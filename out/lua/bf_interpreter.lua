-- bf_interpreter.lua

local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new()
    local self = setmetatable({}, Interpreter)
    self.tape = {}
    self.ptr = 1
    self.code = ""
    self.pc = 1
    self.output = ""
    self.inputBuffer = {}
    self.bracketMap = {}
    self.running = false
    self.maxMemory = 30000  -- taille max mémoire (comme en C classique)
    self.onOutput = nil     -- callback(char)
    self.onInputRequest = nil -- callback() => char or nil
    return self
end

-- Prétraitement pour construire la table des boucles [ ]
function Interpreter:buildBracketMap()
    local stack = {}
    self.bracketMap = {}
    for i = 1, #self.code do
        local c = self.code:sub(i,i)
        if c == "[" then
            table.insert(stack, i)
        elseif c == "]" then
            local startIdx = table.remove(stack)
            if not startIdx then
                error("Erreur syntaxe : ']' sans '[' à la position "..i)
            end
            self.bracketMap[startIdx] = i
            self.bracketMap[i] = startIdx
        end
    end
    if #stack > 0 then
        error("Erreur syntaxe : '[' sans ']' à la position "..stack[#stack])
    end
end

-- Charge le code Brainfuck
function Interpreter:load(code)
    self.code = code
    self.pc = 1
    self.tape = {}
    self.ptr = 1
    self.output = ""
    self.inputBuffer = {}
    self.running = true
    self:buildBracketMap()
end

-- Reset output
function Interpreter:resetOutput()
    self.output = ""
end

-- Ajoute une chaîne d’entrée au buffer
function Interpreter:addInput(str)
    for i=1,#str do
        table.insert(self.inputBuffer, str:sub(i,i))
    end
end

-- Lecture d’un caractère en entrée
function Interpreter:readInput()
    if #self.inputBuffer > 0 then
        return table.remove(self.inputBuffer, 1)
    elseif self.onInputRequest then
        return self.onInputRequest()
    else
        return nil -- pas d'entrée dispo
    end
end

-- Exécute une instruction (step)
function Interpreter:step()
    if not self.running then return end
    if self.pc > #self.code then
        self.running = false
        return
    end

    local c = self.code:sub(self.pc, self.pc)

    if c == ">" then
        self.ptr = self.ptr + 1
        if self.ptr > self.maxMemory then
            error("Dépassement mémoire max: "..self.maxMemory)
        end
        if not self.tape[self.ptr] then
            self.tape[self.ptr] = 0
        end

    elseif c == "<" then
        self.ptr = self.ptr - 1
        if self.ptr < 1 then
            error("Pointeur mémoire inférieur à 1")
        end

    elseif c == "+" then
        self.tape[self.ptr] = (self.tape[self.ptr] or 0) + 1
        if self.tape[self.ptr] > 255 then
            self.tape[self.ptr] = 0
        end

    elseif c == "-" then
        self.tape[self.ptr] = (self.tape[self.ptr] or 0) - 1
        if self.tape[self.ptr] < 0 then
            self.tape[self.ptr] = 255
        end

    elseif c == "." then
        local ch = string.char(self.tape[self.ptr] or 0)
        self.output = self.output .. ch
        if self.onOutput then
            self.onOutput(ch)
        end

    elseif c == "," then
        local inp = self:readInput()
        if inp then
            self.tape[self.ptr] = string.byte(inp)
        else
            -- Pas d'entrée dispo, mettre 0 ou bloquer
            self.tape[self.ptr] = 0
        end

    elseif c == "[" then
        if (self.tape[self.ptr] or 0) == 0 then
            self.pc = self.bracketMap[self.pc]
            if not self.pc then
                error("Erreur boucle : '[' sans correspondance à la position "..self.pc)
            end
        end

    elseif c == "]" then
        if (self.tape[self.ptr] or 0) ~= 0 then
            self.pc = self.bracketMap[self.pc]
            if not self.pc then
                error("Erreur boucle : ']' sans correspondance à la position "..self.pc)
            end
        end
    end

    self.pc = self.pc + 1

    if self.pc > #self.code then
        self.running = false
    end
end

-- Exécute tout en batch jusqu'à la fin ou erreur
function Interpreter:runAll()
    while self.running do
        self:step()
    end
end

-- Retourne vrai si en cours d’exécution
function Interpreter:isRunning()
    return self.running
end

return Interpreter
