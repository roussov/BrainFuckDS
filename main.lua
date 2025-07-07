-- main.lua - Point d'entrée principal pour Brainfuck DS
-- Compatible avec DSLua/MicroLua pour Nintendo DS

local bf_interpreter = require("source.bf_interpreter")
local interpreteur = require("source.interpréteur")
local editor = require("source.editor")
local clavier = require("source.clavier")
local gui = require("source.gui")
local fs = require("source.fs")
local utils = require("source.utils")
local keys = require("source.keys")

-- État global de l'application
local app = {
    mode = "splash",  -- "splash", "editor", "run", "debug", "menu"
    theme = nil,
    interpreter = nil,
    running = false,
    bf_code = "",
    output_buffer = {},
    input_buffer = "",
    mem_state = {},
    config_path = "fat:/config.cfg",
    
    -- Splash screen
    splash = {
        timer = 0,
        duration = 180,  -- 3 secondes (60 FPS)
        alpha = 0
    },
    
    -- Interface
    ui = {
        show_memory = true,
        show_output = true,
        cursor_blink = 0,
        status_message = "",
        status_timer = 0
    }
}

-- Charge la configuration depuis le fichier
local function load_config()
    local config = {
        theme = "default",
        code = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.",
        last_file = "",
        settings = {
            auto_save = true,
            show_line_numbers = true,
            syntax_highlight = true
        }
    }
    
    -- Tenter de charger depuis le fichier
    local f = io.open(app.config_path, "r")
    if f then
        local content = f:read("*all")
        f:close()
        
        -- Évaluer le contenu Lua de manière sécurisée
        local chunk, err = loadstring("return " .. content)
        if chunk then
            local success, loaded_config = pcall(chunk)
            if success and type(loaded_config) == "table" then
                for k, v in pairs(loaded_config) do
                    config[k] = v
                end
            end
        end
    end
    
    return config
end

-- Sauvegarde la configuration
local function save_config()
    local config = {
        theme = app.theme.name or "default",
        code = app.bf_code,
        settings = {
            auto_save = true,
            show_line_numbers = true,
            syntax_highlight = true
        }
    }
    
    local f = io.open(app.config_path, "w")
    if f then
        f:write("{\n")
        f:write(string.format("  theme = %q,\n", config.theme))
        f:write("  code = [[\n" .. config.code .. "\n]],\n")
        f:write("  settings = {\n")
        f:write("    auto_save = " .. tostring(config.settings.auto_save) .. ",\n")
        f:write("    show_line_numbers = " .. tostring(config.settings.show_line_numbers) .. ",\n")
        f:write("    syntax_highlight = " .. tostring(config.settings.syntax_highlight) .. "\n")
        f:write("  }\n")
        f:write("}\n")
        f:close()
    end
end

-- Initialisation de l'application
local function init()
    -- Initialiser les systèmes NDS
    if Screen then Screen.init() end
    keys.init()
    
    -- Charger la configuration
    local config = load_config()
    
    -- Charger le thème
    app.theme = require("themes." .. (config.theme or "default"))
    
    -- Initialiser les modules
    gui.init()
    editor.load(config.code or "")
    
    -- Créer l'interpréteur
    app.interpreter = bf_interpreter.new()
    app.bf_code = config.code or ""
    
    -- Configurer les callbacks de l'interpréteur
    app.interpreter.onOutput = function(char)
        table.insert(app.output_buffer, char)
    end
    
    app.interpreter.onInputRequest = function()
        if #app.input_buffer > 0 then
            local char = app.input_buffer:sub(1, 1)
            app.input_buffer = app.input_buffer:sub(2)
            return char
        end
        return nil
    end
    
    app.mode = "splash"
end

-- Mise à jour du splash screen
local function update_splash()
    app.splash.timer = app.splash.timer + 1
    
    if app.splash.timer < 60 then
        -- Fade in
        app.splash.alpha = app.splash.timer / 60
    elseif app.splash.timer < app.splash.duration - 60 then
        -- Affichage complet
        app.splash.alpha = 1.0
    elseif app.splash.timer < app.splash.duration then
        -- Fade out
        app.splash.alpha = (app.splash.duration - app.splash.timer) / 60
    else
        -- Fin du splash
        app.mode = "editor"
        app.running = true
    end
end

-- Mise à jour principale
local function update()
    keys.update()
    
    if app.mode == "splash" then
        update_splash()
        
    elseif app.mode == "editor" then
        -- Mise à jour de l'éditeur
        local result = editor.update()
        if result == "exit" then
            save_config()
            return false  -- Quitter l'application
        end
        
        -- Synchroniser le code
        app.bf_code = editor.getContent()
        
        -- Gestion des touches spéciales
        if keys.justPressed("START") then
            app.mode = "run"
            app.interpreter:load(app.bf_code)
            app.output_buffer = {}
            app.ui.status_message = "Exécution en cours..."
            app.ui.status_timer = 60
        elseif keys.justPressed("SELECT") then
            app.mode = "menu"
        end
        
        -- Gestion du clavier tactile
        local touch = stylus and stylus.read() or {status = 0, x = 0, y = 0}
        if touch.status > 0 then
            local key = clavier.checkTouch(touch.x, touch.y)
            if key then
                if key == "ENTR" then
                    editor.insertNewline()
                elseif key == "<" then
                    editor.deleteChar()
                elseif key == " " then
                    editor.insertChar(" ")
                else
                    editor.insertChar(key)
                end
            end
        end
        
    elseif app.mode == "run" then
        -- Exécution du programme
        if app.interpreter:isRunning() then
            -- Exécuter quelques étapes par frame pour éviter les blocages
            for i = 1, 50 do
                if app.interpreter:isRunning() then
                    app.interpreter:step()
                else
                    break
                end
            end
        else
            -- Fin d'exécution
            app.ui.status_message = "Exécution terminée - Sortie: " .. table.concat(app.output_buffer)
            app.ui.status_timer = 300  -- 5 secondes
        end
        
        -- Retour à l'éditeur
        if keys.justPressed("B") or keys.justPressed("START") then
            app.mode = "editor"
        end
        
    elseif app.mode == "menu" then
        -- Menu principal (à implémenter)
        if keys.justPressed("B") or keys.justPressed("SELECT") then
            app.mode = "editor"
        end
    end
    
    -- Mise à jour des timers UI
    if app.ui.status_timer > 0 then
        app.ui.status_timer = app.ui.status_timer - 1
        if app.ui.status_timer == 0 then
            app.ui.status_message = ""
        end
    end
    
    app.ui.cursor_blink = (app.ui.cursor_blink + 1) % 60
    
    return true
end

-- Rendu principal
local function draw()
    -- Effacer les écrans
    if Screen then
        Screen.clear(Screen.TOP)
        Screen.clear(Screen.BOTTOM)
    end
    
    if app.mode == "splash" then
        -- Afficher le splash screen
        if Screen and Color then
            local alpha = math.floor(app.splash.alpha * 255)
            Screen.print(64, 80, "BRAINFUCK DS", Color.new(255, 255, 255), Screen.TOP)
            Screen.print(48, 100, "Editeur & Interpreteur", Color.new(200, 200, 200), Screen.TOP)
            Screen.print(72, 120, "v1.0", Color.new(150, 150, 150), Screen.TOP)
        end
        
    elseif app.mode == "editor" then
        -- Écran du haut : informations et mémoire
        if Screen and Color then
            Screen.print(0, 0, "=== BRAINFUCK DS EDITOR ===", Color.new(255, 255, 0), Screen.TOP)
            Screen.print(0, 20, "Code: " .. #app.bf_code .. " caracteres", Color.new(255, 255, 255), Screen.TOP)
            
            -- Afficher un aperçu de la mémoire si disponible
            if app.interpreter and app.interpreter.tape then
                Screen.print(0, 40, "Memoire:", Color.new(200, 200, 200), Screen.TOP)
                local mem_str = ""
                for i = 1, math.min(8, app.interpreter.ptr or 1) do
                    local val = app.interpreter.tape[i] or 0
                    mem_str = mem_str .. string.format("[%d]", val)
                end
                if #mem_str > 0 then
                    Screen.print(0, 60, mem_str, Color.new(150, 255, 150), Screen.TOP)
                end
                Screen.print(0, 80, "Ptr: " .. (app.interpreter.ptr or 1), Color.new(255, 200, 100), Screen.TOP)
            end
            
            -- Afficher la sortie si disponible
            if #app.output_buffer > 0 then
                Screen.print(0, 100, "Sortie:", Color.new(200, 200, 200), Screen.TOP)
                local output = table.concat(app.output_buffer):sub(1, 20)  -- Limiter à 20 chars
                Screen.print(0, 120, '"' .. output .. '"', Color.new(100, 255, 255), Screen.TOP)
            end
            
            -- Message de statut
            if app.ui.status_message ~= "" then
                Screen.print(0, 160, app.ui.status_message, Color.new(255, 255, 100), Screen.TOP)
            end
        end
        
        -- Écran du bas : éditeur + clavier
        editor.render()
        clavier.draw()
        
        -- Afficher les contrôles
        if Screen and Color then
            Screen.print(0, 0, "START:Exec SELECT:Menu", Color.new(180, 180, 180), Screen.BOTTOM)
        end
        
    elseif app.mode == "run" then
        -- Mode exécution
        if Screen and Color then
            Screen.print(0, 0, "=== EXECUTION ===", Color.new(255, 100, 100), Screen.TOP)
            Screen.print(0, 20, "PC: " .. (app.interpreter.pc or 1), Color.new(255, 255, 255), Screen.TOP)
            Screen.print(0, 40, "Ptr: " .. (app.interpreter.ptr or 1), Color.new(255, 255, 255), Screen.TOP)
            Screen.print(0, 60, "Val: " .. (app.interpreter.tape[app.interpreter.ptr] or 0), Color.new(255, 255, 255), Screen.TOP)
            
            -- Afficher la sortie
            Screen.print(0, 100, "Sortie:", Color.new(200, 200, 200), Screen.TOP)
            local output = table.concat(app.output_buffer)
            if #output > 0 then
                -- Afficher ligne par ligne
                local lines = {}
                local current_line = ""
                for i = 1, #output do
                    local c = output:sub(i, i)
                    if c == "\n" then
                        table.insert(lines, current_line)
                        current_line = ""
                    else
                        current_line = current_line .. c
                    end
                end
                if current_line ~= "" then
                    table.insert(lines, current_line)
                end
                
                for i, line in ipairs(lines) do
                    if i <= 3 then  -- Max 3 lignes
                        Screen.print(0, 120 + (i-1)*15, line:sub(1, 30), Color.new(100, 255, 255), Screen.TOP)
                    end
                end
            end
            
            Screen.print(0, 170, "B/START: Retour", Color.new(180, 180, 180), Screen.TOP)
        end
    end
    
    -- Rafraîchir l'affichage
    if Screen then
        Screen.refresh()
    end
end

-- Boucle principale
local function main_loop()
    init()
    
    while true do
        if not update() then
            break
        end
        draw()
        
        -- Attendre la VBlank (60 FPS)
        if VBlank then
            VBlank.wait()
        end
    end
    
    save_config()
end

-- Point d'entrée
main_loop()
