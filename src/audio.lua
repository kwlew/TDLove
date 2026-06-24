local Settings = require "src.settings.settings"

local Audio = {}

function Audio.load()
    -- stub: preload sounds here when assets exist
end

function Audio.play(id)
    -- stub
end

function Audio.sync()
    love.audio.setVolume(Settings.get("volume"))
    -- music_volume and sfx_volume will route to separate sources when assets exist
end

return Audio
