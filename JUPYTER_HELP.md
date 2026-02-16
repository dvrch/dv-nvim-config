# 🚀 Guide Jupyter ULTRA-SIMPLIFIÉ 🛰️

**Nouvelle philosophie** : ZÉRO auto-init = ZÉRO kernel zombie = ZÉRO problème.

---

## ⚡ WORKFLOW EN 3 ÉTAPES

### 1️⃣ **Ouvrir le Notebook**
```bash
nvim mon_fichier.ipynb
```

### 2️⃣ **Initialiser le Kernel MANUELLEMENT**
> **`<leader>mk`** (une seule fois au début)

Tu verras : "Kernel python3 initialized"

### 3️⃣ **Travailler**
- **`<leader>jc`** : Exécuter une cellule
- **`<leader>ja`** : Exécuter TOUTES les cellules

---

## 🎹 RACCOURCIS ESSENTIELS

| Touches | Action | Quand l'utiliser |
|:---|:---|:---|
| **`<leader>mk`** | 🐍 **Initialiser le Kernel** | **AU DÉBUT** (une fois) |
| **`<leader>jc`** | ▶️ Exécuter la cellule | Usage principal |
| **`<leader>ja`** | 🚀 Exécuter TOUT | Pour tester tout le notebook |
| **`<leader>jx`** | Exécuter une ligne | Débogage rapide |
| **`<leader>jv`** | Exécuter sélection | En mode visuel |

---

## 🗑️ NETTOYAGE

| Touches | Action |
|:---|:---|
| **`<leader>jd`** | Supprimer l'output de la cellule actuelle |
| **`<leader>jD`** | Supprimer TOUS les outputs |
| **`<leader>mK`** | 💀 **TUER TOUS LES KERNELS** (en cas de problème) |

---

## 🆘 DÉPANNAGE

### Problème : Les kernels se multiplient
**Solution** : **`<leader>mK`** (tue tout) puis **ferme/rouvre Neovim**

### Problème : "Not in a cell"
**Cause** : Ton curseur n'est pas dans un bloc `# %%`
**Solution** : Assure-toi d'avoir des marqueurs `# %%` entre tes cellules

### Problème : Rien ne s'exécute
**Cause** : Kernel pas initialisé
**Solution** : Fais **`<leader>mk`** en premier

---

## 💡 FORMAT DES CELLULES

Ton notebook doit ressembler à ça :
```python
# %%
print("Cellule 1")
# %%
print("Cellule 2")
```

**Important** : Le `# %%` SEUL sur une ligne = début de cellule.

---

*Configuration minimaliste et stable. Fini l'auto-init qui crée des problèmes !* 🛰️✨
