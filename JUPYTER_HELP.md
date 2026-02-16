# 🚀 Guide Jupyter Professionnel (Mode VSCode) 🛰️

Cette configuration est conçue pour être aussi solide et visuelle que VSCode ou Zed.

---

## ⚡ EXÉCUTION (Nouveautés)

| Touches | Action | Résultat |
|:---|:---|:---|
| **`<leader>jc`** | **Run Cell** | Exécute la cellule sous le curseur |
| **`<leader>ja`** | **Run All** | Nettoie TOUT et exécute tout le fichier (Résultats visibles sous chaque cellule) ✅ |
| **`<leader>ju`** | **Run Above** | Exécute tout depuis le début jusqu'au curseur |
| **`<leader>jb`** | **Run Below** | Exécute tout depuis le curseur jusqu'à la fin |
| **`<leader>jx`** | **Run Line** | Exécute la ligne (Affiche la valeur/sortie directement dessous) ✅ |

---

## 🎨 AFFICHAGE & SYNTAXE

- **Syntaxe Mixte** : Le texte est en Markdown natif, le code est en Python.
- **Résultats Inline** : Les résultats apparaissent en **bleu/gris directement sous ton code**, comme dans un vrai notebook.
- **Graphiques** : S'affichent par-dessus le code (Kitty/Ghostty).

---

## 🖥️ ÉDITEURS EXTERNES (FIXED)

| Touches | Action |
|:---|:---|
| **`<leader>oz`** | Ouvrir dans **Zed** (Chemin corrigé : `.local/zed.app/...`) ✅ |
| **`<leader>ov`** | Ouvrir dans **VSCode** |

---

## 🗑️ NETTOYAGE

| Touches | Action |
|:---|:---|
| **`<leader>jd`** | Supprimer l'output de la cellule actuelle |
| **`<leader>jD`** | Supprimer TOUS les outputs du fichier |

---

## 🔧 CONSEILS POUR UN RÉSULTAT PROPRE

1. **Initialise toujours** avec `<leader>mk` au début de ta session.
2. Si les graphiques ne s'affichent pas, vérifie que tu es dans un terminal compatible (Kitty est idéal).
3. Utilise **`<leader>ja`** pour avoir une vue d'ensemble de ton notebook avec tous les résultats.

*Configuration optimisée pour la stabilité et la clarté visuelle.* 🛰️✨
