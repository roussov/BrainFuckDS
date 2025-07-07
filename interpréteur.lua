-- interpréteur.lua
-- Interface française pour l'interpréteur Brainfuck

local bf_interpreter = require("source.bf_interpreter")
local utils = require("source.utils")

local Interpreteur = {}

-- Crée une nouvelle instance d'interpréteur
function Interpreteur.nouveau()
    return bf_interpreter.new()
end

-- Messages d'erreur en français
local messages_erreur = {
    ["Memory overflow"] = "Dépassement de mémoire",
    ["Memory underflow"] = "Pointeur mémoire négatif",
    ["Unmatched bracket"] = "Crochets non appariés",
    ["Syntax error"] = "Erreur de syntaxe",
    ["Runtime error"] = "Erreur d'exécution"
}

-- Traduit les messages d'erreur
function Interpreteur.traduire_erreur(message)
    for anglais, francais in pairs(messages_erreur) do
        if string.find(message, anglais) then
            return string.gsub(message, anglais, francais)
        end
    end
    return message
end

-- Valide le code Brainfuck
function Interpreteur.valider_code(code)
    local pile_crochets = {}
    local erreurs = {}
    
    for i = 1, #code do
        local c = code:sub(i, i)
        if c == '[' then
            table.insert(pile_crochets, i)
        elseif c == ']' then
            if #pile_crochets == 0 then
                table.insert(erreurs, {
                    position = i,
                    message = "']' sans '[' correspondant"
                })
            else
                table.remove(pile_crochets)
            end
        end
    end
    
    -- Vérifier les crochets ouverts non fermés
    for _, pos in ipairs(pile_crochets) do
        table.insert(erreurs, {
            position = pos,
            message = "'[' sans ']' correspondant"
        })
    end
    
    return #erreurs == 0, erreurs
end

-- Analyse le code et retourne des statistiques
function Interpreteur.analyser_code(code)
    local stats = {
        longueur = #code,
        instructions = {
            pointeur_droite = 0,  -- >
            pointeur_gauche = 0,  -- <
            increment = 0,        -- +
            decrement = 0,        -- -
            sortie = 0,          -- .
            entree = 0,          -- ,
            boucle_debut = 0,    -- [
            boucle_fin = 0,      -- ]
            commentaires = 0     -- autres
        },
        complexite_boucles = 0
    }
    
    local niveau_boucle = 0
    
    for i = 1, #code do
        local c = code:sub(i, i)
        if c == '>' then
            stats.instructions.pointeur_droite = stats.instructions.pointeur_droite + 1
        elseif c == '<' then
            stats.instructions.pointeur_gauche = stats.instructions.pointeur_gauche + 1
        elseif c == '+' then
            stats.instructions.increment = stats.instructions.increment + 1
        elseif c == '-' then
            stats.instructions.decrement = stats.instructions.decrement + 1
        elseif c == '.' then
            stats.instructions.sortie = stats.instructions.sortie + 1
        elseif c == ',' then
            stats.instructions.entree = stats.instructions.entree + 1
        elseif c == '[' then
            stats.instructions.boucle_debut = stats.instructions.boucle_debut + 1
            niveau_boucle = niveau_boucle + 1
            stats.complexite_boucles = math.max(stats.complexite_boucles, niveau_boucle)
        elseif c == ']' then
            stats.instructions.boucle_fin = stats.instructions.boucle_fin + 1
            niveau_boucle = niveau_boucle - 1
        else
            stats.instructions.commentaires = stats.instructions.commentaires + 1
        end
    end
    
    return stats
end

-- Optimise le code Brainfuck (optimisations simples)
function Interpreteur.optimiser_code(code)
    local optimise = code
    
    -- Supprime les commentaires (caractères non-BF)
    optimise = string.gsub(optimise, "[^%+%-<>%[%]%.,]", "")
    
    -- Optimise les séquences répétitives
    -- +++++ -> +{5}
    optimise = string.gsub(optimise, "%+%+%+%+%+", "+{5}")
    optimise = string.gsub(optimise, "%-%-%-%-%-", "-{5}")
    optimise = string.gsub(optimise, ">>>>>", ">{5}")
    optimise = string.gsub(optimise, "<<<<<", "<{5}")
    
    -- Supprime les opérations qui s'annulent
    optimise = string.gsub(optimise, "%+%-", "")
    optimise = string.gsub(optimise, "%-%+", "")
    optimise = string.gsub(optimise, "><", "")
    optimise = string.gsub(optimise, "<>", "")
    
    return optimise
end

-- Formate le code avec indentation
function Interpreteur.formater_code(code)
    local formate = ""
    local indentation = 0
    local ligne_courante = ""
    
    for i = 1, #code do
        local c = code:sub(i, i)
        
        if c == '[' then
            ligne_courante = ligne_courante .. c
            formate = formate .. string.rep("  ", indentation) .. ligne_courante .. "\n"
            indentation = indentation + 1
            ligne_courante = ""
        elseif c == ']' then
            if ligne_courante ~= "" then
                formate = formate .. string.rep("  ", indentation) .. ligne_courante .. "\n"
                ligne_courante = ""
            end
            indentation = math.max(0, indentation - 1)
            formate = formate .. string.rep("  ", indentation) .. c .. "\n"
        else
            ligne_courante = ligne_courante .. c
            if #ligne_courante >= 40 then -- Limite de ligne
                formate = formate .. string.rep("  ", indentation) .. ligne_courante .. "\n"
                ligne_courante = ""
            end
        end
    end
    
    if ligne_courante ~= "" then
        formate = formate .. string.rep("  ", indentation) .. ligne_courante .. "\n"
    end
    
    return formate
end

-- Génère un rapport d'exécution
function Interpreteur.generer_rapport(interpreteur, stats)
    local rapport = {
        "=== RAPPORT D'EXÉCUTION BRAINFUCK ===",
        "",
        "Code:",
        "  Longueur: " .. stats.longueur .. " caractères",
        "  Instructions valides: " .. (stats.longueur - stats.instructions.commentaires),
        "  Commentaires: " .. stats.instructions.commentaires,
        "",
        "Instructions:",
        "  Déplacements pointeur: " .. (stats.instructions.pointeur_droite + stats.instructions.pointeur_gauche),
        "    Droite (>): " .. stats.instructions.pointeur_droite,
        "    Gauche (<): " .. stats.instructions.pointeur_gauche,
        "  Modifications mémoire: " .. (stats.instructions.increment + stats.instructions.decrement),
        "    Incréments (+): " .. stats.instructions.increment,
        "    Décréments (-): " .. stats.instructions.decrement,
        "  Entrées/Sorties: " .. (stats.instructions.entree + stats.instructions.sortie),
        "    Sorties (.): " .. stats.instructions.sortie,
        "    Entrées (,): " .. stats.instructions.entree,
        "  Boucles: " .. stats.instructions.boucle_debut,
        "    Complexité max: " .. stats.complexite_boucles .. " niveaux",
        "",
        "Exécution:",
        "  Sortie: \"" .. (interpreteur.output or "") .. "\"",
        "  Position finale: " .. (interpreteur.ptr or 1),
        "  Mémoire utilisée: " .. (interpreteur.ptr or 1) .. " cellules"
    }
    
    return table.concat(rapport, "\n")
end

return Interpreteur