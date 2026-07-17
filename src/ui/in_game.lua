local State = require "src.ui.state"
local draw  = require "src.ui.utils.draw"
local theme = require "src.ui.utils.theme"

local InGame = {}

local _hud_font  = nil
local _hint_font = nil

function InGame.load()
    _hud_font  = love.graphics.newFont(theme.font.afacad_bold,   theme.size.font_btn)
    _hint_font = love.graphics.newFont(theme.font.fira_semibold, theme.size.font_hint)
end

function InGame.update(dt)
    -- placeholder: game logic goes here
end

function InGame.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Top HUD bar (placeholder)
    love.graphics.setColor(theme.color.hud_fill)
    love.graphics.rectangle("fill", 0, 0, sw, theme.size.hud_h)
    draw.glow_hline(0, sw, theme.size.hud_h, theme.color.glow_hud, theme.alpha.hud_line)

    love.graphics.setFont(_hud_font)
    love.graphics.setColor(theme.color.text_dim)
    love.graphics.print("Wave: 1", theme.size.hud_wave_x, theme.size.hud_item_y)

    love.graphics.setColor(theme.color.text_gold)
    love.graphics.print("Gold: 100", theme.size.hud_gold_x, theme.size.hud_item_y)

    love.graphics.setColor(theme.color.text_lives)
    love.graphics.print("Lives: 20", theme.size.hud_lives_x, theme.size.hud_item_y)

    -- Center placeholder label
    love.graphics.setFont(_hud_font)
    love.graphics.setColor(theme.color.text_faint)
    local msg = "69"
    love.graphics.print(msg, math.floor(sw / 2 - _hud_font:getWidth(msg) / 2), math.floor(sh / 2 - theme.size.placeholder_y_offset))

    -- Bottom hint
    love.graphics.setFont(_hint_font)
    love.graphics.setColor(theme.color.text_hint)
    love.graphics.print("Escape — Pause  •  F11 fullscreen  •  F1 debug", theme.size.hint_margin_x, sh - theme.size.hint_margin_bottom)
end

function InGame.keypressed(key)
    if key == "escape" then
        State.set(State.PAUSED)
    end
end

function InGame.mousepressed(x, y, btn)
    -- placeholder
end

return InGame
