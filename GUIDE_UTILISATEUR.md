# 📖 Guide Utilisateur - Brainfuck DS

## 🎮 Introduction

Brainfuck DS est un éditeur et interpréteur complet du langage Brainfuck pour Nintendo DS. Il offre une interface intuitive avec support tactile et permet d'écrire, éditer et exécuter des programmes Brainfuck directement sur votre console.

## 🕹️ Contrôles

### Écran Tactile
- **Clavier virtuel** : Tapez directement sur les touches affichées
- **Navigation** : Utilisez le stylet pour naviguer dans l'interface

### Boutons Physiques
- **D-Pad** : Navigation dans l'éditeur (↑↓←→)
- **A** : Confirmer/Sélectionner
- **B** : Retour/Nouvelle ligne dans l'éditeur
- **X** : Supprimer caractère (Backspace)
- **Y** : (Réservé pour fonctions futures)
- **L/R** : Navigation rapide
- **START** : Exécuter le programme
- **SELECT** : Menu principal

## 📝 Utilisation de l'Éditeur

### Interface
- **Écran du haut** : Informations système, mémoire, sortie
- **Écran du bas** : Éditeur de code + clavier virtuel

### Fonctionnalités
- ✅ **Coloration syntaxique** : Les instructions Brainfuck sont colorées
- ✅ **Numérotation des lignes** : Chaque ligne est numérotée
- ✅ **Curseur clignotant** : Position actuelle visible
- ✅ **Défilement automatique** : L'éditeur suit le curseur

### Couleurs Syntaxiques
- 🔴 **Rouge** : `>` `<` (déplacement du pointeur)
- 🟢 **Vert** : `+` `-` (modification de la mémoire)
- 🔵 **Bleu** : `.` `,` (entrée/sortie)
- 🟡 **Jaune** : `[` `]` (boucles)
- ⚪ **Gris** : Autres caractères (commentaires)

## 🧠 Le Langage Brainfuck

### Instructions de Base
| Instruction | Description |
|-------------|-------------|
| `>` | Déplace le pointeur vers la droite |
| `<` | Déplace le pointeur vers la gauche |
| `+` | Incrémente la valeur de la cellule courante |
| `-` | Décrémente la valeur de la cellule courante |
| `.` | Affiche le caractère ASCII de la cellule courante |
| `,` | Lit un caractère et le stocke dans la cellule courante |
| `[` | Si la cellule courante est 0, saute après le `]` correspondant |
| `]` | Si la cellule courante n'est pas 0, retourne au `[` correspondant |

### Exemple Simple : "Hello World"
```brainfuck
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```

## 🚀 Exécution des Programmes

### Lancer l'Exécution
1. Écrivez votre code Brainfuck dans l'éditeur
2. Appuyez sur **START** pour lancer l'exécution
3. Observez la sortie sur l'écran du haut

### Mode Debug
- **Écran du haut** : Affiche l'état de la mémoire en temps réel
- **PC** : Position actuelle dans le code (Program Counter)
- **Ptr** : Position du pointeur mémoire
- **Val** : Valeur de la cellule courante

### Arrêter l'Exécution
- Appuyez sur **B** ou **START** pour retourner à l'éditeur

## 💾 Gestion des Fichiers

### Sauvegarde Automatique
- Votre code est automatiquement sauvegardé dans `fat:/config.cfg`
- La configuration et le thème sont également préservés

### Exemples Inclus
Le projet inclut plusieurs exemples :
- `examples/hello_world.bf` : Programme "Hello World" classique
- `examples/fibonacci.bf` : Calcul de la suite de Fibonacci
- `examples/mandelbrot.bf` : Générateur de fractale de Mandelbrot

## ⚙️ Configuration

### Fichier de Configuration
Le fichier `fat:/config.cfg` contient :
```lua
{
  theme = "default",
  code = "votre code ici",
  settings = {
    auto_save = true,
    show_line_numbers = true,
    syntax_highlight = true
  }
}
```

### Thèmes
- **default** : Thème sombre par défaut
- Possibilité d'ajouter des thèmes personnalisés dans `themes/`

## 🔧 Fonctionnalités Avancées

### Analyse de Code
L'interpréteur peut analyser votre code et fournir :
- Statistiques d'utilisation des instructions
- Détection d'erreurs de syntaxe (crochets non appariés)
- Complexité des boucles imbriquées

### Optimisation
- Suppression automatique des commentaires
- Optimisation des séquences répétitives
- Élimination des opérations qui s'annulent

### Formatage
- Indentation automatique des boucles
- Limitation de la longueur des lignes
- Structure claire du code

## 🐛 Dépannage

### Problèmes Courants
1. **Écran noir** : Vérifiez que les fichiers sont correctement installés
2. **Pas de réaction tactile** : Calibrez l'écran tactile de votre DS
3. **Code qui ne s'exécute pas** : Vérifiez la syntaxe (crochets appariés)

### Messages d'Erreur
- **"Crochets non appariés"** : Vérifiez que chaque `[` a son `]` correspondant
- **"Dépassement mémoire"** : Le programme utilise trop de cellules mémoire
- **"Pointeur négatif"** : Le pointeur est sorti de la zone mémoire autorisée

## 📚 Ressources

### Apprendre Brainfuck
- [Wikipedia Brainfuck](https://fr.wikipedia.org/wiki/Brainfuck)
- [Tutoriels en ligne](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a)

### Communauté
- Partagez vos créations sur les forums homebrew DS
- Contribuez au projet sur GitHub

## 🏆 Crédits

- **Développeur** : Équipe Brainfuck DS
- **Moteur Lua** : DSLua/MicroLua
- **Exemples** : Communauté Brainfuck

---

*Amusez-vous bien avec Brainfuck DS ! 🧠🎮*