-- utils.lua
-- Module utilitaire pour Brainfuck NDS Lua

local utils = {}

-- Vérifie si une table (liste) contient une valeur
function utils.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

-- Copie superficielle d'une table (shallow copy)
function utils.shallow_copy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

-- Concatène les éléments d'une table en une chaîne, avec séparateur
function utils.join(tbl, sep)
    sep = sep or ","
    local str = ""
    for i, v in ipairs(tbl) do
        str = str .. tostring(v)
        if i < #tbl then
            str = str .. sep
        end
    end
    return str
end

-- Inverse une chaîne de caractères (simple)
function utils.reverse_str(s)
    local reversed = {}
    for i = #s, 1, -1 do
        reversed[#reversed + 1] = s:sub(i,i)
    end
    return table.concat(reversed)
end

-- Affiche un message de debug avec préfixe
function utils.debug_print(...)
    print("[DEBUG]", ...)
end

-- Fonction pour limiter une valeur dans un intervalle [min, max]
function utils.clamp(value, min_val, max_val)
    if value < min_val then return min_val end
    if value > max_val then return max_val end
    return value
end

-- Initialise une table avec n éléments égaux à val
function utils.init_table(n, val)
    local t = {}
    for i = 1, n do
        t[i] = val
    end
    return t
end

-- Recherche la position d'une valeur dans une table, nil si absente
function utils.index_of(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return nil
end

-- Transforme un entier en caractère ASCII
function utils.char_from_code(code)
    return string.char(code % 256)
end

-- Transforme un caractère en code ASCII
function utils.code_from_char(c)
    return string.byte(c) or 0
end

return utils
