# 🚀 Guide Jupyter Complet : Neovim 🛰️

Environnement Data Science au complet avec **Matplotlib**, **Pandas**, **NumPy** et **Seaborn** installés !

---

## 🎨 Comment Ça Fonctionne

Jupytext convertit ton `.ipynb` en Python temporairement (en mémoire) pour que Molten puisse détecter les cellules. Les fichiers temporaires `.py`/`.md` sont **automatiquement supprimés** après sauvegarde.

---

## ⌨️ Raccourcis Principaux

| Touches | Action | Résultat |
|:---|:---|:---|
| **`<leader>mk`** | Initialiser le kernel | Lance Python 3 |
| **`<leader>jx`** | Exécuter la ligne | Output apparaît DIRECTEMENT sous la ligne |
| **`<leader>jc`** | Exécuter la cellule | Exécute tout le bloc # %% |
| **`<leader>jv`** | Exécuter sélection | En mode visuel |
| **`<leader>jd`** | **Tout effacer** | Supprime TOUS les outputs (cellules + lignes) |
| **`<leader>jo`** | Entrer dans l'output | Pour voir en détail (fenêtre navigable) |
| **`<leader>jh`** | Cacher l'output | Masque la fenêtre |
| **`<leader>jr`** | Re-run tout | Exécute toutes les cellules du fichier |

---

## 📊 Affichage des Résultats

- **Texte** : Apparaît en **lignes virtuelles bleues** directement sous ta ligne de code ✅
- **Print()** : Le résultat s'affiche maintenant correctement
- **Graphiques** : S'affichent dans une fenêtre popup (si ton terminal le supporte)
- **Pour voir en grand** : Fais `<leader>jo` pour naviguer dans l'output

---

## 🔧 Dépannage

### "Not in a cell"
Assure-toi que ton curseur est dans un bloc délimité par `# %%`

### Le graphique ne s'affiche pas
1. Vérifie que tu as un terminal compatible (Kitty, WezTerm, Ghostty)
2. Utilise `plt.show()` à la fin de ton code
3. Fais `<leader>jo` pour forcer l'affichage

### L'output ne se voit pas
- Fais `<leader>jo` pour entrer dans la fenêtre d'output
- Vérifie que le kernel est bien initialisé (`<leader>mk`)

*Configuré avec ❤️ par Antigravity.*
