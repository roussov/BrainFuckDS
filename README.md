# 🧠 Brainfuck DS IDE

Un interpréteur et éditeur complet de Brainfuck pour **Nintendo DS**, écrit en **Lua** (via DSLua ou MicroLua), destiné à fonctionner en tant que **homebrew NDS**.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/brainfuck-ds/brainfuck-ds)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Nintendo%20DS-red.svg)](https://en.wikipedia.org/wiki/Nintendo_DS)

---

## 🎮 Fonctionnalités

### ✨ Éditeur Avancé
- ✔️ **Éditeur de code interactif** avec écran tactile
- ✔️ **Coloration syntaxique** pour Brainfuck
- ✔️ **Numérotation des lignes** automatique
- ✔️ **Curseur clignotant** et navigation fluide
- ✔️ **Clavier virtuel AZERTY** complet
- ✔️ **Sauvegarde automatique** du code

### 🚀 Interpréteur Puissant
- ✔️ **Interpréteur Brainfuck 100% compatible**
- ✔️ **Exécution pas-à-pas** pour le débogage
- ✔️ **Visualiseur de mémoire** en temps réel
- ✔️ **Gestion des entrées/sorties** complète
- ✔️ **Détection d'erreurs** avancée
- ✔️ **Optimisations de code** automatiques

### 🎨 Interface Utilisateur
- ✔️ **Interface double écran** optimisée
- ✔️ **Thèmes personnalisables** (système modulaire)
- ✔️ **Navigation intuitive** (D-pad, boutons, tactile)
- ✔️ **Messages d'état** informatifs
- ✔️ **Splash screen** animé

### 💾 Gestion des Fichiers
- ✔️ **Chargement/sauvegarde** depuis la carte SD
- ✔️ **Exemples inclus** (Hello World, Fibonacci, Mandelbrot)
- ✔️ **Configuration persistante**
- ✔️ **Support des fichiers .bf**

---

## 🗂️ Structure du Projet

```
brainfuck_ds/
├── 📁 source/                    # Code source Lua
│   ├── 🧠 bf_interpreter.lua     # Moteur Brainfuck
│   ├── ✏️ editor.lua             # Éditeur de texte
│   ├── ⌨️ clavier.lua            # Clavier virtuel
│   ├── 🖼️ gui.lua                # Interface utilisateur
│   ├── 🎮 keys.lua               # Gestion des touches
│   ├── 💾 fs.lua                 # Système de fichiers
│   ├── 🔧 utils.lua              # Utilitaires
│   └── 🇫🇷 interpréteur.lua      # Interface française
├── 📁 themes/                    # Thèmes visuels
│   └── 🎨 default.lua            # Thème par défaut
├── 📁 examples/                  # Exemples de programmes
│   ├── 👋 hello_world.bf         # Hello World classique
│   ├── 🔢 fibonacci.bf           # Suite de Fibonacci
│   └── 🌀 mandelbrot.bf          # Fractale de Mandelbrot
├── 📁 gfx/                       # Ressources graphiques
│   ├── 🖼️ icon.bmp               # Icône de l'application
│   └── 🌟 splash.png             # Écran de démarrage
├── 📁 data/                      # Données du projet
│   └── 📁 fonts/                 # Polices de caractères
├── 📁 build/                     # Scripts de build
│   └── 🔨 build.lua              # Script de build avancé
├── 🚀 main.lua                   # Point d'entrée principal
├── ⚙️ Makefile                   # Système de build
├── 📖 README.md                  # Ce fichier
├── 📚 GUIDE_UTILISATEUR.md       # Guide utilisateur complet
├── 🛠️ DEVELOPPEMENT.md           # Guide de développement
└── 💿 brainfuck.nds              # ROM compilée (générée)
```

---

## 🚀 Installation Rapide

### Prérequis
- **devkitARM** installé et configuré
- **Lua 5.1+** pour les scripts de build
- **ndstool** pour la création de ROM
- **Love2D NDS** (love.nds) dans le répertoire racine

### Compilation
```bash
# Clone du projet
git clone https://github.com/brainfuck-ds/brainfuck-ds.git
cd brainfuck-ds

# Build de release
make release

# Test de la ROM
make test
```

### Installation sur Flashcart
```bash
# Copie vers votre flashcart
make install DEST=/path/to/your/flashcart
```

---

## 🎮 Utilisation

### Contrôles de Base
| Bouton | Action |
|--------|--------|
| **D-Pad** | Navigation dans l'éditeur |
| **A** | Confirmer/Sélectionner |
| **B** | Nouvelle ligne |
| **X** | Supprimer caractère |
| **START** | Exécuter le programme |
| **SELECT** | Menu principal |
| **Écran tactile** | Clavier virtuel |

### Premiers Pas
1. **Démarrage** : Lancez brainfuck.nds sur votre DS
2. **Édition** : Utilisez le clavier tactile ou les boutons pour écrire
3. **Exécution** : Appuyez sur START pour lancer votre programme
4. **Débogage** : Observez la mémoire sur l'écran du haut

### Exemple Simple
```brainfuck
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```
Ce programme affiche "Hello World!"

---

## 🛠️ Développement

### Build de Développement
```bash
make dev          # Build sans optimisations
make watch        # Rebuild automatique
make lint         # Analyse statique
make format       # Formatage du code
```

### Architecture
- **Modulaire** : Chaque composant est indépendant
- **Extensible** : Système de thèmes et plugins
- **Optimisé** : Performance adaptée à la Nintendo DS
- **Documenté** : Code commenté et guides complets

### Contribution
1. Fork du projet
2. Création d'une branche feature
3. Développement avec tests
4. Pull request avec description

Voir [DEVELOPPEMENT.md](DEVELOPPEMENT.md) pour plus de détails.

---

## 📚 Documentation

- 📖 **[Guide Utilisateur](GUIDE_UTILISATEUR.md)** - Manuel complet d'utilisation
- 🛠️ **[Guide Développeur](DEVELOPPEMENT.md)** - Documentation technique
- 🧠 **[Référence Brainfuck](https://en.wikipedia.org/wiki/Brainfuck)** - Spécification du langage

---

## 🎯 Fonctionnalités Avancées

### Analyse de Code
- **Validation syntaxique** automatique
- **Statistiques d'utilisation** des instructions
- **Détection de boucles infinies** potentielles
- **Optimisation de code** (suppression de redondances)

### Débogage
- **Exécution pas-à-pas** avec contrôle fin
- **Visualisation mémoire** en temps réel
- **Points d'arrêt** sur instructions
- **Historique d'exécution**

### Personnalisation
- **Thèmes visuels** personnalisables
- **Configuration sauvegardée** automatiquement
- **Raccourcis clavier** configurables
- **Interface adaptable**

---

## 🏆 Exemples Inclus

### Hello World
```brainfuck
++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.
```

### Fibonacci
Programme calculant la suite de Fibonacci et affichant les résultats.

### Mandelbrot
Générateur de fractale de Mandelbrot en ASCII art.

---

## 🤝 Communauté

### Support
- **Issues GitHub** pour les bugs et suggestions
- **Discussions** pour l'aide et les questions
- **Wiki** pour la documentation communautaire

### Remerciements
- **Communauté homebrew DS** pour les outils et ressources
- **Créateurs de DSLua/MicroLua** pour le runtime Lua
- **Développeurs Brainfuck** pour l'inspiration

---

## 📄 Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🔗 Liens Utiles

- 🏠 **[Site Web](https://brainfuck-ds.github.io)**
- 📦 **[Releases](https://github.com/brainfuck-ds/brainfuck-ds/releases)**
- 🐛 **[Issues](https://github.com/brainfuck-ds/brainfuck-ds/issues)**
- 💬 **[Discussions](https://github.com/brainfuck-ds/brainfuck-ds/discussions)**

---

<div align="center">

**Fait avec ❤️ pour la communauté Nintendo DS homebrew**

*Brainfuck DS - Programmation ésotérique sur console portable* 🧠🎮

</div>
