-- clavier.lua — clavier virtuel tactile pour NDS (simplifié)

local Gui = require("source.gui")
local Keys = require("source.keys")

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
    if not Screen or not Color then return end
    
    local y = startY
    for row = 1, #Clavier.layout[2] do
        local x = startX
        for _, key in ipairs(Clavier.layout[2][row]) do
            local label = key
            if key == ' ' then label = 'SPC' end
            if key == 'ENTR' then label = 'ENT' end
            if key == '<' then label = 'DEL' end
            
            -- Dessiner la touche
            local pressed = (Clavier.pressedKey == key)
            local bgColor = pressed and Color.new(100, 150, 200) or Color.new(80, 80, 90)
            local textColor = Color.new(255, 255, 255)
            
            Screen.fillRect(x, y, keyWidth, keyHeight, bgColor)
            Screen.drawRect(x, y, keyWidth, keyHeight, Color.new(60, 60, 70))
            
            -- Centrer le texte
            local textX = x + (keyWidth - #label * 4) / 2
            local textY = y + (keyHeight - 8) / 2
            Screen.print(textX, textY, label, textColor, Screen.BOTTOM)
            
            x = x + keyWidth + 2
        end
        y = y + keyHeight + 2
    end
end

-- Initialisation du clavier
function Clavier.init()
    Clavier.pressedKey = nil
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
