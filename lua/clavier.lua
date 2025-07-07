-- clavier.lua — clavier virtuel tactile pour NDS (simplifié)

local Gui = require("gui")
local Keys = require("keys")

local Clavier = {}

-- Disposition AZERTY par défaut (modifiable)
Clavier.layout = {
    "AZERTY", 
    {
        {'a','z','e','r','t','y','u','i','o','p'},
        {'q','s','d','f','g','h','j','k','l','m'},
        {'w','x','c','v','b','n','<',' ','.','ENTR'},
    }
}

-- Taille touches (en pixels)
local keyWidth, keyHeight = 22, 20
local startX, startY = 8, 130

-- Stockage état touche pressée
Clavier.pressedKey = nil

-- Dessine le clavier sur écran bas
function Clavier.draw()
    Gui.clearScreenBottom()
    local y = startY
    for row=1,#Clavier.layout[2] do
        local x = startX
        for _, key in ipairs(Clavier.layout[2][row]) do
            local label = key
            if key == ' ' then label = '␣' end
            Gui.printKey(x, y, keyWidth, keyHeight, label, (Clavier.pressedKey == key))
            x = x + keyWidth + 4
        end
        y = y + keyHeight + 4
    end
end

-- Vérifie si touche tactile pressée (coordonnées x,y)
function Clavier.checkTouch(tx, ty)
    local y = startY
    for row=1,#Clavier.layout[2] do
        local x = startX
        for _, key in ipairs(Clavier.layout[2][row]) do
            if tx >= x and tx <= x + keyWidth and ty >= y and ty <= y + keyHeight then
                Clavier.pressedKey = key
                return key
            end
            x = x + keyWidth + 4
        end
        y = y + keyHeight + 4
    end
    Clavier.pressedKey = nil
    return nil
end

-- Doit être appelé dans la boucle principale pour gérer le tactile
function Clavier.update(touch)
    if touch.status == "pressed" or touch.status == "hold" then
        local key = Clavier.checkTouch(touch.x, touch.y)
        if key then
            return key
        end
    end
    Clavier.pressedKey = nil
    return nil
end

return Clavier
