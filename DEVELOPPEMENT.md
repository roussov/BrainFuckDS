# 🛠️ Guide de Développement - Brainfuck DS

## 📋 Prérequis

### Outils Requis
- **Lua 5.1+** : Interpréteur Lua
- **devkitARM** : Toolchain pour Nintendo DS
- **ndstool** : Outil de création de ROM NDS
- **Love2D NDS** : Runtime Lua pour Nintendo DS

### Outils Optionnels
- **melonDS** ou **DeSmuME** : Émulateurs Nintendo DS
- **luacheck** : Analyseur statique Lua
- **lua-format** : Formateur de code Lua
- **inotify-tools** : Surveillance de fichiers (Linux)

## 🏗️ Architecture du Projet

```
brainfuck_ds/
├── source/                 # Code source Lua
│   ├── bf_interpreter.lua  # Moteur Brainfuck
│   ├── editor.lua         # Éditeur de texte
│   ├── clavier.lua        # Clavier virtuel
│   ├── gui.lua            # Interface utilisateur
│   ├── keys.lua           # Gestion des touches
│   ├── fs.lua             # Système de fichiers
│   ├── utils.lua          # Utilitaires
│   └── interpréteur.lua   # Interface française
├── themes/                # Thèmes visuels
│   └── default.lua        # Thème par défaut
├── examples/              # Exemples de programmes
├── gfx/                   # Ressources graphiques
├── data/                  # Données du jeu
├── build/                 # Scripts de build
│   └── build.lua          # Script de build principal
├── main.lua              # Point d'entrée
├── Makefile              # Système de build
└── README.md             # Documentation
```

## 🔧 Compilation

### Build Standard
```bash
make build
```

### Build de Développement
```bash
make dev
```

### Build de Release
```bash
make release
```

### Nettoyage
```bash
make clean
```

## 🧪 Tests et Débogage

### Test de la ROM
```bash
make test
```

### Lancement dans l'émulateur
```bash
make run          # melonDS
make run-desmume  # DeSmuME
```

### Surveillance des fichiers
```bash
make watch  # Rebuild automatique lors des modifications
```

## 📝 Standards de Code

### Style Lua
- **Indentation** : 4 espaces
- **Noms de variables** : snake_case
- **Noms de fonctions** : camelCase pour les méthodes, snake_case pour les fonctions
- **Constantes** : UPPER_CASE

### Exemple de Code
```lua
-- Bon style
local MonModule = {}

local CONSTANTE_GLOBALE = 42

function MonModule.maFonction(param1, param2)
    local variable_locale = param1 + param2
    return variable_locale
end

function MonModule:maMethode()
    self.propriete = "valeur"
end

return MonModule
```

### Commentaires
```lua
-- Commentaire de ligne simple

--[[
Commentaire
multi-lignes
]]

--- Documentation de fonction
-- @param code string Code Brainfuck à exécuter
-- @return boolean Succès de l'exécution
function executer_code(code)
    -- Implémentation
end
```

## 🏛️ Architecture Logicielle

### Modules Principaux

#### 1. bf_interpreter.lua
- **Rôle** : Moteur d'exécution Brainfuck
- **Fonctions clés** :
  - `new()` : Créer une instance
  - `load(code)` : Charger du code
  - `step()` : Exécuter une instruction
  - `runAll()` : Exécution complète

#### 2. editor.lua
- **Rôle** : Éditeur de texte interactif
- **Fonctions clés** :
  - `load(text)` : Charger du texte
  - `render()` : Affichage
  - `update()` : Mise à jour
  - `insertChar(char)` : Insertion de caractère

#### 3. gui.lua
- **Rôle** : Interface utilisateur
- **Fonctions clés** :
  - `init()` : Initialisation
  - `printKey()` : Affichage de touche
  - `message()` : Affichage de message

### Flux de Données
```
main.lua
    ↓
[Initialisation]
    ↓
[Boucle principale]
    ├── keys.update()      # Lecture des touches
    ├── editor.update()    # Mise à jour éditeur
    ├── gui.update()       # Mise à jour interface
    └── draw()             # Rendu graphique
```

## 🎨 Système de Thèmes

### Structure d'un Thème
```lua
-- themes/mon_theme.lua
local theme = {
    name = "mon_theme",
    
    -- Couleurs principales
    background = {30, 30, 40},
    foreground = {220, 220, 220},
    
    -- Éditeur
    editor = {
        background = {25, 25, 35},
        text = {255, 255, 255},
        cursor = {255, 255, 0}
    },
    
    -- Syntaxe Brainfuck
    syntax = {
        pointer = {255, 100, 100},  -- > <
        memory = {100, 255, 100},   -- + -
        io = {100, 100, 255},       -- . ,
        loop = {255, 255, 100}      -- [ ]
    }
}

return theme
```

### Utilisation
```lua
local theme = require("themes.mon_theme")
app.theme = theme
```

## 🔌 API Nintendo DS

### Écrans
```lua
-- Effacer un écran
Screen.clear(Screen.TOP)
Screen.clear(Screen.BOTTOM)

-- Afficher du texte
Screen.print(x, y, text, color, screen)

-- Dessiner des formes
Screen.fillRect(x, y, width, height, color)
Screen.drawRect(x, y, width, height, color)

-- Rafraîchir l'affichage
Screen.refresh()
```

### Couleurs
```lua
-- Créer une couleur
local color = Color.new(r, g, b)        -- RGB
local color = Color.new(r, g, b, a)     -- RGBA
```

### Touches
```lua
-- Initialisation
pad.init()

-- Lecture des touches
pad.scanPads()
local pressed = pad.isKeyDown(pad.KEY.A)
```

### Écran Tactile
```lua
-- Lecture du stylet
local touch = stylus.read()
if touch.status > 0 then
    local x, y = touch.x, touch.y
    -- Traitement du touch
end
```

## 🐛 Débogage

### Messages de Debug
```lua
local utils = require("source.utils")

-- Message de debug
utils.debug_print("Valeur:", variable)

-- Affichage conditionnel
if DEBUG then
    print("Mode debug activé")
end
```

### Gestion d'Erreurs
```lua
-- Protection d'appel
local success, result = pcall(function()
    -- Code pouvant échouer
    return operation_risquee()
end)

if not success then
    print("Erreur:", result)
end
```

### Profiling Simple
```lua
local start_time = os.clock()
-- Code à mesurer
local end_time = os.clock()
print("Durée:", (end_time - start_time) * 1000, "ms")
```

## 📊 Optimisation

### Performance
- **Éviter les allocations** dans les boucles principales
- **Réutiliser les objets** plutôt que les recréer
- **Limiter les appels** aux fonctions coûteuses

### Mémoire
- **Nettoyer les références** inutiles
- **Utiliser des pools d'objets** pour les éléments fréquents
- **Surveiller la consommation** avec `collectgarbage("count")`

### Exemple d'Optimisation
```lua
-- Avant (inefficace)
function update()
    for i = 1, 1000 do
        local obj = {x = i, y = i}  -- Allocation répétée
        process(obj)
    end
end

-- Après (optimisé)
local temp_obj = {x = 0, y = 0}  -- Réutilisation
function update()
    for i = 1, 1000 do
        temp_obj.x = i
        temp_obj.y = i
        process(temp_obj)
    end
end
```

## 🚀 Déploiement

### Création de la ROM
```bash
make release
```

### Test sur Matériel
1. Copier `brainfuck.nds` sur une flashcart
2. Insérer dans la Nintendo DS
3. Lancer le homebrew

### Distribution
```bash
make package  # Crée un archive de distribution
```

## 🤝 Contribution

### Workflow Git
1. Fork du projet
2. Création d'une branche feature
3. Développement et tests
4. Pull request avec description

### Standards de Commit
```
type(scope): description

feat(editor): ajout de la coloration syntaxique
fix(interpreter): correction du dépassement mémoire
docs(readme): mise à jour de la documentation
```

### Tests Avant Commit
```bash
make clean
make check
make build
make test
```

## 📚 Ressources

### Documentation Nintendo DS
- [devkitPro Documentation](https://devkitpro.org/wiki/Getting_Started)
- [libnds Reference](https://libnds.devkitpro.org/)

### Lua
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)
- [Programming in Lua](https://www.lua.org/pil/)

### Brainfuck
- [Brainfuck Specification](https://github.com/brain-lang/brainfuck/blob/master/brainfuck.md)
- [Brainfuck Algorithms](http://brainfuck.org/)

---

*Happy coding! 🧠💻*