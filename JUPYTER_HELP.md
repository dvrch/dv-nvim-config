# 🚀 Guide Jupyter Simplifié : Neovim 🛰️

Configuration ultra-simplifiée : Molten travaille **directement** sur les fichiers `.ipynb` sans conversion intermédiaire.

---

## 🎨 Coloration Syntaxique
Les fichiers `.ipynb` s'ouvrent avec :
- **JSON natif** : Neovim affiche la structure brute du notebook
- Pour avoir une belle vue, utilise VSCode en parallèle ou travaille directement dans le JSON

> **Note** : J'ai désactivé Jupytext qui créait des fichiers parasites. Molten fonctionne seul maintenant.

---

## ⌨️ Raccourcis Jupyter

| Action | Touches |
|:---|:---|
| **Initialiser** (se fait auto) | `<leader>mk` |
| **Exécuter Cellule** | `<leader>jc` |
| **Exécuter Ligne** | `<leader>jx` |
| **Supprimer Output** | `<leader>jd` |
| **Voir Output (Float)** | `<leader>jo` |

---

## 🔧 Navigation dans un .ipynb

Les notebooks `.ipynb` sont des fichiers JSON. Pour exécuter du code :
1. Place ton curseur sur une ligne Python dans une cellule "source"
2. Fais `<leader>jx` (ligne) ou `<leader>jc` (cellule complète)
3. Le résultat apparaît en dessous en texte virtuel

---

## 💡 Conseil
Pour une meilleure expérience visuelle, ouvre le même fichier dans VSCode à côté de Neovim :
- **VSCode** : Pour voir et éditer visuellement
- **Neovim** : Pour exécuter rapidement avec les raccourcis

*Configuré avec ❤️ par Antigravity.*
