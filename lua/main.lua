local bf_interpreter = require("source.bf_interpreter")
local editor = require("source.editor")
local clavier = require("source.clavier")
local gui = require("source.gui")
local fs = require("source.fs")
local utils = require("source.utils")
local keys = require("source.keys")

local splashImage
local splashAlpha = 0
local splashState = "fadein" -- "fadein", "show", "fadeout", "done"
local splashTimer = 0

local theme
local running = false
local bf_code = ""
local output_buffer = {}
local mem_state = {}

local config_path = "config.cfg"


-- Sauvegarde config simple
local function save_config()
    local f = io.open(config_path, "w")
    if f then
        f:write("return {\n")
        f:write(string.format("  theme = %q,\n", theme.name or "dark"))
        f:write("  code = [[\n" .. bf_code .. "\n]]\n")
        f:write("}\n")
        f:close()
    end
end

function love.load()
    splashImage = love.graphics.newImage("gfx/splash.png")
    load_config()
    gui.init(theme)
    editor.set_code(bf_code)
    editor.init()
    clavier.init()
    keys.init()
end

function love.update(dt)
    -- Gestion splash
    if splashState == "fadein" then
        splashAlpha = math.min(1, splashAlpha + dt)
        if splashAlpha >= 1 then splashState = "show" splashTimer = 0 end
    elseif splashState == "show" then
        splashTimer = splashTimer + dt
        if splashTimer > 2 then splashState = "fadeout" end
    elseif splashState == "fadeout" then
        splashAlpha = math.max(0, splashAlpha - dt)
        if splashAlpha <= 0 then splashState = "done" running = true end
    end

    if running then
        editor.update(dt)
        clavier.update()
        gui.update(dt)
        keys.update(dt)

        -- Synchroniser code de l'éditeur
        bf_code = editor.get_code()
    end
end

function love.draw()
    love.graphics.clear(theme.background[1]/255, theme.background[2]/255, theme.background[3]/255)

    if splashState ~= "done" then
        love.graphics.setColor(1,1,1,splashAlpha)
        local w, h = love.graphics.getDimensions()
        local iw, ih = splashImage:getDimensions()
        love.graphics.draw(splashImage, (w - iw)/2, (h - ih)/2)
        love.graphics.setColor(1,1,1,1)
        return
    end

    -- Dessiner GUI + éditeur
    gui.draw()
    editor.draw(theme)
end

function love.quit()
    save_config()
end
