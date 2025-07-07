-- themes/default.lua
-- Thème par défaut pour l'éditeur Brainfuck DS

local theme = {
    name = "default",
    
    -- Couleurs principales
    background = {30, 30, 40},
    foreground = {220, 220, 220},
    
    -- Éditeur
    editor = {
        background = {25, 25, 35},
        text = {255, 255, 255},
        cursor = {255, 255, 0},
        line_numbers = {120, 120, 120},
        selection = {80, 120, 200, 128}
    },
    
    -- Syntaxe Brainfuck
    syntax = {
        pointer = {255, 100, 100},     -- > <
        memory = {100, 255, 100},      -- + -
        io = {100, 100, 255},          -- . ,
        loop = {255, 255, 100},        -- [ ]
        comment = {120, 120, 120},     -- autres caractères
        default = {200, 200, 200}
    },
    
    -- Interface
    ui = {
        button = {80, 80, 90},
        button_hover = {100, 100, 110},
        button_pressed = {60, 60, 70},
        button_text = {255, 255, 255},
        
        panel = {40, 40, 50},
        panel_border = {60, 60, 70},
        
        status_bar = {20, 20, 30},
        status_text = {180, 180, 180}
    },
    
    -- Messages
    messages = {
        info = {100, 200, 255},
        warning = {255, 200, 100},
        error = {255, 100, 100},
        success = {100, 255, 100}
    },
    
    -- Visualiseur mémoire
    memory = {
        cell = {50, 50, 60},
        cell_active = {100, 150, 200},
        cell_border = {80, 80, 90},
        value_text = {255, 255, 255},
        pointer_indicator = {255, 255, 0}
    }
}

return theme