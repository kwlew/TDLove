local Button   = require "src.ui.button"
local State    = require "src.ui.state"
local Settings = require "src.settings.settings"

local MainMenu = {}

local _buttons    = {}
local _font       = nil
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
            function() end),  -- placeholder
        Button.new(cx, startY + (bh + gap)*2, bw, bh, "Quit",
            function() Settings.save(); love.event.quit() end),
    }
end

function MainMenu.load()
    _font       = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Bold.ttf",      22)
    _title_font = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-ExtraBold.ttf", 56)
    _hint_font  = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Regular.ttf",   14)
    rebuild()
end

function MainMenu.update(dt)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if sw ~= _last_w or sh ~= _last_h then rebuild() end

    local mx, my = love.mouse.getPosition()
    for _, btn in ipairs(_buttons) do btn:update(mx, my) end
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

    love.graphics.setColor(1, 1, 1, 0.92)
    love.graphics.print(title, tx, ty)

    -- Subtitle
    love.graphics.setFont(_hint_font)
    local sub = "Tower Defense  •  Idle"
    love.graphics.setColor(0.55, 0.75, 1, 0.45)
    love.graphics.print(sub, math.floor(sw / 2 - _hint_font:getWidth(sub) / 2), ty + th + 6)

    -- Buttons
    for _, btn in ipairs(_buttons) do btn:draw(_font) end

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
end

return MainMenu
