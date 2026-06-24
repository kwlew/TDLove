local Button   = require "src.ui.button"
local State    = require "src.ui.state"
local Settings = require "src.settings.settings"
local Window   = require "src.settings.window"
local Debug    = require "src.settings.debug"
local draw     = require "src.ui.utils.draw"
local theme    = require "src.ui.utils.theme"
local Audio    = require "src.audio"

local SettingsUI = {}

-- ── Layout constants (sourced from theme — sizes don't change between palettes) ─
local PANEL_W        = theme.size.panel_w
local ROW_H          = theme.size.row_h
local SEC_H          = theme.size.sec_h
local TITLE_H        = theme.size.title_h
local PAD_H          = theme.size.pad_h
local PAD_V          = theme.size.pad_v
local TOGGLE_W       = theme.size.toggle_w
local TOGGLE_H       = theme.size.toggle_h
local SLIDER_W       = theme.size.slider_w
local SLIDER_H       = theme.size.slider_h
local HANDLE_R       = theme.size.handle_r
local SELECT_W       = theme.size.select_w
local SELECT_ARROW_W = theme.size.select_arrow_w

-- ── Row definitions ────────────────────────────────────────────────────────────
local ROWS = {
    { kind = "section", label = "General" },
    { kind = "toggle",  key = "fullscreen", label = "Fullscreen" },
    { kind = "input",   key = "fps_cap",    label = "FPS Cap", min = 1, max = 999 },
    { kind = "select",  key = "theme",      label = "Theme",
      options = {"blue", "red"}, display = {"Blue", "Red"} },
    { kind = "section", label = "Audio" },
    { kind = "slider",  key = "volume",       label = "Master Volume", min = 0, max = 1 },
    { kind = "slider",  key = "music_volume", label = "Music Volume",  min = 0, max = 1 },
    { kind = "slider",  key = "sfx_volume",   label = "SFX Volume",    min = 0, max = 1 },
    { kind = "section", label = "Debug" },
    { kind = "toggle",  key = "show_debug",     label = "Debug Overlay" },
    { kind = "toggle",  key = "debug_fps",      label = "FPS Counter" },
    { kind = "toggle",  key = "debug_mem",      label = "Memory Usage" },
    { kind = "toggle",  key = "debug_ups",      label = "Updates / Second" },
    { kind = "toggle",  key = "debug_playtime", label = "Play Time" },
}

-- ── Module state ───────────────────────────────────────────────────────────────
local _fonts    = {}
local _back_btn = nil
local _panel    = { x = 0, y = 0, w = 0, h = 0 }
local _last_w, _last_h = 0, 0
local _drag_key   = nil
local _drag_val   = nil
local _scroll     = 0
local _max_scroll = 0
-- text input state
local _input_key   = nil   -- key of the row currently being edited
local _input_str   = ""    -- live text buffer while editing
local _input_blink = 0     -- cursor blink accumulator

-- ── Private helpers ────────────────────────────────────────────────────────────
local function row_height(row)
    return row.kind == "section" and SEC_H or ROW_H
end

local function rows_total_height()
    local h = 0
    for _, r in ipairs(ROWS) do h = h + row_height(r) end
    return h
end

-- X position for a right-aligned widget of the given width.
local function widget_x(w)
    return _panel.x + _panel.w - PAD_H - w
end

local function slider_val_from_mouse(row, mx, bar_x)
    local t   = math.max(0, math.min(1, (mx - bar_x) / SLIDER_W))
    local raw = row.min + t * (row.max - row.min)
    return math.floor(raw * 100 + 0.5) / 100
end

local function apply_toggle(row)
    if row.key == "fullscreen" then
        Window.toggleFullscreen()
        Settings.set("fullscreen", love.window.getFullscreen())
    elseif Debug.flags[row.key] ~= nil then
        Debug.toggle(row.key)
    else
        Settings.toggle(row.key)
    end
end

local function cycle_select(row, dir)
    local val = Settings.get(row.key)
    local idx = 1
    for i, opt in ipairs(row.options) do
        if opt == val then idx = i; break end
    end
    idx = ((idx - 1 + dir) % #row.options) + 1
    Settings.set(row.key, row.options[idx])
    if row.key == "theme" then theme.activate(row.options[idx]) end
end

-- Commit whatever is in _input_str to settings, then clear input state.
local function confirm_input()
    if not _input_key then return end
    local n = tonumber(_input_str)
    if n then
        for _, row in ipairs(ROWS) do
            if row.key == _input_key then
                n = math.max(row.min, math.min(row.max, math.floor(n)))
                break
            end
        end
        Settings.set(_input_key, n)
    end
    _input_key = nil
    _input_str = ""
end

local function rebuild()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    _last_w, _last_h = sw, sh

    local content_h = rows_total_height() + PAD_V * 2 + TITLE_H
    local ph = math.min(content_h, math.floor(sh * 0.76))

    _panel.x = math.floor(sw / 2 - PANEL_W / 2)
    _panel.y = math.floor(sh / 2 - ph / 2)
    _panel.w = PANEL_W
    _panel.h = ph

    _max_scroll = math.max(0, content_h - ph)
    _scroll     = math.max(0, math.min(_scroll, _max_scroll))

    local bw, bh = theme.size.back_btn_w, theme.size.back_btn_h
    _back_btn = Button.new(
        _panel.x + 14,
        _panel.y + PAD_V + math.floor((TITLE_H - bh) / 2),
        bw, bh, "← Back",
        function() State.set(State._settings_back) end
    )
end

-- ── Draw helpers ───────────────────────────────────────────────────────────────
local function draw_row_label(label, cy)
    love.graphics.setFont(_fonts.label)
    love.graphics.setColor(theme.color.text_label)
    love.graphics.print(label, _panel.x + PAD_H, cy + math.floor((ROW_H - _fonts.label:getHeight()) / 2))
end

local function draw_section(row, cy)
    love.graphics.setFont(_fonts.section)
    love.graphics.setColor(theme.color.text_section)
    love.graphics.print(row.label:upper(), _panel.x + PAD_H, cy + 8)

    love.graphics.setColor(theme.color.section_divider)
    love.graphics.rectangle("fill", _panel.x + PAD_H, cy + SEC_H - 3, _panel.w - PAD_H * 2, 1)
end

local function draw_toggle(row, cy)
    draw_row_label(row.label, cy)

    local val    = Settings.get(row.key)
    local pill_x = widget_x(TOGGLE_W)
    local pill_y = cy + math.floor((ROW_H - TOGGLE_H) / 2)

    if val then
        local oo = theme.size.toggle_glow_outer
        local oi = theme.size.toggle_glow_inner
        love.graphics.setColor(theme.color.toggle_glow_outer)
        love.graphics.rectangle("line", pill_x - oo, pill_y - oo, TOGGLE_W + oo*2, TOGGLE_H + oo*2, TOGGLE_H/2 + oo)
        love.graphics.setColor(theme.color.toggle_glow_inner)
        love.graphics.rectangle("line", pill_x - oi, pill_y - oi, TOGGLE_W + oi*2, TOGGLE_H + oi*2, TOGGLE_H/2 + oi)
    end
    love.graphics.setColor(val and theme.color.toggle_on or theme.color.toggle_off)
    love.graphics.rectangle("fill", pill_x, pill_y, TOGGLE_W, TOGGLE_H, TOGGLE_H / 2)
    love.graphics.setColor(val and theme.color.toggle_border_on or theme.color.toggle_border_off)
    love.graphics.rectangle("line", pill_x, pill_y, TOGGLE_W, TOGGLE_H, TOGGLE_H / 2)

    local knob_r  = TOGGLE_H / 2 - theme.size.toggle_knob_inset
    local knob_cx = val and (pill_x + TOGGLE_W - TOGGLE_H / 2) or (pill_x + TOGGLE_H / 2)
    love.graphics.setColor(theme.color.toggle_knob)
    love.graphics.circle("fill", knob_cx, pill_y + TOGGLE_H / 2, knob_r)
end

local function draw_slider(row, cy)
    draw_row_label(row.label, cy)

    local val   = (_drag_key == row.key) and _drag_val or Settings.get(row.key)
    local t     = (val - row.min) / (row.max - row.min)
    local bar_x = widget_x(SLIDER_W)
    local bar_y = cy + math.floor(ROW_H / 2 - SLIDER_H / 2)

    love.graphics.setFont(_fonts.hint)
    love.graphics.setColor(theme.color.text_pct)
    local pct = string.format("%d%%", math.floor(val * 100 + 0.5))
    love.graphics.print(pct,
        bar_x - _fonts.hint:getWidth(pct) - 10,
        cy + math.floor((ROW_H - _fonts.hint:getHeight()) / 2))

    love.graphics.setColor(theme.color.slider_track)
    love.graphics.rectangle("fill", bar_x, bar_y, SLIDER_W, SLIDER_H, theme.size.slider_corner)
    love.graphics.setColor(theme.color.slider_track_border)
    love.graphics.rectangle("line", bar_x, bar_y, SLIDER_W, SLIDER_H, theme.size.slider_corner)

    local ge = theme.size.slider_glow_expand
    if t > 0 then
        love.graphics.setColor(theme.color.slider_fill_glow)
        love.graphics.rectangle("fill", bar_x, bar_y - ge, math.max(0, t * SLIDER_W), SLIDER_H + ge*2, theme.size.slider_corner)
    end
    love.graphics.setColor(theme.color.slider_fill)
    love.graphics.rectangle("fill", bar_x, bar_y, math.max(0, t * SLIDER_W), SLIDER_H, theme.size.slider_corner)

    local hx = bar_x + t * SLIDER_W
    local hy = bar_y + SLIDER_H / 2
    draw.glow_circle(hx, hy, HANDLE_R, theme.color.toggle_knob, theme.color.glow, theme.alpha.slider_handle)
end

local function draw_select(row, cy)
    draw_row_label(row.label, cy)

    local val     = Settings.get(row.key)
    local display = tostring(val)
    for i, opt in ipairs(row.options) do
        if opt == val then display = row.display[i]; break end
    end

    local rx = widget_x(SELECT_W)
    local ry = cy + math.floor((ROW_H - TOGGLE_H) / 2)

    draw.glow_rect(rx, ry, SELECT_W, TOGGLE_H, TOGGLE_H / 2,
        theme.color.toggle_off, theme.color.glow, 0.35)

    love.graphics.setFont(_fonts.hint)
    local fh = _fonts.hint:getHeight()
    local ty = ry + math.floor((TOGGLE_H - fh) / 2)

    love.graphics.setColor(theme.color.text_dim)
    love.graphics.print("<", rx + 8, ty)
    love.graphics.print(">", rx + SELECT_W - _fonts.hint:getWidth(">") - 8, ty)

    love.graphics.setColor(theme.color.text_title)
    love.graphics.print(display, rx + math.floor((SELECT_W - _fonts.hint:getWidth(display)) / 2), ty)
end

local function draw_input(row, cy)
    draw_row_label(row.label, cy)

    local focused = (_input_key == row.key)
    local text    = focused and _input_str or tostring(Settings.get(row.key))

    local rx = widget_x(SELECT_W)
    local ry = cy + math.floor((ROW_H - TOGGLE_H) / 2)

    draw.glow_rect(rx, ry, SELECT_W, TOGGLE_H, TOGGLE_H / 2,
        theme.color.toggle_off, theme.color.glow, focused and 0.80 or 0.35)

    love.graphics.setFont(_fonts.hint)
    local fh     = _fonts.hint:getHeight()
    local ty     = ry + math.floor((TOGGLE_H - fh) / 2)
    local tw     = _fonts.hint:getWidth(text)
    local text_x = rx + math.floor((SELECT_W - tw) / 2)

    love.graphics.setColor(theme.color.text_title)
    love.graphics.print(text, text_x, ty)

    -- blinking cursor after the last character
    if focused and math.floor(_input_blink * 2) % 2 == 0 then
        love.graphics.setColor(theme.color.text_title)
        love.graphics.rectangle("fill", text_x + tw + 2, ty + 1, 1, fh - 2)
    end
end

-- ── Public interface ───────────────────────────────────────────────────────────
function SettingsUI.load()
    _fonts = {
        title   = love.graphics.newFont(theme.font.afacad_extrabold, theme.size.font_settings_title),
        section = love.graphics.newFont(theme.font.afacad_bold,      theme.size.font_settings_section),
        label   = love.graphics.newFont(theme.font.afacad_regular,   theme.size.font_settings_label),
        hint    = love.graphics.newFont(theme.font.fira_semibold,    theme.size.font_settings_hint),
    }
    rebuild()
end

function SettingsUI.update(dt)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if sw ~= _last_w or sh ~= _last_h then rebuild() end

    _input_blink = _input_blink + dt

    local mx, my = love.mouse.getPosition()
    _back_btn:update(mx, my)

    if _drag_key and love.mouse.isDown(1) then
        local bar_x = widget_x(SLIDER_W)
        for _, row in ipairs(ROWS) do
            if row.kind == "slider" and row.key == _drag_key then
                _drag_val = slider_val_from_mouse(row, mx, bar_x)
                break
            end
        end
    end
end

function SettingsUI.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    draw.glow_rect(_panel.x, _panel.y, _panel.w, _panel.h, 10,
        theme.color.panel_fill, theme.color.glow_panel, theme.alpha.panel)

    love.graphics.setFont(_fonts.title)
    love.graphics.setColor(theme.color.text_title)
    local title = "Settings"
    love.graphics.print(title,
        math.floor(_panel.x + _panel.w / 2 - _fonts.title:getWidth(title) / 2),
        _panel.y + PAD_V)

    -- Clip row content to the scrollable area
    local clip_y = _panel.y + TITLE_H + PAD_V
    local clip_h = _panel.h - TITLE_H - PAD_V * 2
    love.graphics.setScissor(_panel.x, clip_y, _panel.w, clip_h)

    local cy = _panel.y + PAD_V + TITLE_H - _scroll
    for _, row in ipairs(ROWS) do
        if     row.kind == "section" then draw_section(row, cy)
        elseif row.kind == "toggle"  then draw_toggle(row, cy)
        elseif row.kind == "slider"  then draw_slider(row, cy)
        elseif row.kind == "select"  then draw_select(row, cy)
        elseif row.kind == "input"   then draw_input(row, cy)
        end
        cy = cy + row_height(row)
    end

    love.graphics.setScissor()

    -- Thin scrollbar when content overflows
    if _max_scroll > 0 then
        local sbar_x    = _panel.x + _panel.w - 5
        local sbar_y    = clip_y + 2
        local sbar_h    = clip_h - 4
        local content_h = rows_total_height() + PAD_V * 2 + TITLE_H
        local thumb_h   = math.max(16, sbar_h * (_panel.h / content_h))
        local thumb_y   = sbar_y + (_scroll / _max_scroll) * (sbar_h - thumb_h)
        love.graphics.setColor(theme.color.section_divider)
        love.graphics.rectangle("fill", sbar_x, sbar_y, 3, sbar_h, 1)
        love.graphics.setColor(theme.color.text_muted)
        love.graphics.rectangle("fill", sbar_x, thumb_y, 3, thumb_h, 1)
    end

    _back_btn:draw(_fonts.label)

    love.graphics.setFont(_fonts.hint)
    love.graphics.setColor(theme.color.text_muted)
    love.graphics.print("Escape — Back  •  F11 fullscreen  •  Scroll wheel to scroll",
        theme.size.hint_margin_x, sh - theme.size.hint_margin_bottom)
end

function SettingsUI.mousepressed(x, y, btn)
    if btn ~= 1 then return end

    -- Commit any open text input before processing the click.
    confirm_input()

    _back_btn:mousepressed(x, y, btn)

    -- Only process row hits within the scrollable content area
    local clip_top = _panel.y + TITLE_H + PAD_V
    local clip_bot = _panel.y + _panel.h
    if y < clip_top or y > clip_bot then return end

    local cy = _panel.y + PAD_V + TITLE_H - _scroll
    for _, row in ipairs(ROWS) do
        if row.kind == "toggle" then
            local pill_x = widget_x(TOGGLE_W)
            local pill_y = cy + math.floor((ROW_H - TOGGLE_H) / 2)
            if x >= pill_x and x <= pill_x + TOGGLE_W
            and y >= pill_y and y <= pill_y + TOGGLE_H then
                apply_toggle(row)
            end

        elseif row.kind == "slider" then
            local bar_x = widget_x(SLIDER_W)
            local bar_y = cy + math.floor(ROW_H / 2 - SLIDER_H / 2)
            if x >= bar_x - HANDLE_R and x <= bar_x + SLIDER_W + HANDLE_R
            and y >= bar_y - HANDLE_R and y <= bar_y + SLIDER_H + HANDLE_R then
                _drag_key = row.key
                _drag_val = slider_val_from_mouse(row, x, bar_x)
            end

        elseif row.kind == "select" then
            local rx = widget_x(SELECT_W)
            local ry = cy + math.floor((ROW_H - TOGGLE_H) / 2)
            if y >= ry and y <= ry + TOGGLE_H then
                if x >= rx and x < rx + SELECT_ARROW_W then
                    cycle_select(row, -1)
                elseif x >= rx + SELECT_W - SELECT_ARROW_W and x <= rx + SELECT_W then
                    cycle_select(row, 1)
                end
            end

        elseif row.kind == "input" then
            local rx = widget_x(SELECT_W)
            local ry = cy + math.floor((ROW_H - TOGGLE_H) / 2)
            if x >= rx and x <= rx + SELECT_W and y >= ry and y <= ry + TOGGLE_H then
                _input_key   = row.key
                _input_str   = tostring(Settings.get(row.key))
                _input_blink = 0
            end
        end

        cy = cy + row_height(row)
    end
end

function SettingsUI.mousereleased(x, y, btn)
    if btn == 1 and _drag_key and _drag_val ~= nil then
        Settings.set(_drag_key, _drag_val)
        if _drag_key == "volume" or _drag_key == "music_volume" or _drag_key == "sfx_volume" then
            Audio.sync()
        end
    end
    _drag_key = nil
    _drag_val = nil
end

function SettingsUI.textinput(char)
    if not _input_key then return end
    -- Only accept digits; cap at 3 characters to keep values within 1-999.
    if char:match("%d") and #_input_str < 3 then
        _input_str   = _input_str .. char
        _input_blink = 0
    end
end

function SettingsUI.keypressed(key)
    if _input_key then
        if key == "backspace" then
            _input_str   = _input_str:sub(1, -2)
            _input_blink = 0
        elseif key == "return" or key == "kpenter" then
            confirm_input()
        elseif key == "escape" then
            -- Cancel edit without saving.
            _input_key = nil
            _input_str = ""
        end
        -- Swallow all keys while the input is focused.
        return
    end

    if key == "escape" then State.set(State._settings_back) end
end

function SettingsUI.wheelmoved(x, y)
    _scroll = math.max(0, math.min(_max_scroll, _scroll - y * 30))
end

return SettingsUI
