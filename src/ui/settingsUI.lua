local Button   = require "src.ui.button"
local State    = require "src.ui.state"
local Settings = require "src.settings.settings"
local Window   = require "src.settings.window"
local Debug    = require "src.settings.debug"

local SettingsUI = {}

-- ── Layout constants ───────────────────────────────────────────────────────────
local PANEL_W  = 560
local ROW_H    = 50
local SEC_H    = 38
local TITLE_H  = 54
local PAD_H    = 36
local PAD_V    = 20
local TOGGLE_W = 48
local TOGGLE_H = 24
local SLIDER_W = 200
local SLIDER_H = 6
local HANDLE_R = 8

-- ── Row definitions (static) ───────────────────────────────────────────────────
local ROWS = {
    { kind = "section", label = "General" },
    { kind = "toggle",  key = "fullscreen",      label = "Fullscreen" },
    { kind = "slider",  key = "volume",           label = "Volume",  min = 0, max = 1 },
    { kind = "section", label = "Debug" },
    { kind = "toggle",  key = "show_debug",       label = "Debug Overlay" },
    { kind = "toggle",  key = "debug_fps",        label = "FPS Counter" },
    { kind = "toggle",  key = "debug_mem",        label = "Memory Usage" },
    { kind = "toggle",  key = "debug_ups",        label = "Updates / Second" },
    { kind = "toggle",  key = "debug_playtime",   label = "Play Time" },
}

-- ── Module state ───────────────────────────────────────────────────────────────
local _fonts    = {}
local _back_btn = nil
local _panel    = { x = 0, y = 0, w = 0, h = 0 }
local _last_w, _last_h = 0, 0
local _drag_key = nil  -- key of the slider currently being dragged
local _drag_val = nil  -- live value during drag; saved to Settings only on release

-- ── Private helpers ────────────────────────────────────────────────────────────
local function rows_total_height()
    local h = 0
    for _, r in ipairs(ROWS) do
        h = h + (r.kind == "section" and SEC_H or ROW_H)
    end
    return h
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

local function rebuild()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    _last_w, _last_h = sw, sh

    local ph    = rows_total_height() + PAD_V * 2 + TITLE_H
    _panel.x    = math.floor(sw / 2 - PANEL_W / 2)
    _panel.y    = math.floor(sh / 2 - ph / 2)
    _panel.w    = PANEL_W
    _panel.h    = ph

    local bw, bh = 140, 44
    _back_btn = Button.new(
        math.floor(sw / 2 - bw / 2), sh - bh - 16,
        bw, bh, "← Back",
        function() State.set(State.MAIN_MENU) end
    )
end

-- ── Draw helpers ───────────────────────────────────────────────────────────────
local function draw_section(row, cy)
    love.graphics.setFont(_fonts.section)
    love.graphics.setColor(0.45, 0.65, 1, 0.55)
    love.graphics.print(row.label:upper(), _panel.x + PAD_H, cy + 8)

    love.graphics.setColor(0.3, 0.5, 1, 0.12)
    love.graphics.rectangle("fill",
        _panel.x + PAD_H, cy + SEC_H - 3,
        _panel.w - PAD_H * 2, 1)
end

local function draw_toggle(row, cy)
    love.graphics.setFont(_fonts.label)
    love.graphics.setColor(1, 1, 1, 0.82)
    love.graphics.print(row.label,
        _panel.x + PAD_H,
        cy + math.floor((ROW_H - _fonts.label:getHeight()) / 2))

    local val    = Settings.get(row.key)
    local pill_x = _panel.x + _panel.w - PAD_H - TOGGLE_W
    local pill_y = cy + math.floor((ROW_H - TOGGLE_H) / 2)

    love.graphics.setColor(val and 0.22 or 0.20, val and 0.68 or 0.24, val and 0.38 or 0.32, 0.90)
    love.graphics.rectangle("fill", pill_x, pill_y, TOGGLE_W, TOGGLE_H, TOGGLE_H / 2)

    local knob_r  = TOGGLE_H / 2 - 3
    local knob_cx = val and (pill_x + TOGGLE_W - TOGGLE_H / 2) or (pill_x + TOGGLE_H / 2)
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.circle("fill", knob_cx, pill_y + TOGGLE_H / 2, knob_r)
end

local function draw_slider(row, cy)
    love.graphics.setFont(_fonts.label)
    love.graphics.setColor(1, 1, 1, 0.82)
    love.graphics.print(row.label,
        _panel.x + PAD_H,
        cy + math.floor((ROW_H - _fonts.label:getHeight()) / 2))

    -- Use the live drag value while dragging, otherwise the saved value
    local val   = (_drag_key == row.key) and _drag_val or Settings.get(row.key)
    local t     = (val - row.min) / (row.max - row.min)
    local bar_x = _panel.x + _panel.w - PAD_H - SLIDER_W
    local bar_y = cy + math.floor(ROW_H / 2 - SLIDER_H / 2)

    -- Percentage readout
    love.graphics.setFont(_fonts.hint)
    love.graphics.setColor(0.65, 0.82, 1, 0.60)
    local pct = string.format("%d%%", math.floor(val * 100 + 0.5))
    love.graphics.print(pct,
        bar_x - _fonts.hint:getWidth(pct) - 10,
        cy + math.floor((ROW_H - _fonts.hint:getHeight()) / 2))

    -- Track
    love.graphics.setColor(0.18, 0.22, 0.38, 0.80)
    love.graphics.rectangle("fill", bar_x, bar_y, SLIDER_W, SLIDER_H, 3)

    -- Fill
    love.graphics.setColor(0.30, 0.60, 1.00, 0.85)
    love.graphics.rectangle("fill", bar_x, bar_y, math.max(0, t * SLIDER_W), SLIDER_H, 3)

    -- Handle
    local hx = bar_x + t * SLIDER_W
    local hy  = bar_y + SLIDER_H / 2
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.circle("fill", hx, hy, HANDLE_R)
    love.graphics.setColor(0.30, 0.60, 1.00, 0.70)
    love.graphics.circle("line", hx, hy, HANDLE_R)
end

-- ── Public interface ───────────────────────────────────────────────────────────
function SettingsUI.load()
    _fonts = {
        title   = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-ExtraBold.ttf", 38),
        section = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Bold.ttf",      14),
        label   = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Regular.ttf",   18),
        hint    = love.graphics.newFont("assets/fonts/Fira-Sans/FiraSans-SemiBold.ttf",      13),
    }
    rebuild()
end

function SettingsUI.update(dt)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if sw ~= _last_w or sh ~= _last_h then rebuild() end

    local mx, my = love.mouse.getPosition()
    _back_btn:update(mx, my)

    if _drag_key and love.mouse.isDown(1) then
        local bar_x = _panel.x + _panel.w - PAD_H - SLIDER_W
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

    love.graphics.setColor(0.07, 0.10, 0.17, 0.97)
    love.graphics.rectangle("fill", _panel.x, _panel.y, _panel.w, _panel.h, 10)
    love.graphics.setColor(0.30, 0.50, 1.00, 0.22)
    love.graphics.rectangle("line", _panel.x, _panel.y, _panel.w, _panel.h, 10)

    love.graphics.setFont(_fonts.title)
    love.graphics.setColor(1, 1, 1, 0.92)
    local title = "Settings"
    love.graphics.print(title,
        math.floor(_panel.x + _panel.w / 2 - _fonts.title:getWidth(title) / 2),
        _panel.y + PAD_V)

    local cy = _panel.y + PAD_V + TITLE_H
    for _, row in ipairs(ROWS) do
        if     row.kind == "section" then draw_section(row, cy); cy = cy + SEC_H
        elseif row.kind == "toggle"  then draw_toggle(row, cy);  cy = cy + ROW_H
        elseif row.kind == "slider"  then draw_slider(row, cy);  cy = cy + ROW_H
        end
    end

    _back_btn:draw(_fonts.label)

    love.graphics.setFont(_fonts.hint)
    love.graphics.setColor(1, 1, 1, 0.22)
    love.graphics.print("Escape — Back  •  F11 fullscreen", 10, sh - 22)
end

function SettingsUI.mousepressed(x, y, btn)
    if btn ~= 1 then return end
    _back_btn:mousepressed(x, y, btn)

    local cy = _panel.y + PAD_V + TITLE_H
    for _, row in ipairs(ROWS) do
        if row.kind == "toggle" then
            local pill_x = _panel.x + _panel.w - PAD_H - TOGGLE_W
            local pill_y = cy + math.floor((ROW_H - TOGGLE_H) / 2)
            if x >= pill_x and x <= pill_x + TOGGLE_W
            and y >= pill_y and y <= pill_y + TOGGLE_H then
                apply_toggle(row)
            end
            cy = cy + ROW_H

        elseif row.kind == "slider" then
            local bar_x = _panel.x + _panel.w - PAD_H - SLIDER_W
            local bar_y = cy + math.floor(ROW_H / 2 - SLIDER_H / 2)
            if x >= bar_x - HANDLE_R and x <= bar_x + SLIDER_W + HANDLE_R
            and y >= bar_y - HANDLE_R and y <= bar_y + SLIDER_H + HANDLE_R then
                _drag_key = row.key
                _drag_val = slider_val_from_mouse(row, x, bar_x)
            end
            cy = cy + ROW_H

        elseif row.kind == "section" then
            cy = cy + SEC_H
        end
    end
end

function SettingsUI.mousereleased(x, y, btn)
    if btn == 1 and _drag_key and _drag_val ~= nil then
        Settings.set(_drag_key, _drag_val)
    end
    _drag_key = nil
    _drag_val = nil
end

function SettingsUI.keypressed(key)
    if key == "escape" then State.set(State.MAIN_MENU) end
end

return SettingsUI
