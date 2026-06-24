local State = {}

State.MAIN_MENU = "main_menu"
State.IN_GAME   = "in_game"
State.SETTINGS  = "settings"
State.PAUSED    = "paused"

State._current       = State.MAIN_MENU
State._settings_back = State.MAIN_MENU   -- where Back returns to from settings

function State.set(name)
    State._current = name
end

-- Open settings and remember which screen to return to on Back/Escape.
function State.goSettings(caller)
    State._settings_back = caller or State.MAIN_MENU
    State.set(State.SETTINGS)
end

function State.get()
    return State._current
end

function State.is(name)
    return State._current == name
end

return State
