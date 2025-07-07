-- build.lua
-- Script de build pour Brainfuck DS

local build = {}

-- Configuration du build
local config = {
    project_name = "brainfuck",
    version = "1.0.0",
    author = "Brainfuck DS Team",
    
    -- Répertoires
    source_dir = "source",
    data_dir = "data",
    gfx_dir = "gfx",
    themes_dir = "themes",
    examples_dir = "examples",
    build_dir = "build",
    out_dir = "out",
    
    -- Fichiers
    main_file = "main.lua",
    rom_name = "brainfuck.nds",
    
    -- Outils
    ndstool = "ndstool",
    love_nds = "love.nds",
    
    -- Options de fallback
    create_portable = true,
    skip_nds_tools = false,
    
    -- Options
    compress = true,
    optimize = true,
    debug = false
}

-- Utilitaires
local function log(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] %s: %s", timestamp, level, message))
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function create_directory(path)
    os.execute("mkdir -p " .. path)
end

local function copy_file(src, dest)
    local cmd = string.format("cp %s %s", src, dest)
    log("Exécution de la commande: " .. cmd, "DEBUG")
    local result = os.execute(cmd)
    log("Résultat de la commande: " .. tostring(result), "DEBUG")
    -- Sur macOS, os.execute peut retourner true au lieu de 0
    return result == 0 or result == true
end

local function copy_directory(src, dest)
    local cmd = string.format("cp -r %s %s", src, dest)
    log("Exécution de la commande: " .. cmd, "DEBUG")
    local result = os.execute(cmd)
    log("Résultat de la commande: " .. tostring(result), "DEBUG")
    -- Sur macOS, os.execute peut retourner true au lieu de 0
    return result == 0 or result == true
end

-- Validation des prérequis
function build.check_prerequisites()
    log("Vérification des prérequis...")
    
    local required_files = {
        config.main_file,
        config.source_dir
    }
    
    -- Fichiers optionnels pour NDS
    local optional_files = {
        config.gfx_dir .. "/splash.png",
        config.gfx_dir .. "/icon.bmp"
    }
    
    for _, file in ipairs(required_files) do
        if not file_exists(file) then
            log("Fichier manquant: " .. file, "ERROR")
            return false
        end
    end
    
    -- Vérifier les fichiers optionnels
    for _, file in ipairs(optional_files) do
        if not file_exists(file) then
            log("Fichier optionnel manquant: " .. file, "WARN")
        end
    end
    
    -- Vérifier les outils NDS
    if os.execute("which " .. config.ndstool .. " > /dev/null 2>&1") ~= 0 then
        log("ndstool non trouvé dans le PATH", "WARN")
        config.skip_nds_tools = true
        log("Mode portable activé (sans outils NDS)", "INFO")
    end
    
    if not file_exists(config.love_nds) then
        log("Fichier " .. config.love_nds .. " non trouvé", "WARN")
        config.skip_nds_tools = true
        log("Mode portable activé (sans Love2D NDS)", "INFO")
    end
    
    log("Prérequis validés ✓")
    return true
end

-- Nettoyage
function build.clean()
    log("Nettoyage des fichiers de build...")
    os.execute("rm -rf " .. config.out_dir)
    os.execute("rm -f *.nds")
    log("Nettoyage terminé ✓")
    return true
end

-- Préparation des sources
function build.prepare_sources()
    log("Préparation des sources...")
    
    -- Créer les répertoires de sortie
    log("Création du répertoire: " .. config.out_dir)
    create_directory(config.out_dir)
    
    log("Création du répertoire: " .. config.out_dir .. "/lua")
    create_directory(config.out_dir .. "/lua")
    
    log("Création du répertoire: " .. config.out_dir .. "/data")
    create_directory(config.out_dir .. "/data")
    
    -- Copier le fichier principal
    log("Copie de " .. config.main_file .. " vers " .. config.out_dir .. "/lua/")
    if not copy_file(config.main_file, config.out_dir .. "/lua/") then
        log("Erreur lors de la copie de " .. config.main_file, "ERROR")
        return false
    end
    log("Fichier principal copié ✓")
    
    -- Copier les sources
    log("Copie du répertoire " .. config.source_dir .. " vers " .. config.out_dir .. "/lua/")
    if not copy_directory(config.source_dir, config.out_dir .. "/lua/") then
        log("Erreur lors de la copie des sources", "ERROR")
        return false
    end
    log("Sources copiées ✓")
    
    -- Copier les thèmes
    if file_exists(config.themes_dir) then
        log("Copie du répertoire " .. config.themes_dir)
        copy_directory(config.themes_dir, config.out_dir .. "/lua/")
        log("Thèmes copiés ✓")
    else
        log("Répertoire themes non trouvé, ignoré", "WARN")
    end
    
    -- Copier les données
    if file_exists(config.data_dir) then
        log("Copie du répertoire " .. config.data_dir)
        copy_directory(config.data_dir, config.out_dir .. "/data/")
        log("Données copiées ✓")
    else
        log("Répertoire data non trouvé, ignoré", "WARN")
    end
    
    -- Copier les exemples
    if file_exists(config.examples_dir) then
        log("Copie du répertoire " .. config.examples_dir)
        copy_directory(config.examples_dir, config.out_dir .. "/data/")
        log("Exemples copiés ✓")
    else
        log("Répertoire examples non trouvé, ignoré", "WARN")
    end
    
    log("Sources préparées ✓")
    return true
end

-- Optimisation du code Lua
function build.optimize_lua()
    if not config.optimize or config.skip_nds_tools then
        log("Optimisation désactivée (mode portable)")
        return true
    end
    
    log("Optimisation du code Lua...")
    
    -- Supprimer les commentaires et espaces inutiles
    local function optimize_file(filepath)
        local f = io.open(filepath, "r")
        if not f then return false end
        
        local content = f:read("*all")
        f:close()
        
        -- Supprimer les commentaires de ligne
        content = content:gsub("%-%-[^\n]*\n", "\n")
        
        -- Supprimer les espaces multiples
        content = content:gsub("  +", " ")
        
        -- Supprimer les lignes vides multiples
        content = content:gsub("\n\n+", "\n\n")
        
        f = io.open(filepath, "w")
        if f then
            f:write(content)
            f:close()
            return true
        end
        return false
    end
    
    -- Optimiser tous les fichiers .lua
    local lua_files = {
        config.out_dir .. "/lua/" .. config.main_file
    }
    
    -- Ajouter les fichiers source
    local source_files = {
        "bf_interpreter.lua", "editor.lua", "clavier.lua",
        "gui.lua", "fs.lua", "utils.lua", "keys.lua", "interpréteur.lua"
    }
    
    for _, file in ipairs(source_files) do
        table.insert(lua_files, config.out_dir .. "/lua/source/" .. file)
    end
    
    for _, file in ipairs(lua_files) do
        if file_exists(file) then
            optimize_file(file)
        end
    end
    
    log("Optimisation terminée ✓")
    return true
end

-- Génération des métadonnées
function build.generate_metadata()
    log("Génération des métadonnées...")
    
    local metadata = {
        name = config.project_name,
        version = config.version,
        author = config.author,
        build_date = os.date("%Y-%m-%d %H:%M:%S"),
        build_number = os.time(),
        lua_files = {},
        data_files = {}
    }
    
    -- Sauvegarder les métadonnées
    local f = io.open(config.out_dir .. "/metadata.lua", "w")
    if f then
        f:write("return {\n")
        for k, v in pairs(metadata) do
            if type(v) == "string" then
                f:write(string.format("  %s = %q,\n", k, v))
            elseif type(v) == "number" then
                f:write(string.format("  %s = %d,\n", k, v))
            end
        end
        f:write("}\n")
        f:close()
    end
    
    log("Métadonnées générées ✓")
    return true
end

-- Construction portable (sans outils NDS)
function build.build_portable()
    log("Construction du build portable...")
    
    -- Créer un fichier de lancement
    local launcher_content = [[
#!/usr/bin/env lua
-- Lanceur pour Brainfuck DS (version portable)

-- Ajouter le répertoire lua au path
package.path = package.path .. ";./lua/?.lua;./lua/source/?.lua"

-- Charger le programme principal
require("main")
]]
    
    local f = io.open(config.out_dir .. "/run.lua", "w")
    if f then
        f:write(launcher_content)
        f:close()
        os.execute("chmod +x " .. config.out_dir .. "/run.lua")
    end
    
    -- Créer un script de lancement shell
    local shell_launcher = [[
#!/bin/bash
# Lanceur shell pour Brainfuck DS
cd "$(dirname "$0")"
lua run.lua "$@"
]]
    
    f = io.open(config.out_dir .. "/run.sh", "w")
    if f then
        f:write(shell_launcher)
        f:close()
        os.execute("chmod +x " .. config.out_dir .. "/run.sh")
    end
    
    -- Créer un README pour le build portable
    local readme_content = [[
# Brainfuck DS - Build Portable

Ce build portable peut être exécuté sans les outils Nintendo DS.

## Utilisation

### Avec Lua directement :
```bash
lua run.lua
```

### Avec le script shell :
```bash
./run.sh
```

## Structure
- lua/ : Code source Lua
- data/ : Données et exemples
- run.lua : Lanceur Lua
- run.sh : Lanceur shell

## Note
Ce build est destiné au développement et aux tests.
Pour créer une vraie ROM NDS, installez les outils devkitPro.
]]
    
    f = io.open(config.out_dir .. "/README_PORTABLE.md", "w")
    if f then
        f:write(readme_content)
        f:close()
    end
    
    log("Build portable créé avec succès ✓")
    log("Utilisez: cd " .. config.out_dir .. " && lua run.lua")
    return true
end

-- Construction de la ROM
function build.build_rom()
    if config.skip_nds_tools then
        return build.build_portable()
    end
    
    log("Construction de la ROM NDS...")
    
    -- Vérifier que Love2D NDS est disponible
    if not file_exists(config.love_nds) then
        log("Fichier " .. config.love_nds .. " non trouvé", "ERROR")
        log("Téléchargez Love2D pour NDS depuis: https://github.com/TurtleP/LovePotion", "INFO")
        return false
    end
    
    -- Copier le binaire Love2D
    if not copy_file(config.love_nds, config.out_dir .. "/boot.nds") then
        log("Erreur lors de la copie de " .. config.love_nds, "ERROR")
        return false
    end
    
    -- Construire la commande ndstool
    local cmd = string.format(
        "%s -c %s -7 %s/boot.nds -d %s/lua",
        config.ndstool,
        config.rom_name,
        config.out_dir,
        config.out_dir
    )
    
    -- Ajouter l'icône si disponible
    if file_exists(config.gfx_dir .. "/icon.bmp") then
        cmd = cmd .. " -b " .. config.gfx_dir .. "/icon.bmp"
    end
    
    -- Exécuter la construction
    log("Commande: " .. cmd)
    local result = os.execute(cmd)
    
    if result == 0 then
        log("ROM construite avec succès: " .. config.rom_name .. " ✓")
        
        -- Afficher la taille du fichier
        local f = io.open(config.rom_name, "r")
        if f then
            local size = f:seek("end")
            f:close()
            log(string.format("Taille de la ROM: %.2f KB", size / 1024))
        end
        
        return true
    else
        log("Erreur lors de la construction de la ROM", "ERROR")
        return false
    end
end

-- Build complet
function build.full_build()
    log("=== DÉBUT DU BUILD BRAINFUCK DS ===")
    log("Version: " .. config.version)
    
    local start_time = os.time()
    
    -- Étapes du build
    local steps = {
        {"Vérification des prérequis", build.check_prerequisites},
        {"Nettoyage", build.clean},
        {"Préparation des sources", build.prepare_sources},
        {"Optimisation", build.optimize_lua},
        {"Génération des métadonnées", build.generate_metadata},
        {"Construction de la ROM", build.build_rom}
    }
    
    for i, step in ipairs(steps) do
        log(string.format("Étape %d/%d: %s", i, #steps, step[1]))
        local success, err = pcall(step[2])
        if not success then
            log("Erreur lors de l'exécution: " .. tostring(err), "ERROR")
            log("BUILD ÉCHOUÉ ❌", "ERROR")
            return false
        elseif not err then
            log("Étape échouée: " .. step[1], "ERROR")
            log("BUILD ÉCHOUÉ ❌", "ERROR")
            return false
        end
    end
    
    local build_time = os.time() - start_time
    log(string.format("BUILD RÉUSSI ✅ (durée: %ds)", build_time))
    log("=== FIN DU BUILD ===")
    
    return true
end

-- Build de développement (sans optimisations)
function build.dev_build()
    config.optimize = false
    config.debug = true
    log("Mode développement activé")
    return build.full_build()
end

-- Build de release (avec toutes les optimisations)
function build.release_build()
    config.optimize = true
    config.debug = false
    log("Mode release activé")
    return build.full_build()
end

-- Interface en ligne de commande
function build.main(args)
    args = args or {}
    local command = args[1] or "build"
    
    if command == "clean" then
        build.clean()
    elseif command == "dev" then
        build.dev_build()
    elseif command == "release" then
        build.release_build()
    elseif command == "check" then
        build.check_prerequisites()
    else
        build.full_build()
    end
end

-- Exécution si appelé directement
if arg and arg[0] and arg[0]:match("build%.lua$") then
    build.main(arg)
end

return build
