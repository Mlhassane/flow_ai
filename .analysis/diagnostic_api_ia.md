# 🔍 Diagnostic API IA - Problème de Correction vs Quiz

## 📊 Résumé du Problème

**✅ Ce qui fonctionne :** Génération de quiz  
**❌ Ce qui ne fonctionne pas :** Correction d'exercices de maths

---

## 🎯 Analyse Comparative

### 1. **Différences dans les Prompts**

#### 🟢 QUIZ (Fonctionne)
```
AGIS EN TANT QU'EXPERT PÉDAGOGIQUE.
Génère un quiz FLASH de 5 questions.

CONSIGNES DE LISIBILITÉ (CRITIQUE) :
1. PAS DE LATEX
2. NOTATION HUMAINE
3. RÉPONSES COURTES
4. EXPLICATIONS FLASH : Maximum 2 phrases.

FORMAT JSON :
[
  {
    "question": "Texte sans code",
    "answer": "Réponse directe",
    "explanation": "Explication simple"
  }
]
```

**Caractéristiques :**
- ✅ Prompt court et direct
- ✅ Demande un tableau JSON simple `[]`
- ✅ Consignes claires et concises
- ✅ Limite explicite : "Maximum 2 phrases"
- ✅ Structure JSON simple (3 champs seulement)

#### 🔴 CORRECTION (Ne fonctionne pas)
```
### PERSONA : TU ES UN PROFESSEUR EXPERT ET PASSIONNÉ AU TABLEAU.

### TA MISSION :
Analyse l'image. S'il s'agit d'une épreuve, corrige-la au tableau avec pédagogie.

### RÈGLES DE LISIBILITÉ (STRICTES) :
1. PAS DE LATEX
2. NOTATION HUMAINE
3. STYLE : Décompose les calculs clairs
4. FORMAT : Sois structuré avec du Markdown simple.

### FORMAT JSON (STRICT) :
{
  "is_exam": true,
  "subject": "MATIERE",
  "correction": "# TITRE\\n\\n## Analyse\\n...\\n## Résolution\\n...",
  "similar_exercises": ["Exo 1", "Exo 2"],
  "pedagogical_advice": "Conseil."
}
```

**Problèmes identifiés :**
- ⚠️ Prompt plus long et complexe
- ⚠️ Demande un objet JSON `{}` avec structure imbriquée
- ⚠️ Demande du Markdown formaté dans le JSON
- ⚠️ Pas de limite de longueur explicite
- ⚠️ Tâche plus complexe : "corrige-la au tableau avec pédagogie"
- ⚠️ 5 champs dont certains complexes (correction avec Markdown)

---

### 2. **Différences dans les Paramètres API**

| Paramètre | QUIZ | CORRECTION |
|-----------|------|------------|
| `max_tokens` | 1000 | 4000 |
| `temperature` | 0.2 | 0.1 |
| `task` | "quiz" | "correction" |

**Observation :** La correction demande 4x plus de tokens, ce qui peut causer des timeouts ou des réponses incomplètes.

---

### 3. **Complexité du Parsing**

#### QUIZ
```dart
// Extraction simple d'un tableau
int startIdx = content.indexOf('[');
int endIdx = content.lastIndexOf(']');
String jsonRaw = content.substring(startIdx, endIdx + 1);
```

#### CORRECTION
```dart
// Extraction d'un objet
int startIdx = content.indexOf('{');
int endIdx = content.lastIndexOf('}');
String jsonRaw = content.substring(startIdx, endIdx + 1);

// Puis parsing complexe avec nettoyage LaTeX
// + Algorithme de "suture" pour les backslashes
```

---

## 🐛 Causes Probables de l'Échec

### 1. **Prompt Trop Ambitieux**
Le prompt de correction demande :
- Une analyse complète de l'image
- Une correction pédagogique détaillée
- Du Markdown structuré
- Des exercices similaires
- Des conseils pédagogiques

**Résultat :** L'IA génère une réponse trop longue, mal formatée, ou incomplète.

### 2. **Format JSON Complexe**
- Le champ `correction` contient du Markdown avec `\n`, ce qui complique le JSON
- Les backslashes dans le Markdown causent des problèmes de parsing
- L'algorithme de "suture" peut échouer si le format n'est pas parfait

### 3. **Manque de Contraintes**
- Pas de limite de longueur pour la correction
- Pas de structure imposée pour le Markdown
- L'IA peut diverger et générer du contenu non-JSON

---

## 💡 Solutions Recommandées

### ✅ Solution 1 : Simplifier le Prompt de Correction

**Avant :**
```
Analyse l'image. S'il s'agit d'une épreuve, corrige-la au tableau avec pédagogie.
```

**Après :**
```
Analyse cette épreuve et fournis une correction CONCISE.

RÈGLES STRICTES :
1. Correction en 3-5 étapes maximum
2. Chaque étape = 1 phrase courte
3. PAS de Markdown complexe (pas de #, ##)
4. Utilise des numéros simples : (1), (2), (3)
5. Maximum 200 mots pour la correction
```

### ✅ Solution 2 : Simplifier le Format JSON

**Avant :**
```json
{
  "correction": "# TITRE\\n\\n## Analyse\\n..."
}
```

**Après :**
```json
{
  "correction": "Étape 1: ... Étape 2: ... Étape 3: ..."
}
```

### ✅ Solution 3 : Réduire max_tokens

**Avant :** `max_tokens = 4000`  
**Après :** `max_tokens = 1500`

**Raison :** Forcer l'IA à être concise évite les réponses trop longues et mal formatées.

### ✅ Solution 4 : Ajouter un Exemple dans le Prompt

```
EXEMPLE DE RÉPONSE ATTENDUE :
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: Identifier l'équation. Étape 2: Isoler x. Étape 3: Calculer x = 5.",
  "similar_exercises": ["Résoudre 3x + 7 = 22", "Résoudre 2x - 4 = 10"],
  "pedagogical_advice": "Toujours vérifier ta solution en remplaçant x dans l'équation."
}
```

---

## 🎯 Comment Améliorer Votre Interaction avec l'Appli

### ❌ Mauvaise Pratique
- Prendre une photo d'une épreuve complète avec 5-10 exercices
- Attendre une correction détaillée de tout
- Utiliser des images floues ou mal cadrées

### ✅ Bonne Pratique
1. **Une question à la fois** : Prenez une photo d'UN SEUL exercice
2. **Image claire** : Assurez-vous que le texte est lisible
3. **Cadrage serré** : Évitez les informations inutiles autour
4. **Niveau indiqué** : Assurez-vous que votre niveau est bien configuré dans le profil

### 📸 Exemple de Bonne Photo
```
✅ Photo centrée sur 1 exercice
✅ Texte net et lisible
✅ Bon éclairage
✅ Pas de reflets
```

---

## 🔧 Modifications à Apporter

### 1. Dans `corrector_service.dart`

**Ligne 27-49 : Nouveau Prompt**
```dart
final prompt = """
Tu es un correcteur IA. Analyse cette épreuve et fournis une correction CONCISE.

RÈGLES STRICTES :
1. Correction en 3-5 étapes numérotées
2. Chaque étape = 1 phrase courte
3. PAS de Markdown (pas de #, ##, *, -)
4. Utilise : Étape 1:, Étape 2:, etc.
5. Maximum 200 mots pour la correction

EXEMPLE :
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On identifie l'équation 2x + 5 = 15. Étape 2: On soustrait 5 des deux côtés pour obtenir 2x = 10. Étape 3: On divise par 2 pour trouver x = 5.",
  "similar_exercises": ["Résoudre 3x + 7 = 22", "Résoudre x - 4 = 10"],
  "pedagogical_advice": "Vérifie toujours ta solution en la remplaçant dans l'équation."
}

FORMAT JSON (STRICT) :
{
  "is_exam": true ou false,
  "subject": "MATIERE",
  "correction": "Étape 1: ... Étape 2: ...",
  "similar_exercises": ["Exo 1", "Exo 2"],
  "pedagogical_advice": "Conseil court."
}
""";
```

### 2. Dans `app.py` (Backend)

**Ligne 36-38 : Réduire max_tokens**
```python
if query.task == "correction":
    current_max_tokens = 1500  # Au lieu de 4000
    current_temp = 0.2  # Au lieu de 0.1 (un peu plus de créativité)
```

---

## 📈 Résultat Attendu

Après ces modifications :
- ✅ Réponses plus courtes et plus fiables
- ✅ JSON plus facile à parser
- ✅ Moins de timeouts
- ✅ Corrections plus claires et directes
- ✅ Meilleure expérience utilisateur

---

## 🧪 Test Recommandé

1. Prendre une photo d'un exercice simple (ex: "Résoudre 2x + 5 = 15")
2. Vérifier que la réponse JSON est bien formatée
3. Vérifier que la correction est concise (3-5 étapes)
4. Tester avec différents types d'exercices (algèbre, géométrie, etc.)

---

**Date :** 2026-02-16  
**Auteur :** Diagnostic automatique
