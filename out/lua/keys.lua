-- keys.lua

local Keys = {}

local PAD = pad -- variable globale libnds/pad
local currentState = {}
local previousState = {}

-- Liste des boutons supportés
Keys.buttons = {
    "A", "B", "X", "Y", "L", "R",
    "START", "SELECT",
    "UP", "DOWN", "LEFT", "RIGHT"
}

-- Initialise les états (à appeler une fois au démarrage)
function Keys.init()
    PAD.init()
    for _, btn in ipairs(Keys.buttons) do
        currentState[btn] = false
        previousState[btn] = false
    end
end

-- Met à jour les états des boutons (à appeler chaque frame)
function Keys.update()
    PAD.scanPads()
    for _, btn in ipairs(Keys.buttons) do
        previousState[btn] = currentState[btn]
        currentState[btn] = PAD.isKeyDown(PAD.KEY[btn])
    end
end

-- Retourne true si le bouton est actuellement pressé
function Keys.pressed(button)
    return currentState[button] or false
end

-- Retourne true si le bouton vient juste d’être pressé (transition off -> on)
function Keys.justPressed(button)
    return currentState[button] and not previousState[button]
end

-- Retourne true si le bouton vient juste d’être relâché (transition on -> off)
function Keys.justReleased(button)
    return not currentState[button] and previousState[button]
end

return Keys
