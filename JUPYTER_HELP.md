# 🚀 Guide Rapide : Jupyter dans Neovim (Optimisé)

### 🛠️ Initialisation du Noyau (Kernel)
- **`<leader>mk`** : Initialise directement avec **Python 3 (Système)**. C'est le plus rapide ! ⚡
- **`<leader>mj`** : Te permet de choisir manuellement un autre noyau si besoin.

---

### 🎹 Raccourcis Principaux

| Touches | Action |
| :--- | :--- |
| **`<leader>mk`** | **Initialisation Rapide** (Python 3) |
| **`<leader>rl`** | Exécuter la **Ligne** actuelle |
| **`<leader>rc`** | Ré-exécuter la **Cellule** actuelle (délimitée par `# %%`) |
| **`<leader>os`** | **Montrer** l'output (Fenêtre flottante) |
| **`<leader>rd`** | **Effacer** l'output de la cellule |
| **`<leader>mh`** | **Ouvrir cette aide** 📖 |

---

### 💡 Détection des Cellules ("Not in a cell")
Pour que Neovim reconnaisse une cellule, j'ai activé le format **Hydrogen**.
Une cellule doit ressembler à ceci :
```python
# %%
print("Ceci est une cellule")
a = 10
# %%
```
Si tu n'as pas de `# %%`, Neovim ne "voit" pas la cellule. Tu peux les ajouter manuellement ou laisser Jupytext les gérer.

---

### 📊 Visualisation
- Pour voir un graphique : fais ton exécution, puis **`<leader>os`**.
- L'erreur `E325 ATTENTION` (Swap file) a été nettoyée. Neovim ne devrait plus bloquer à l'ouverture.

---
*Configuré avec ❤️ par Antigravity.*
