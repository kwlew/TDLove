local Button   = require "src.ui.button"
local State    = require "src.ui.state"
local Settings = require "src.settings.settings"
local rgb_text = require "src.ui.utils.rgb_text"
local draw     = require "src.ui.utils.draw"
local theme    = require "src.ui.utils.theme"

local MainMenu = {}

local _buttons     = {}
local _github_icon = nil
local _github_img  = nil
local _font        = nil
local _title_font = nil
local _hint_font  = nil
local _last_w, _last_h = 0, 0

local function rebuild()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    _last_w, _last_h = sw, sh

    local bw, bh = theme.size.btn_w, theme.size.btn_h
    local cx     = math.floor(sw / 2 - bw / 2)
    local gap    = theme.size.btn_gap
    local startY = math.floor(sh * theme.size.menu_btn_start_y)

    _buttons = {
        Button.new(cx, startY,                bw, bh, "Play",
            function() State.set(State.IN_GAME) end),
        Button.new(cx, startY + (bh + gap),   bw, bh, "Settings",
            function() State.goSettings(State.MAIN_MENU) end),
        Button.new(cx, startY + (bh + gap)*2, bw, bh, "Quit",
            function() Settings.save(); love.event.quit() end),
    }

    local size   = theme.size.github_size
    local margin = theme.size.github_margin
    _github_icon = {
        size    = size,
        x       = sw - size - margin,
        y       = sh - size - margin,
        hovered = false,
        onClick = function() love.system.openURL("https://github.com/kwlew/TDLove") end,
    }
end

function MainMenu.load()
    _font       = love.graphics.newFont(theme.font.afacad_bold,      theme.size.font_btn)
    _title_font = love.graphics.newFont(theme.font.afacad_extrabold, theme.size.font_menu_title)
    _hint_font  = love.graphics.newFont(theme.font.fira_semibold,    theme.size.font_hint)
    _github_img = love.graphics.newImage("assets/images/socials/github.png")
    rebuild()
end

function MainMenu.update(dt)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if sw ~= _last_w or sh ~= _last_h then rebuild() end

    local mx, my = love.mouse.getPosition()
    for _, btn in ipairs(_buttons) do btn:update(mx, my) end
    _github_icon.hovered = mx >= _github_icon.x and mx <= _github_icon.x + _github_icon.size
                       and my >= _github_icon.y and my <= _github_icon.y + _github_icon.size
end

function MainMenu.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Title
    love.graphics.setFont(_title_font)
    local title = "TD Idle"
    local tw = _title_font:getWidth(title)
    local th = _title_font:getHeight()
    local tx = math.floor(sw / 2 - tw / 2)
    local ty = math.floor(sh * theme.size.menu_title_y - th / 2)

    local px, py = theme.size.title_pad_x, theme.size.title_pad_y
    draw.glow_rect(tx - px, ty - py, tw + px * 2, th + py * 2, theme.size.title_corner, theme.color.title_box_fill, theme.color.glow_title, theme.alpha.title_box)

    rgb_text.draw(title, tx, ty)

    -- Subtitle
    love.graphics.setFont(_hint_font)
    local sub = "Tower Defense  •  Idle"
    love.graphics.setColor(theme.color.text_subtitle)
    love.graphics.print(sub, math.floor(sw / 2 - _hint_font:getWidth(sub) / 2), ty + th + theme.size.title_pad_y + theme.size.subtitle_gap)

    -- Buttons
    for _, btn in ipairs(_buttons) do btn:draw(_font) end

    -- GitHub icon (bottom-right)
    local scale = _github_icon.size / _github_img:getWidth()
    love.graphics.setColor(_github_icon.hovered and theme.color.text or theme.color.github_dim)
    love.graphics.draw(_github_img, _github_icon.x, _github_icon.y, 0, scale, scale)

    -- Bottom hint
    love.graphics.setFont(_hint_font)
    love.graphics.setColor(theme.color.text_hint)
    love.graphics.print("Escape to quit  •  F11 fullscreen  •  F1 debug", theme.size.hint_margin_x, sh - theme.size.hint_margin_bottom)
end

function MainMenu.keypressed(key)
    if key == "escape" then
        Settings.save()
        love.event.quit()
    end
end

function MainMenu.mousepressed(x, y, btn)
    for _, b in ipairs(_buttons) do b:mousepressed(x, y, btn) end
    if btn == 1 and _github_icon.hovered then _github_icon.onClick() end
end

return MainMenu
