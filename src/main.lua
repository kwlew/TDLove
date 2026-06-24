local Debug      = require "src.settings.debug"
local Audio      = require "src.audio"
local theme      = require "src.ui.utils.theme"
local Settings   = require "src.settings.settings"
local Window     = require "src.settings.window"
local State      = require "src.ui.state"
local MainMenu   = require "src.ui.main_menu"
local InGame     = require "src.ui.in_game"
local SettingsUI = require "src.ui.settingsUI"
local PauseMenu  = require "src.ui.pause_menu"

local screens = {}

function love.load()
    Settings.load()
    theme.activate(Settings.get("theme"))
    Audio.load()
    Audio.sync()

    MainMenu.load()
    InGame.load()
    SettingsUI.load()
    PauseMenu.load()

    screens = {
        [State.MAIN_MENU] = MainMenu,
        [State.IN_GAME]   = InGame,
        [State.SETTINGS]  = SettingsUI,
        [State.PAUSED]    = PauseMenu,
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
    love.graphics.setBackgroundColor(theme.color.bg)

    if State.is(State.PAUSED) then
        InGame.draw()
        PauseMenu.draw()
    else
        local screen = screens[State.get()]
        if screen and screen.draw then screen.draw() end
    end

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

function love.textinput(char)
    local screen = screens[State.get()]
    if screen and screen.textinput then screen.textinput(char) end
end

function love.wheelmoved(x, y)
    local screen = screens[State.get()]
    if screen and screen.wheelmoved then screen.wheelmoved(x, y) end
end

function love.quit()
    Settings.save()
end
