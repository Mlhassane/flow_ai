# 🧪 Tests de Validation - Correcteur IA

## 📋 Scénarios de Test

### Test 1 : Équation Linéaire Simple ⭐
**Niveau :** Facile  
**Type :** Algèbre

**Photo à prendre :**
```
Résoudre : 2x + 5 = 15
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On soustrait 5 des deux côtés de l'équation pour obtenir 2x = 10. Étape 2: On divise par 2 pour isoler x. Étape 3: On obtient x = 5. Étape 4: Vérification en remplaçant x par 5 dans l'équation originale donne 2(5) + 5 = 15, ce qui est correct.",
  "similar_exercises": [
    "Résoudre 3x + 7 = 22",
    "Résoudre 5x - 3 = 17",
    "Résoudre x/2 + 1 = 4"
  ],
  "pedagogical_advice": "Toujours vérifier ta solution en la remplaçant dans l'équation de départ pour s'assurer qu'elle est correcte."
}
```

**Critères de validation :**
- ✅ Temps de réponse < 10 secondes
- ✅ Format JSON valide
- ✅ 3-5 étapes numérotées
- ✅ Pas de LaTeX
- ✅ Exercices similaires pertinents

---

### Test 2 : Système d'Équations ⭐⭐
**Niveau :** Moyen  
**Type :** Algèbre

**Photo à prendre :**
```
Résoudre le système :
(1) 2x + y = 10
(2) x - y = 2
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On additionne les équations (1) et (2) pour éliminer y, ce qui donne 3x = 12. Étape 2: On divise par 3 pour obtenir x = 4. Étape 3: On remplace x = 4 dans l'équation (2) pour trouver 4 - y = 2, donc y = 2. Étape 4: Vérification dans (1) donne 2(4) + 2 = 10, ce qui est correct.",
  "similar_exercises": [
    "Résoudre x + y = 7 et x - y = 3",
    "Résoudre 3x + 2y = 12 et x - y = 1",
    "Résoudre 2x - y = 5 et x + y = 4"
  ],
  "pedagogical_advice": "La méthode par addition est efficace quand les coefficients d'une variable sont opposés ou peuvent le devenir facilement."
}
```

**Critères de validation :**
- ✅ Méthode de résolution claire
- ✅ Étapes logiques
- ✅ Vérification incluse
- ✅ Exercices similaires avec systèmes

---

### Test 3 : Géométrie - Pythagore ⭐⭐
**Niveau :** Moyen  
**Type :** Géométrie

**Photo à prendre :**
```
Triangle ABC rectangle en A
AB = 3 cm
AC = 4 cm
Calculer BC
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: Le triangle est rectangle en A, donc on applique le théorème de Pythagore BC² = AB² + AC². Étape 2: On calcule BC² = 3² + 4² = 9 + 16 = 25. Étape 3: On prend la racine carrée pour obtenir BC = 5 cm.",
  "similar_exercises": [
    "Calculer l'hypoténuse si a = 5 et b = 12",
    "Calculer un côté si c = 10 et b = 6",
    "Triangle rectangle avec a = 8 et b = 15"
  ],
  "pedagogical_advice": "Le théorème de Pythagore ne s'applique qu'aux triangles rectangles. Vérifie toujours que l'angle droit est bien indiqué."
}
```

**Critères de validation :**
- ✅ Théorème correctement identifié
- ✅ Calculs détaillés
- ✅ Unités mentionnées
- ✅ Conseil sur l'application du théorème

---

### Test 4 : Fraction ⭐
**Niveau :** Facile  
**Type :** Arithmétique

**Photo à prendre :**
```
Simplifier : 12/18
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On cherche le PGCD de 12 et 18, qui est 6. Étape 2: On divise le numérateur et le dénominateur par 6. Étape 3: On obtient 12÷6 / 18÷6 = 2/3.",
  "similar_exercises": [
    "Simplifier 15/25",
    "Simplifier 24/36",
    "Simplifier 8/12"
  ],
  "pedagogical_advice": "Pour simplifier une fraction, divise le numérateur et le dénominateur par leur PGCD (Plus Grand Commun Diviseur)."
}
```

---

### Test 5 : Développement ⭐⭐
**Niveau :** Moyen  
**Type :** Algèbre

**Photo à prendre :**
```
Développer : (x + 3)(x - 2)
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On applique la distributivité (double distribution). Étape 2: x × x = x², x × (-2) = -2x, 3 × x = 3x, 3 × (-2) = -6. Étape 3: On additionne tous les termes pour obtenir x² - 2x + 3x - 6. Étape 4: On réduit pour obtenir x² + x - 6.",
  "similar_exercises": [
    "Développer (x + 5)(x - 1)",
    "Développer (2x + 1)(x - 3)",
    "Développer (x - 4)(x + 2)"
  ],
  "pedagogical_advice": "Pense à la méthode FOIL (First, Outer, Inner, Last) pour ne rien oublier lors de la double distribution."
}
```

---

### Test 6 : Pourcentage ⭐
**Niveau :** Facile  
**Type :** Arithmétique

**Photo à prendre :**
```
Calculer 20% de 150
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: Pour calculer 20% de 150, on multiplie 150 par 20/100. Étape 2: On calcule 150 × 0,20 = 30. Étape 3: Donc 20% de 150 = 30.",
  "similar_exercises": [
    "Calculer 15% de 200",
    "Calculer 25% de 80",
    "Calculer 30% de 120"
  ],
  "pedagogical_advice": "Pour calculer un pourcentage, multiplie le nombre par le pourcentage divisé par 100, ou multiplie par la forme décimale (20% = 0,20)."
}
```

---

### Test 7 : Inéquation ⭐⭐
**Niveau :** Moyen  
**Type :** Algèbre

**Photo à prendre :**
```
Résoudre : 3x - 5 > 10
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On ajoute 5 des deux côtés pour obtenir 3x > 15. Étape 2: On divise par 3 (nombre positif, donc le sens de l'inégalité ne change pas). Étape 3: On obtient x > 5.",
  "similar_exercises": [
    "Résoudre 2x + 3 < 11",
    "Résoudre 5x - 7 ≥ 13",
    "Résoudre -2x + 4 > 8"
  ],
  "pedagogical_advice": "Attention : quand on multiplie ou divise par un nombre négatif, il faut inverser le sens de l'inégalité."
}
```

---

### Test 8 : Aire ⭐
**Niveau :** Facile  
**Type :** Géométrie

**Photo à prendre :**
```
Calculer l'aire d'un rectangle
Longueur = 8 cm
Largeur = 5 cm
```

**Résultat attendu :**
```json
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: L'aire d'un rectangle se calcule avec la formule Aire = Longueur × Largeur. Étape 2: On multiplie 8 × 5 = 40. Étape 3: L'aire est donc 40 cm².",
  "similar_exercises": [
    "Calculer l'aire d'un rectangle 12 cm × 7 cm",
    "Calculer l'aire d'un carré de côté 6 cm",
    "Calculer l'aire d'un rectangle 15 cm × 4 cm"
  ],
  "pedagogical_advice": "N'oublie pas d'indiquer l'unité au carré (cm², m², etc.) pour une aire."
}
```

---

## 📊 Grille d'Évaluation

Pour chaque test, vérifier :

| Critère | Poids | Validation |
|---------|-------|------------|
| Temps de réponse < 10s | 10% | ⬜ |
| JSON valide | 20% | ⬜ |
| 3-5 étapes | 15% | ⬜ |
| Étapes claires | 20% | ⬜ |
| Pas de LaTeX | 10% | ⬜ |
| Exercices similaires pertinents | 15% | ⬜ |
| Conseil pédagogique utile | 10% | ⬜ |

**Score de réussite :** ≥ 85%

---

## 🎯 Tests de Régression

### Cas Limites à Tester

#### Test 9 : Photo Floue
**Objectif :** Vérifier la gestion d'erreur
**Résultat attendu :** Message d'erreur clair ou demande de reprendre la photo

#### Test 10 : Exercice Trop Long
**Photo :** Démonstration mathématique de 15 lignes
**Résultat attendu :** Correction partielle ou message suggérant de diviser l'exercice

#### Test 11 : Pas un Exercice
**Photo :** Image d'un chat
**Résultat attendu :** `"is_exam": false` avec message approprié

---

## 📝 Rapport de Test

### Modèle de Rapport

```markdown
## Test [Numéro] - [Nom du Test]
**Date :** [Date]
**Testeur :** [Nom]

### Résultat
- ✅ / ❌ Succès
- Temps de réponse : [X] secondes
- Score : [X]%

### Observations
[Notes sur le comportement]

### Problèmes Identifiés
[Liste des problèmes]

### Recommandations
[Suggestions d'amélioration]
```

---

## 🚀 Automatisation (Futur)

### Script de Test Automatique
```python
# test_corrector.py
import requests
import base64
import json

def test_correction(image_path, expected_subject):
    with open(image_path, 'rb') as f:
        image_b64 = base64.b64encode(f.read()).decode()
    
    response = requests.post(
        'https://mahamanelawaly-mon-api-ia.hf.space/generate',
        headers={'x-api-key': 'flow_secure_2024'},
        json={
            'prompt': '[Prompt de correction]',
            'image': image_b64,
            'task': 'correction'
        }
    )
    
    result = response.json()
    # Assertions...
    assert result['subject'] == expected_subject
    # etc.
```

---

**Date de création :** 2026-02-16  
**Version :** 1.0  
**Statut :** Prêt pour tests manuels
