-- fs.lua (extrait) — menu tactile de sélection de fichier

local Gui = require("gui")
local Keys = require("keys")
local fat = require("fat")

function Fs.selectFile(dirPath)
    dirPath = dirPath or "sd:/scripts/"
    local files = {}
    local dir = fat.opendir(dirPath)
    if not dir then
        fat.mkdir(dirPath)
        dir = fat.opendir(dirPath)
    end

    while true do
        files = {}
        fat.rewinddir(dir)
        local entry
        while true do
            entry = fat.readdir(dir)
            if not entry then break end
            if entry.name:sub(-3) == ".bf" then
                table.insert(files, entry.name)
            end
        end
        if #files == 0 then
            Gui.message("Aucun fichier .bf trouvé dans scripts/")
            return nil
        end

        local selected = 1

        while true do
            Gui.clearScreenBottom()
            Gui.drawTitle("Choisir fichier BF")
            for i = 1, math.min(#files, 8) do
                local prefix = (i == selected) and ">" or " "
                Gui.printLineBottom(i, prefix .. " " .. files[i])
            end
            Gui.printLineBottom(9, "D-Pad: haut/bas  A: choisir  B: quitter")

            Keys.update()
            if Keys.pressed("UP") then
                selected = selected - 1
                if selected < 1 then selected = #files end
            elseif Keys.pressed("DOWN") then
                selected = selected + 1
                if selected > #files then selected = 1 end
            elseif Keys.pressed("A") then
                fat.closedir(dir)
                return files[selected]
            elseif Keys.pressed("B") then
                fat.closedir(dir)
                return nil
            end
            VBlank.wait()
        end
    end
end
