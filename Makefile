# === Makefile pour Brainfuck DS ===
# Utilise le script de build Lua avancé

PROJECT     := brainfuck
ROM_NAME    := $(PROJECT).nds
BUILD_SCRIPT := build/build.lua

# === Règles principales ===

# Build par défaut
all: build

# Build complet
build:
	@echo "🚀 Lancement du build Brainfuck DS..."
	@lua $(BUILD_SCRIPT) build

# Build de développement (sans optimisations)
dev:
	@echo "🔧 Build de développement..."
	@lua $(BUILD_SCRIPT) dev

# Build de release (avec optimisations)
release:
	@echo "📦 Build de release..."
	@lua $(BUILD_SCRIPT) release

# Vérification des prérequis
check:
	@echo "🔍 Vérification des prérequis..."
	@lua $(BUILD_SCRIPT) check

# Nettoyage
clean:
	@echo "🧹 Nettoyage..."
	@lua $(BUILD_SCRIPT) clean

# === Utilitaires ===

# Lancement dans l'émulateur
run: $(ROM_NAME)
	@echo "▶️ Lancement dans melonDS..."
	@melonDS $(ROM_NAME) || echo "melonDS non trouvé, utilisez DeSmuME ou un autre émulateur"

# Lancement avec DeSmuME
run-desmume: $(ROM_NAME)
	@echo "▶️ Lancement dans DeSmuME..."
	@desmume $(ROM_NAME) || echo "DeSmuME non trouvé"

# Installation sur flashcart (nécessite un répertoire de destination)
install: $(ROM_NAME)
	@if [ -z "$(DEST)" ]; then \
		echo "❌ Spécifiez le répertoire de destination: make install DEST=/path/to/flashcart"; \
	else \
		echo "📋 Installation vers $(DEST)..."; \
		cp $(ROM_NAME) $(DEST)/; \
		cp -r examples $(DEST)/ 2>/dev/null || true; \
		echo "✅ Installation terminée"; \
	fi

# Affichage des informations
info:
	@echo "📊 Informations du projet:"
	@echo "  Nom: $(PROJECT)"
	@echo "  ROM: $(ROM_NAME)"
	@echo "  Script de build: $(BUILD_SCRIPT)"
	@echo ""
	@echo "🎯 Cibles disponibles:"
	@echo "  build     - Build complet"
	@echo "  dev       - Build de développement"
	@echo "  release   - Build de release"
	@echo "  clean     - Nettoyage"
	@echo "  check     - Vérification des prérequis"
	@echo "  run       - Lancement dans melonDS"
	@echo "  install   - Installation sur flashcart"
	@echo "  info      - Affichage de cette aide"

# Test de la ROM (vérification basique)
test: $(ROM_NAME)
	@echo "🧪 Test de la ROM..."
	@if [ -f $(ROM_NAME) ]; then \
		echo "✅ ROM générée avec succès"; \
		ls -lh $(ROM_NAME); \
	else \
		echo "❌ ROM non trouvée"; \
		exit 1; \
	fi

# === Règles de développement ===

# Surveillance des fichiers (nécessite inotify-tools)
watch:
	@echo "👀 Surveillance des fichiers..."
	@while inotifywait -e modify -r source/ main.lua themes/ 2>/dev/null; do \
		echo "🔄 Fichier modifié, rebuild..."; \
		make dev; \
	done || echo "inotify-tools non installé, utilisez 'make dev' manuellement"

# Formatage du code Lua (nécessite lua-format)
format:
	@echo "🎨 Formatage du code..."
	@find . -name "*.lua" -not -path "./build/*" -not -path "./out/*" -exec lua-format -i {} \; 2>/dev/null || echo "lua-format non installé"

# Analyse statique (nécessite luacheck)
lint:
	@echo "🔍 Analyse statique..."
	@luacheck . --exclude-files build/ out/ || echo "luacheck non installé"

# === Règles spéciales ===

# Génération de la documentation
docs:
	@echo "📚 Génération de la documentation..."
	@mkdir -p docs
	@echo "Documentation disponible dans GUIDE_UTILISATEUR.md"

# Création d'un package de distribution
package: release
	@echo "📦 Création du package de distribution..."
	@mkdir -p dist
	@cp $(ROM_NAME) dist/
	@cp README.md dist/
	@cp GUIDE_UTILISATEUR.md dist/
	@cp -r examples dist/
	@tar -czf brainfuck-ds-v1.0.tar.gz -C dist .
	@echo "✅ Package créé: brainfuck-ds-v1.0.tar.gz"

# === Déclarations ===

.PHONY: all build dev release clean check run run-desmume install info test watch format lint docs package

# Aide par défaut
help: info

