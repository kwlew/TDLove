local Button   = require "src.ui.button"
local State    = require "src.ui.state"
local Settings = require "src.settings.settings"
local rgb_text = require "src.ui.utils.rgb_text"

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

    local bw, bh = 240, 54
    local cx     = math.floor(sw / 2 - bw / 2)
    local gap    = 16
    local startY = math.floor(sh * 0.52)

    _buttons = {
        Button.new(cx, startY,                bw, bh, "Play",
            function() State.set(State.IN_GAME) end),
        Button.new(cx, startY + (bh + gap),   bw, bh, "Settings",
            function() State.set(State.SETTINGS) end),
        Button.new(cx, startY + (bh + gap)*2, bw, bh, "Quit",
            function() Settings.save(); love.event.quit() end),
    }

    local size   = 32
    local margin = 14
    _github_icon = {
        size    = size,
        x       = sw - size - margin,
        y       = sh - size - margin,
        hovered = false,
        onClick = function() love.system.openURL("https://github.com/kwlew/TDLove") end,
    }
end

function MainMenu.load()
    _font       = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Bold.ttf",      22)
    _title_font = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-ExtraBold.ttf", 56)
    _hint_font  = love.graphics.newFont("assets/fonts/Fira-Sans/FiraSans-SemiBold.ttf",   14)
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
    local ty = math.floor(sh * 0.22 - th / 2)

    love.graphics.setColor(0.2, 0.5, 1, 0.12)
    love.graphics.rectangle("fill", tx - 28, ty - 14, tw + 56, th + 28, 12)
    love.graphics.setColor(0.4, 0.7, 1, 0.18)
    love.graphics.rectangle("line", tx - 28, ty - 14, tw + 56, th + 28, 12)

    rgb_text.draw(title, tx, ty)

    -- Subtitle
    love.graphics.setFont(_hint_font)
    local sub = "Tower Defense  •  Idle"
    love.graphics.setColor(0.55, 0.75, 1, 0.45)
    love.graphics.print(sub, math.floor(sw / 2 - _hint_font:getWidth(sub) / 2), ty + th + 6)

    -- Buttons
    for _, btn in ipairs(_buttons) do btn:draw(_font) end

    -- GitHub icon (bottom-right)
    local scale = _github_icon.size / _github_img:getWidth()
    love.graphics.setColor(1, 1, 1, _github_icon.hovered and 1 or 0.55)
    love.graphics.draw(_github_img, _github_icon.x, _github_icon.y, 0, scale, scale)

    -- Bottom hint
    love.graphics.setFont(_hint_font)
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.print("Escape to quit  •  F11 fullscreen  •  F1 debug", 10, sh - 24)
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
