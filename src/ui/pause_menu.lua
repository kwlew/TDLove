local Button = require "src.ui.button"
local State  = require "src.ui.state"
local draw   = require "src.ui.utils.draw"
local theme  = require "src.ui.utils.theme"

local PauseMenu = {}

local PANEL_W   = 400
local PANEL_H   = 330
local OVERLAY_A = 0.65

local _font       = nil
local _title_font = nil
local _buttons    = {}
local _last_w, _last_h = 0, 0

local function rebuild()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    _last_w, _last_h = sw, sh

    local bw, bh = theme.size.btn_w, theme.size.btn_h
    local gap  = theme.size.btn_gap
    local cx   = math.floor(sw / 2 - bw / 2)
    local by   = math.floor(sh / 2 - 80)

    _buttons = {
        Button.new(cx, by,                bw, bh, "Resume",
            function() State.set(State.IN_GAME) end),
        Button.new(cx, by + (bh + gap),   bw, bh, "Settings",
            function() State.goSettings(State.PAUSED) end),
        Button.new(cx, by + (bh + gap)*2, bw, bh, "Quit to Menu",
            function() State.set(State.MAIN_MENU) end),
    }
end

function PauseMenu.load()
    _title_font = love.graphics.newFont(theme.font.afacad_extrabold, theme.size.font_settings_title)
    _font       = love.graphics.newFont(theme.font.afacad_bold,      theme.size.font_btn)
    rebuild()
end

function PauseMenu.update(dt)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if sw ~= _last_w or sh ~= _last_h then rebuild() end

    local mx, my = love.mouse.getPosition()
    for _, btn in ipairs(_buttons) do btn:update(mx, my) end
end

function PauseMenu.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Full-screen dark overlay
    love.graphics.setColor(0, 0, 0, OVERLAY_A)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Frosted panel
    local px = math.floor(sw / 2 - PANEL_W / 2)
    local py = math.floor(sh / 2 - PANEL_H / 2)
    draw.glow_rect(px, py, PANEL_W, PANEL_H, 10,
        theme.color.panel_fill, theme.color.glow_panel, theme.alpha.panel)

    -- Title
    love.graphics.setFont(_title_font)
    local title = "PAUSED"
    love.graphics.setColor(theme.color.text_title)
    love.graphics.print(title, math.floor(sw / 2 - _title_font:getWidth(title) / 2), py + 24)

    -- Buttons
    for _, btn in ipairs(_buttons) do btn:draw(_font) end
end

function PauseMenu.keypressed(key)
    if key == "escape" then State.set(State.IN_GAME) end
end

function PauseMenu.mousepressed(x, y, btn)
    for _, b in ipairs(_buttons) do b:mousepressed(x, y, btn) end
end

return PauseMenu
