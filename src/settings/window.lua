local Window = {}
local Settings = require "src.settings.settings"

Window.config = {
    unfocused_fps_cap = 60,
    width = 1280,
    height = 720,
    title = "TD by kwlew",
    icon_path = "assets/icon.png",
    resizable = true,
    min_width = 1280,
    min_height = 720,
    state = "main_menu",
}

function Window.load()
    love.window.setTitle(Window.config.title)
    love.window.setIcon(love.image.newImageData(Window.config.icon_path))
    love.window.setMode(Window.config.width, Window.config.height, {
        resizable = Window.config.resizable,
        minwidth = Window.config.min_width,
        minheight = Window.config.min_height,
    })
end

function Window.update()
    Window.focusCheck()
end

function Window.toggleFullscreen()
    local isFullscreen = love.window.getFullscreen()
    love.window.setFullscreen(not isFullscreen, "desktop")
end

function Window.focusCheck()
    if not love.window.hasFocus() then
        Window.setFps(Window.config.unfocused_fps_cap)
    end
end

function Window.setFps(cap)
    love.timer.sleep(1 / cap)
end

function Window.getDimensions()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

return Window