# ✅ Plan d'Action - Déploiement des Corrections

## 🎯 Objectif
Corriger le problème de génération de corrections d'exercices dans l'application Flow.

---

## 📋 Checklist de Déploiement

### Phase 1 : Déploiement Backend (mon_api_ia)

#### ✅ Étape 1.1 : Vérifier les Modifications
```bash
cd e:\perso\flutter\flow\mon_api_ia
git status
```

**Fichier modifié :** `app.py`
- Ligne 36-38 : `max_tokens` réduit de 4000 → 1500
- Ligne 36-38 : `temperature` augmentée de 0.1 → 0.2

#### ✅ Étape 1.2 : Tester Localement (Optionnel)
```bash
# Installer les dépendances
pip install -r requirements.txt

# Lancer le serveur local
uvicorn app:app --host 0.0.0.0 --port 7860
```

**Test avec curl :**
```bash
curl -X POST http://localhost:7860/generate \
  -H "Content-Type: application/json" \
  -H "x-api-key: flow_secure_2024" \
  -d '{
    "prompt": "Résoudre 2x + 5 = 15. Réponds en JSON avec is_exam, subject, correction, similar_exercises, pedagogical_advice",
    "task": "correction"
  }'
```

#### ✅ Étape 1.3 : Commit et Push
```bash
git add app.py
git commit -m "fix: Optimisation paramètres correction (max_tokens: 1500, temp: 0.2)"
git push origin main
```

#### ✅ Étape 1.4 : Déployer sur Hugging Face
1. Aller sur https://huggingface.co/spaces/mahamanelawaly/mon-api-ia
2. Vérifier que le push a déclenché un rebuild automatique
3. Attendre 2-3 minutes que le Space redémarre
4. Vérifier le statut : doit être "Running"

---

### Phase 2 : Déploiement Flutter (Application Mobile)

#### ✅ Étape 2.1 : Vérifier les Modifications
```bash
cd e:\perso\flutter\flow
git status
```

**Fichier modifié :** `lib/services/corrector_service.dart`
- Ligne 27-49 : Nouveau prompt simplifié avec exemple

#### ✅ Étape 2.2 : Tester l'Application
```bash
# Lancer l'application
flutter run
```

**Tests à effectuer :**
1. Naviguer vers "Correcteur IA"
2. Prendre une photo d'un exercice simple (ex: "2x + 5 = 15")
3. Vérifier que la correction s'affiche correctement
4. Vérifier le format : "Étape 1: ..., Étape 2: ..., Étape 3: ..."

#### ✅ Étape 2.3 : Vérifier les Logs
Dans la console Flutter, chercher :
```
--- [CorrectorService] Réponse brute reçue ---
```

Vérifier que le JSON est bien formaté.

#### ✅ Étape 2.4 : Commit et Push
```bash
git add lib/services/corrector_service.dart
git commit -m "fix: Simplification prompt correction avec contraintes strictes"
git push origin main
```

---

### Phase 3 : Tests Utilisateur

#### ✅ Test 1 : Équation Simple
**Photo à prendre :**
```
Résoudre : 3x - 7 = 14
```

**Résultat attendu :**
- ✅ Correction en 3-4 étapes
- ✅ Chaque étape claire et concise
- ✅ Pas de LaTeX ou Markdown complexe
- ✅ Exercices similaires proposés

#### ✅ Test 2 : Système d'Équations
**Photo à prendre :**
```
(1) 2x + y = 10
(2) x - y = 2
```

**Résultat attendu :**
- ✅ Méthode de résolution expliquée
- ✅ Étapes numérotées
- ✅ Résultat final correct

#### ✅ Test 3 : Géométrie
**Photo à prendre :**
```
Triangle rectangle : a = 3, b = 4
Calculer c
```

**Résultat attendu :**
- ✅ Théorème de Pythagore mentionné
- ✅ Calcul détaillé
- ✅ Résultat c = 5

---

## 🐛 Debugging en Cas de Problème

### Problème 1 : "Erreur serveur: 401"
**Cause :** Clé API incorrecte

**Solution :**
1. Vérifier dans `corrector_service.dart` ligne 9 : `_apiKey = 'flow_secure_2024'`
2. Vérifier dans `app.py` ligne 10 : `API_KEY = "flow_secure_2024"`

### Problème 2 : "Erreur serveur: 500"
**Cause :** Erreur dans le backend

**Solution :**
1. Aller sur https://huggingface.co/spaces/mahamanelawaly/mon-api-ia
2. Cliquer sur "Logs"
3. Chercher l'erreur Python
4. Corriger et redéployer

### Problème 3 : "Format de réponse invalide"
**Cause :** L'IA n'a pas respecté le format JSON

**Solution :**
1. Vérifier les logs Flutter : `print('--- [CorrectorService] JSON Sanitisé : $sanitizedJson ---')`
2. Si le JSON est mal formaté, ajuster le prompt pour être encore plus strict
3. Réduire encore `max_tokens` si nécessaire (ex: 1200)

### Problème 4 : Timeout
**Cause :** Réponse trop longue

**Solution :**
1. Réduire `max_tokens` à 1000
2. Ajouter dans le prompt : "MAXIMUM 150 MOTS"

---

## 📊 Métriques de Succès

### Avant les Modifications
- ⏱️ Temps de réponse : 15-30 secondes
- ❌ Taux d'échec : ~40%
- 📝 Longueur moyenne : 800-1200 mots

### Objectif Après Modifications
- ⏱️ Temps de réponse : 5-10 secondes
- ✅ Taux de succès : ~85%
- 📝 Longueur moyenne : 150-250 mots

### Comment Mesurer
1. Tester 10 exercices différents
2. Noter le temps de réponse pour chacun
3. Noter si la correction est correcte et bien formatée
4. Calculer le taux de succès

---

## 🚀 Déploiement Rapide (TL;DR)

```bash
# Backend
cd e:\perso\flutter\flow\mon_api_ia
git add app.py
git commit -m "fix: Optimisation correction (tokens: 1500, temp: 0.2)"
git push

# Frontend
cd e:\perso\flutter\flow
git add lib/services/corrector_service.dart
git commit -m "fix: Simplification prompt correction"
git push

# Test
flutter run
# Tester avec un exercice simple
```

---

## 📚 Documentation Créée

Tous les documents sont dans `.analysis/` :

1. **`diagnostic_api_ia.md`** - Analyse complète du problème
2. **`guide_correcteur.md`** - Guide utilisateur pour le correcteur
3. **`guide_communication_ia.md`** - Comment bien interagir avec l'IA
4. **`modifications_summary.md`** - Résumé des modifications
5. **`plan_action.md`** - Ce fichier

---

## ✅ Validation Finale

Avant de considérer le problème résolu, vérifier :

- [ ] Backend déployé sur Hugging Face
- [ ] Application Flutter fonctionne localement
- [ ] Test 1 (équation simple) réussi
- [ ] Test 2 (système) réussi
- [ ] Test 3 (géométrie) réussi
- [ ] Temps de réponse < 10 secondes
- [ ] Pas d'erreurs de parsing
- [ ] Format "Étape 1:, Étape 2:, ..." respecté

---

## 🎯 Prochaines Améliorations (Optionnel)

### Amélioration 1 : Support Multi-Langues
- Adapter le prompt selon la langue de l'utilisateur
- Supporter français, anglais, arabe

### Amélioration 2 : Historique des Corrections
- Sauvegarder les corrections dans une base de données
- Permettre à l'utilisateur de revoir ses anciennes corrections

### Amélioration 3 : Feedback Utilisateur
- Ajouter un bouton "👍 Utile" / "👎 Pas utile"
- Utiliser ces données pour améliorer le prompt

### Amélioration 4 : Mode Détaillé
- Ajouter un toggle "Mode Détaillé" / "Mode Rapide"
- Mode Détaillé : plus d'étapes, plus d'explications
- Mode Rapide : correction minimale (actuel)

---

**Date de création :** 2026-02-16  
**Auteur :** Assistant IA  
**Statut :** ✅ Prêt pour déploiement
