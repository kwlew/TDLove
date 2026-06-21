local Settings = {}

Settings.default = {
    fps_cap = 999,
    show_debug = true,
    debug_fps = true,
    debug_mem = true,
    debug_ups = true,
    debug_playtime = true,
    volume = 1.0,
    fullscreen = false,
}

Settings._data = {}
local SAVE_FILE = "settings.dat"

local function serialize(data)
    local lines = {}
    for k, v in pairs(data) do
        table.insert(lines, k .. "=" .. tostring(v))
    end
    return table.concat(lines, "\n")
end

local function deserialize(content)
    local data = {}
    for line in content:gmatch("[^\n]+") do
        local k, v = line:match("^(.-)=(.+)$")
        if k then
            if v == "true" then v = true
            elseif v == "false" then v = false
            elseif tonumber(v) then v = tonumber(v)
            end
            data[k] = v
        end
    end
    return data
end

function Settings.load()
    Settings._data = {}
    for k, v in pairs(Settings.default) do
        Settings._data[k] = v
    end

    if love.filesystem.getInfo(SAVE_FILE) then
        local contents = love.filesystem.read(SAVE_FILE)
        local parsed = deserialize(contents)
        for k, v in pairs(parsed) do
            if Settings.default[k] ~= nil then
                Settings._data[k] = v
            end
        end
    end
end

function Settings.save()
    love.filesystem.write(SAVE_FILE, serialize(Settings._data))
end

function Settings.get(key)
    return Settings._data[key]
end

function Settings.set(key, value)
    Settings._data[key] = value
    Settings.save()
end

function Settings.toggle(key)
    Settings.set(key, not Settings._data[key])
end

return Settings
