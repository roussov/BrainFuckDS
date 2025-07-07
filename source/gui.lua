-- gui.lua

local Gui = {}

-- Messages empilés (tableau de {text, timer, color})
local messages = {}
local MESSAGE_DURATION_DEFAULT = 180 -- frames (~3s)

-- Initialise l'affichage
function Gui.init()
    if Screen then Screen.init() end
    Gui.clearScreenBottom()
    messages = {}
end

-- Efface l'écran du bas
function Gui.clearScreenBottom()
    if Screen then Screen.clear(Screen.BOTTOM) end
end

-- Dessine un rectangle avec dégradé vertical (simple)
local function drawGradientRect(x, y, w, h, c1, c2)
    for i=0,h-1 do
        local ratio = i / (h-1)
        local r = c1.r * (1 - ratio) + c2.r * ratio
        local g = c1.g * (1 - ratio) + c2.g * ratio
        local b = c1.b * (1 - ratio) + c2.b * ratio
        Screen.fillRect(x, y+i, w, 1, Color.new(r,g,b))
    end
end

-- Dessine une ombre portée (simple)
local function drawShadow(x, y, w, h, shadowColor)
    Screen.fillRect(x+2, y+2, w, h, shadowColor)
end

-- Dessine une touche clavier tactile avec label
-- pressed = true si surbrillance active
function Gui.printKey(x, y, w, h, label, pressed, touchX, touchY, touchStatus)
    local baseColor1 = Color.new(200, 200, 200)
    local baseColor2 = Color.new(150, 150, 150)
    local shadowColor = Color.new(50, 50, 50)

    if pressed then
        baseColor1 = Color.new(100, 180, 250)
        baseColor2 = Color.new(50, 120, 220)
        shadowColor = Color.new(20, 50, 100)
    end

    -- Dessiner ombre portée
    drawShadow(x, y, w, h, shadowColor)

    -- Dessiner rectangle dégradé
    drawGradientRect(x, y, w, h, baseColor1, baseColor2)

    -- Dessiner bordure
    Screen.drawRect(x, y, w, h, Color.new(30, 30, 30))

    -- Centrer texte label
    local textWidth = #label * 8
    local textX = x + math.floor((w - textWidth) / 2)
    local textY = y + math.floor((h - 8) / 2)

    Screen.print(textX, textY, label, Color.new(0, 0, 0))

    -- Gestion du clic tactile
    if touchStatus == 1 and
       touchX >= x and touchX <= x + w and
       touchY >= y and touchY <= y + h then
        return label
    end

    return nil
end

-- Affiche du texte multiligne avec défilement horizontal si trop large
-- x,y position de départ, couleur optionnelle, maxWidth en px, vitesse px/frame
function Gui.printMultiline(x, y, text, color, maxWidth, speed)
    color = color or Color.new(255, 255, 255)
    maxWidth = maxWidth or 256
    speed = speed or 1

    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local time = os.clock() * 60 -- frames approximatives

    for i, line in ipairs(lines) do
        local width = #line * 8
        if width <= maxWidth then
            Screen.print(x, y + (i - 1) * 12, line, color, Screen.BOTTOM)
        else
            local offset = (time * speed) % (width + maxWidth)
            local drawX = x - offset
            Screen.print(drawX, y + (i - 1) * 12, line, color, Screen.BOTTOM)
            Screen.print(drawX + width + 10, y + (i - 1) * 12, line, color, Screen.BOTTOM)
        end
    end
end

-- Ajoute un message empilé avec durée et couleur personnalisée
function Gui.message(text, duration, color)
    duration = duration or MESSAGE_DURATION_DEFAULT
    color = color or Color.new(255, 255, 0)
    table.insert(messages, {text = text, timer = duration, color = color})
end

-- Affiche les messages empilés en bas écran, maxLines messages (par défaut 3)
function Gui.renderMessages(maxLines)
    maxLines = maxLines or 3
    local screenHeight = 192
    local baseY = screenHeight - (maxLines * 12)
    local count = 0

    for i = #messages, 1, -1 do
        local msg = messages[i]
        if msg.timer > 0 then
            Gui.printMultiline(0, baseY + count * 12, msg.text, msg.color)
            count = count + 1
            msg.timer = msg.timer - 1
            if count >= maxLines then
                break
            end
        else
            table.remove(messages, i)
        end
    end
end

-- Affiche une ligne standard alignée à gauche (option couleur)
function Gui.printLineBottom(i, text, color)
    color = color or Color.new(255, 255, 255)
    Screen.print(0, i * 12, text, color, Screen.BOTTOM)
end

-- Affiche barre de statut en bas (option couleur)
function Gui.printStatusBottom(text, color)
    color = color or Color.new(255, 255, 255)
    local screenHeight = 192
    Screen.print(0, screenHeight - 12, text, color, Screen.BOTTOM)
end

-- Mise à jour écran (affiche messages + refresh)
function Gui.sync()
    Gui.renderMessages()
    if Screen then Screen.refresh() end
end

-- Fonction draw pour compatibilité
function Gui.draw()
    Gui.sync()
end

-- Fonction update pour compatibilité
function Gui.update(dt)
    -- Mise à jour des messages
    for i = #messages, 1, -1 do
        local msg = messages[i]
        if msg.timer > 0 then
            msg.timer = msg.timer - 1
        else
            table.remove(messages, i)
        end
    end
end

return Gui
