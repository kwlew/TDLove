local State = {}

State.MAIN_MENU = "main_menu"
State.IN_GAME   = "in_game"
State.SETTINGS  = "settings"

State._current = State.MAIN_MENU

function State.set(name)
    State._current = name
end

function State.get()
    return State._current
end

function State.is(name)
    return State._current == name
end

return State
