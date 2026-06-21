local Debug      = require "src.settings.debug"
local Settings   = require "src.settings.settings"
local Window     = require "src.settings.window"
local State      = require "src.ui.state"
local MainMenu   = require "src.ui.main_menu"
local InGame     = require "src.ui.in_game"
local SettingsUI = require "src.ui.settingsUI"

local screens = {}

function love.load()
    Settings.load()
    Window.load()

    MainMenu.load()
    InGame.load()
    SettingsUI.load()

    screens = {
        [State.MAIN_MENU] = MainMenu,
        [State.IN_GAME]   = InGame,
        [State.SETTINGS]  = SettingsUI,
    }

    Debug.load()
end

function love.update(dt)
    Debug.update(dt)
    Window.update()
    local screen = screens[State.get()]
    if screen and screen.update then screen.update(dt) end
end

function love.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

    local screen = screens[State.get()]
    if screen and screen.draw then screen.draw() end

    if Settings.get("show_debug") then
        Debug.draw()
    end
end

function love.keypressed(key)
    if key == "f1"  then Settings.toggle("show_debug") end
    if key == "f3"  then Debug.toggle("debug_fps") end
    if key == "f4"  then Debug.toggle("debug_mem") end
    if key == "f5"  then Debug.toggle("debug_ups") end
    if key == "f6"  then Debug.toggle("debug_playtime") end
    if key == "f11" then Window.toggleFullscreen() end

    local screen = screens[State.get()]
    if screen and screen.keypressed then screen.keypressed(key) end
end

function love.mousepressed(x, y, btn)
    local screen = screens[State.get()]
    if screen and screen.mousepressed then screen.mousepressed(x, y, btn) end
end

function love.mousereleased(x, y, btn)
    local screen = screens[State.get()]
    if screen and screen.mousereleased then screen.mousereleased(x, y, btn) end
end
