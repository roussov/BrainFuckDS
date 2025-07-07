#!/usr/bin/env lua
-- Lanceur pour Brainfuck DS (version portable)

-- Ajouter le répertoire lua au path
package.path = package.path .. ";./lua/?.lua;./lua/source/?.lua"

-- Charger le programme principal
require("main")
