local Window   = {}
local Settings = require "src.settings.settings"

Window.config = {
    unfocused_fps_cap = 60,
}

local _frame_start = 0

function Window.update()
    local cap = Settings.get("fps_cap") or 999
    if not love.window.hasFocus() then
        cap = math.min(cap, Window.config.unfocused_fps_cap)
    end

    if cap < 999 then
        local deadline  = _frame_start + 1 / cap
        local remaining = deadline - love.timer.getTime()

        -- Sleep for most of the wait so we don't burn CPU, then spin the last
        -- millisecond for precision (love.timer.sleep is ~1ms accurate on Windows).
        if remaining > 0.002 then
            love.timer.sleep(remaining - 0.001)
        end
        while love.timer.getTime() < deadline do end
    end

    _frame_start = love.timer.getTime()
end

function Window.toggleFullscreen()
    local isFullscreen = love.window.getFullscreen()
    love.window.setFullscreen(not isFullscreen, "desktop")
end

function Window.getDimensions()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

return Window
