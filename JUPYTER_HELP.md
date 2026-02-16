# 🚀 Guide Jupyter DÉFINITIF : Neovim 🛰️

Configuration professionnelle avec exécution séquentielle et gestion intelligente des kernels.

---

## ⚡ PRIORITÉS D'EXÉCUTION

### 1️⃣ **PRIORITÉ 1 : CELLULE** (Recommandé)
**`<leader>jc`** : Exécute TOUTE la cellule (bloc entre deux `# %%`)
- C'est la commande PRINCIPALE pour travailler avec Jupyter
- Garantit l'exécution complète du code d'une cellule

### 2️⃣ **PRIORITÉ 2 : SÉLECTION**
**`<leader>jv`** (en mode VISUEL) : Exécute les lignes sélectionnées
1. Sélectionne plusieurs lignes avec `V` (mode visuel ligne)
2. Appuie sur `<leader>jv`
3. Seules les lignes sélectionnées s'exécutent

### 3️⃣ **PRIORITÉ 3 : LIGNE**
**`<leader>jx`** : Exécute UNE SEULE ligne
- Utile pour le débogage rapide

---

## 🔥 COMMANDES GLOBALES (NOUVELLES)

| Touches | Action | Description |
|:---|:---|:---|
| **`<leader>ja`** | **Run All Clean** | 🧹 Supprime TOUS les outputs + Exécute TOUTES les cellules une par une (attend que chaque cellule finisse avant de lancer la suivante) ✅ |
| **`<leader>jD`** | **Delete All Outputs** | 🗑️ Supprime TOUS les outputs de TOUTES les cellules (majuscule D) |
| **`<leader>jd`** | Delete Current Output | Supprime l'output de la cellule actuelle (minuscule d) |
| **`<leader>ji`** | Interrupt | ⏸️ Interrompt l'exécution en cours |

---

## 🎯 WORKFLOW RECOMMANDÉ

### Pour Développer :
1. **`<leader>jc`** : Exécuter la cellule actuelle
2. Corriger le code si nécessaire
3. **`<leader>jc`** : Re-exécuter

### Pour Tester Tout :
1. **`<leader>ja`** : Nettoie tout et exécute toutes les cellules séquentiellement ✅

### Pour Nettoyer :
- **`<leader>jD`** : Supprime tous les résultats d'un coup

---

## 🐍 KERNEL (Plus de Problème)

Le kernel Python 3 s'initialise **automatiquement UNE SEULE FOIS** quand tu ouvres un `.ipynb`.
- Plus de demande à chaque exécution ✅
- Un seul kernel par fichier ✅
- Pour réinitialiser manuellement : **`<leader>mk`**

---

## 📊 Affichage des Résultats

- **Texte** : Directement sous la ligne de code en bleu
- **Print()** : Fonctionne parfaitement
- **Graphiques** : Fenêtre popup (si terminal compatible)
- **Voir en grand** : `<leader>jo`

---

## 🆘 Dépannage

### La cellule ne s'exécute pas
Vérifie que ton curseur est dans un bloc délimité par `# %%`

### Exécution bloquée
Fais `<leader>ji` pour interrompre

### Kernel non initialisé
Fais `<leader>mk` manuellement

*Configuré avec ❤️ par Antigravity. Sois attentif aux priorités !*
