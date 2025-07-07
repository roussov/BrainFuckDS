-- editor.lua

local Editor = {}

local Keys = require("source.keys")

-- Contenu sous forme de tableau de lignes
Editor.lines = {""}

-- Position curseur (1-based)
Editor.cursorLine = 1
Editor.cursorCol = 1

-- Scroll vertical (ligne de départ affichée)
Editor.scroll = 1

-- Nombre de lignes affichées dans la zone (ex: écran bas 192px / 12px par ligne = 10 lignes)
Editor.visibleLines = 10

-- Initialisation
function Editor.init()
    -- Initialisation si nécessaire
end

-- Charge un contenu texte (string) dans l’éditeur (split en lignes)
function Editor.load(text)
    Editor.lines = {}
    for line in text:gmatch("([^\n]*)\n?") do
        table.insert(Editor.lines, line)
    end
    if #Editor.lines == 0 then
        Editor.lines = {""}
    end
    Editor.cursorLine = 1
    Editor.cursorCol = 1
    Editor.scroll = 1
end

-- Retourne le contenu complet sous forme de string
function Editor.getContent()
    return table.concat(Editor.lines, "\n")
end

-- Insère un caractère à la position curseur
function Editor.insertChar(char)
    local line = Editor.lines[Editor.cursorLine]
    local before = line:sub(1, Editor.cursorCol - 1)
    local after = line:sub(Editor.cursorCol)
    Editor.lines[Editor.cursorLine] = before .. char .. after
    Editor.cursorCol = Editor.cursorCol + 1
end

-- Supprime caractère avant le curseur (Backspace)
function Editor.deleteChar()
    if Editor.cursorCol > 1 then
        local line = Editor.lines[Editor.cursorLine]
        local before = line:sub(1, Editor.cursorCol - 2)
        local after = line:sub(Editor.cursorCol)
        Editor.lines[Editor.cursorLine] = before .. after
        Editor.cursorCol = Editor.cursorCol - 1
    elseif Editor.cursorLine > 1 then
        -- Fusionne ligne actuelle avec précédente
        local prevLine = Editor.lines[Editor.cursorLine - 1]
        local currLine = Editor.lines[Editor.cursorLine]
        Editor.lines[Editor.cursorLine - 1] = prevLine .. currLine
        table.remove(Editor.lines, Editor.cursorLine)
        Editor.cursorLine = Editor.cursorLine - 1
        Editor.cursorCol = #prevLine + 1
        -- Ajuste scroll si besoin
        if Editor.scroll > Editor.cursorLine then
            Editor.scroll = Editor.cursorLine
        end
    end
end

-- Retour chariot (entree)
function Editor.insertNewline()
    local line = Editor.lines[Editor.cursorLine]
    local before = line:sub(1, Editor.cursorCol - 1)
    local after = line:sub(Editor.cursorCol)
    Editor.lines[Editor.cursorLine] = before
    table.insert(Editor.lines, Editor.cursorLine + 1, after)
    Editor.cursorLine = Editor.cursorLine + 1
    Editor.cursorCol = 1
    -- Scroll si curseur sort de l’écran visible
    if Editor.cursorLine - Editor.scroll >= Editor.visibleLines then
        Editor.scroll = Editor.scroll + 1
    end
end

-- Déplacement curseur
function Editor.moveCursorUp()
    if Editor.cursorLine > 1 then
        Editor.cursorLine = Editor.cursorLine - 1
        local lineLength = #Editor.lines[Editor.cursorLine]
        Editor.cursorCol = math.min(Editor.cursorCol, lineLength + 1)
        if Editor.cursorLine < Editor.scroll then
            Editor.scroll = Editor.scroll - 1
        end
    end
end

function Editor.moveCursorDown()
    if Editor.cursorLine < #Editor.lines then
        Editor.cursorLine = Editor.cursorLine + 1
        local lineLength = #Editor.lines[Editor.cursorLine]
        Editor.cursorCol = math.min(Editor.cursorCol, lineLength + 1)
        if Editor.cursorLine - Editor.scroll >= Editor.visibleLines then
            Editor.scroll = Editor.scroll + 1
        end
    end
end

function Editor.moveCursorLeft()
    if Editor.cursorCol > 1 then
        Editor.cursorCol = Editor.cursorCol - 1
    elseif Editor.cursorLine > 1 then
        Editor.cursorLine = Editor.cursorLine - 1
        Editor.cursorCol = #Editor.lines[Editor.cursorLine] + 1
        if Editor.cursorLine < Editor.scroll then
            Editor.scroll = Editor.scroll - 1
        end
    end
end

function Editor.moveCursorRight()
    local lineLength = #Editor.lines[Editor.cursorLine]
    if Editor.cursorCol <= lineLength then
        Editor.cursorCol = Editor.cursorCol + 1
    elseif Editor.cursorLine < #Editor.lines then
        Editor.cursorLine = Editor.cursorLine + 1
        Editor.cursorCol = 1
        if Editor.cursorLine - Editor.scroll >= Editor.visibleLines then
            Editor.scroll = Editor.scroll + 1
        end
    end
end

-- Rendu écran bas (affiche les lignes visibles + curseur)
function Editor.render()
    if not Screen or not Color then return end
    
    local startLine = Editor.scroll
    local endLine = math.min(startLine + Editor.visibleLines - 1, #Editor.lines)

    -- Afficher les lignes de code
    for i = startLine, endLine do
        local y = 20 + (i - startLine) * 12  -- Décalage pour laisser place aux contrôles
        local lineText = Editor.lines[i] or ""
        
        -- Numéro de ligne
        Screen.print(0, y, string.format("%2d:", i), Color.new(120, 120, 120), Screen.BOTTOM)
        
        -- Contenu de la ligne avec coloration syntaxique simple
        Editor.renderLineWithSyntax(24, y, lineText)
    end

    -- Affiche curseur sous forme d'un petit rectangle clignotant
    if (os.clock() * 2) % 2 < 1 then  -- Clignotement
        local cursorX = 24 + (Editor.cursorCol - 1) * 6
        local cursorY = 20 + (Editor.cursorLine - startLine) * 12
        if cursorY >= 20 and cursorY < 20 + Editor.visibleLines * 12 then
            Screen.fillRect(cursorX, cursorY, 2, 12, Color.new(255, 255, 0))
        end
    end
end

-- Rendu d'une ligne avec coloration syntaxique Brainfuck
function Editor.renderLineWithSyntax(x, y, text)
    if not Screen or not Color then return end
    
    local colors = {
        ['>'] = Color.new(255, 100, 100),  -- Rouge pour >
        ['<'] = Color.new(255, 100, 100),  -- Rouge pour <
        ['+'] = Color.new(100, 255, 100), -- Vert pour +
        ['-'] = Color.new(100, 255, 100), -- Vert pour -
        ['.'] = Color.new(100, 100, 255), -- Bleu pour .
        [','] = Color.new(100, 100, 255), -- Bleu pour ,
        ['['] = Color.new(255, 255, 100), -- Jaune pour [
        [']'] = Color.new(255, 255, 100), -- Jaune pour ]
    }
    
    for i = 1, #text do
        local char = text:sub(i, i)
        local color = colors[char] or Color.new(200, 200, 200)
        Screen.print(x + (i-1) * 6, y, char, color, Screen.BOTTOM)
    end
end

-- Mise à jour par frame : gestion des déplacements clavier
function Editor.update()
    if Keys.justPressed("UP") then Editor.moveCursorUp() end
    if Keys.justPressed("DOWN") then Editor.moveCursorDown() end
    if Keys.justPressed("LEFT") then Editor.moveCursorLeft() end
    if Keys.justPressed("RIGHT") then Editor.moveCursorRight() end

    -- Retour chariot avec bouton B (exemple)
    if Keys.justPressed("B") then Editor.insertNewline() end

    -- Suppression avec bouton X (exemple)
    if Keys.justPressed("X") then Editor.deleteChar() end

    -- Quitter avec START (exemple)
    if Keys.justPressed("START") then
        return "exit"
    end

    return nil
end

return Editor
