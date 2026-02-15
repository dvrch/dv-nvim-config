# 🚀 Guide Rapide : Jupyter dans Neovim

Bienvenue dans ton environnement de Data Science ultra-performant ! 🛰️

## 🛠️ Initialisation (Indispensable)
Avant d'exécuter du code, tu dois initialiser le noyau (kernel) :
1. Ouvre un fichier `.ipynb` ou `.py`.
2. Appuie sur `<leader>mj`.
3. Sélectionne `python3` (ou le kernel de ton choix).

---

## 🎹 Raccourcis Principaux

| Touches | Action |
| :--- | :--- |
| `<leader>mj` | **Initialiser le Kernel** (Startup) |
| `<leader>rl` | Exécuter la **Ligne** actuelle |
| `<leader>rc` | Ré-exécuter la **Cellule** actuelle |
| `<leader>me` | Évaluer un **Opérateur** (ex: `vap` pour un paragraphe) |
| `<leader>rv` | Évaluer la **Sélection Visuelle** |
| `<leader>os` | **Montrer** l'output (Float Window) |
| `<leader>oh` | **Cacher** l'output |
| `<leader>rd` | **Effacer** l'output de la cellule |
| `<leader>mh` | **Ouvrir cette aide** 📖 |

---

## 📊 Visualisation & Images
- Les graphiques (Matplotlib, Seaborn, Plotly) s'affichent automatiquement si ton terminal le supporte.
- Si les images ne s'affichent pas, vérifie que `luarocks install magick` a bien fonctionné.
- Utilise `<leader>os` pour voir le graphique en grand dans une fenêtre flottante.

---

## 📝 Édition de Notebooks (.ipynb)
- Grâce à **Jupytext**, tu peux ouvrir un fichier `.ipynb` et il sera affiché comme du Markdown.
- À l'enregistrement (`:w`), Neovim synchronise automatiquement les changements avec le fichier `.ipynb` réel.
- **Otter.nvim** s'occupe de te donner l'autocomplétion (LSP) dans les blocs de code.

---

## ⚡ Astuces
- Pour voir toutes les variables : utilise les commandes magiques IPython comme `%whos`.
- Pour installer un package sans quitter Neovim : `!pip install <package>`.

---
*Configuré avec ❤️ par Antigravity.*
