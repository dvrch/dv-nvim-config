# 🚀 Guide Jupyter Master : Neovim 🛰️

Ton environnement a été migré vers le format **Markdown (.md)** pour Jupytext. C'est le mode le plus puissant car il permet une vraie coloration mixte.

---

### 🎨 1. Coloration Syntaxique Double
- Tes fichiers `.ipynb` s'ouvriront désormais comme du **Markdown**.
- **Le texte** : Coloration Markdown native (titres, gras, etc.).
- **Le code** : Coloration Python native complète à l'intérieur des blocs ```python.
- **Toggle** : Utilise toujours **`<leader>uy`** pour alterner avec ta coloration Obsidienne.

---

### 📏 2. Délimitation des Cellules (Visuel)
Les cellules sont délimitées par ` ```python ` et ` ``` `.
- **Ligne de séparation** : J'ai ajouté un trait horizontal virtuel (`━━━`) sur ces balises pour que tu voies bien les blocs, sans polluer le fichier.

---

### 🎹 3. Nouveaux Raccourcis Unifiés
| Action | Raccourci | Résultat |
| :--- | :--- | :--- |
| **Initialiser** | **`<leader>mk`** | Lance le moteur Python |
| **Exécuter Cellule** | **`<leader>jc`** | Exécute tout le bloc de code |
| **Exécuter Ligne** | **`<leader>jx`** | Exécute la ligne sous le curseur |
| **Supprimer Output** | **`<leader>jd`** | Efface le résultat (Ligne ou Cellule) |
| **Voir en Grand** | **`<leader>jo`** | Ouvre une fenêtre flottante (si texte long) |

---

### 📊 4. Où est mon résultat ? (Nouveauté !)
- **Plus de fenêtres gênantes** : Le résultat apparaît désormais **DIRECTEMENT SOUS TA LIGNE** de code en texte virtuel bleu/gris. ✅
- Pour les graphiques (plots), ils s'afficheront sur ton code là où se trouve le curseur.

---
### 🚨 Aide au dépannage ("Not in a cell")
Si Molten dit "Not in a cell", assure-toi que ton curseur est **à l'intérieur** d'un bloc de code Markdown :
```python
print("Ici ça marche")
```

*Configuré avec ❤️ par Antigravity.*
