local State = require "src.ui.state"

local InGame = {}

local _hud_font  = nil
local _hint_font = nil

function InGame.load()
    _hud_font  = love.graphics.newFont("assets/fonts/Afacad-Flux/AfacadFlux-Bold.ttf",    22)
    _hint_font = love.graphics.newFont("assets/fonts/Fira-Sans/FiraSans-SemiBold.ttf", 14)
end

function InGame.update(dt)
    -- placeholder: game logic goes here
end

function InGame.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Top HUD bar (placeholder)
    love.graphics.setColor(0.08, 0.14, 0.22, 0.92)
    love.graphics.rectangle("fill", 0, 0, sw, 58)
    love.graphics.setColor(0.3, 0.6, 1, 0.25)
    love.graphics.rectangle("line", 0, 0, sw, 58)

    love.graphics.setFont(_hud_font)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.print("Wave: 1", 20, 16)

    love.graphics.setColor(0.9, 0.8, 0.2, 0.85)
    love.graphics.print("Gold: 100", 160, 16)

    love.graphics.setColor(0.3, 0.9, 0.4, 0.85)
    love.graphics.print("Lives: 20", 320, 16)

    -- Center placeholder label
    love.graphics.setFont(_hud_font)
    love.graphics.setColor(1, 1, 1, 0.12)
    local msg = "[ Game World Placeholder ]"
    love.graphics.print(msg, math.floor(sw / 2 - _hud_font:getWidth(msg) / 2), math.floor(sh / 2 - 11))

    -- Bottom hint
    love.graphics.setFont(_hint_font)
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.print("Escape — Main Menu  •  F11 fullscreen  •  F1 debug", 10, sh - 24)
end

function InGame.keypressed(key)
    if key == "escape" then
        State.set(State.MAIN_MENU)
    end
end

function InGame.mousepressed(x, y, btn)
    -- placeholder
end

return InGame
