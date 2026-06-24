local Debug    = {}
local Settings = require "src.settings.settings"
local theme    = require "src.ui.utils.theme"

Debug.flags = {
    debug_fps = nil,
    debug_mem = nil,
    debug_ups = nil,
    debug_playtime = nil,
}

Debug.config = {
    text = {
        size             = 14,
        background_color = {0, 0, 0, 0.10},
    }
}
Debug.font = nil

function Debug.load()
    Debug.font = love.graphics.newFont(theme.font.afacad_extrabold, Debug.config.text.size)
    Debug.flags.debug_fps = Settings.get("debug_fps")
    Debug.flags.debug_mem = Settings.get("debug_mem")
    Debug.flags.debug_ups = Settings.get("debug_ups")
    Debug.flags.debug_playtime = Settings.get("debug_playtime")
end

function Debug.toggle(key)
    if Debug.flags[key] ~= nil then
        Debug.flags[key] = not Debug.flags[key]
        Settings.set(key, Debug.flags[key])
    end
end

function Debug.draw()
    local parts = {}

    if Debug.flags.debug_fps then
        table.insert(parts, math.floor(love.timer.getFPS()) .. "fps")
    end
    if Debug.flags.debug_mem then
        table.insert(parts, math.floor(collectgarbage("count")) .. "KB")
    end
    if Debug.flags.debug_ups then
        -- track this yourself (see below)
        table.insert(parts, Debug.ups .. "ups")
    end
    if Debug.flags.debug_playtime then
        table.insert(parts, math.floor(love.timer.getTime()) .. "s")
    end

    if #parts == 0 then return end

    local text = table.concat(parts, " | ")

    love.graphics.setFont(Debug.font)
    love.graphics.setColor(Debug.config.text.background_color)
    love.graphics.rectangle("fill", 6, 6, love.graphics.getFont():getWidth(text) + 10, 22, 3)
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.print(text, 11, 9)
end

Debug.ups = 0
Debug.ups_timer = 0
Debug.ups_count = 0

function Debug.update(dt)
    Debug.ups_count = Debug.ups_count + 1
    Debug.ups_timer = Debug.ups_timer + dt

    if Debug.ups_timer >= 1 then
        Debug.ups = Debug.ups_count
        Debug.ups_count = 0
        Debug.ups_timer = 0
    end
end

return Debug