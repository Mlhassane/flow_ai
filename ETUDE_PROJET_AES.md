# 📋 ÉTUDE DE PROJET — Flow pour l'Alliance des États du Sahel (AES)

**Date :** 21 Février 2026  
**Auteur :** Équipe Flow  
**Version :** 1.0  
**Cible :** Mali 🇲🇱 · Burkina Faso 🇧🇫 · Niger 🇳🇪

---

## 📑 TABLE DES MATIÈRES

1. [Résumé Exécutif](#1--résumé-exécutif)
2. [Analyse de l'Application Flow](#2--analyse-de-lapplication-flow)
3. [Contexte Éducatif des Pays AES](#3--contexte-éducatif-des-pays-aes)
4. [Opportunité de Marché](#4--opportunité-de-marché)
5. [Adaptations Nécessaires](#5--adaptations-nécessaires)
6. [Modèle Économique](#6--modèle-économique)
7. [Architecture Technique & Déploiement](#7--architecture-technique--déploiement)
8. [Stratégie de Lancement](#8--stratégie-de-lancement)
9. [Risques & Mitigation](#9--risques--mitigation)
10. [Budget Estimé](#10--budget-estimé)
11. [Calendrier Prévisionnel](#11--calendrier-prévisionnel)
12. [Conclusion](#12--conclusion)

---

## 1. 🎯 RÉSUMÉ EXÉCUTIF

**Flow** est une application mobile éducative propulsée par l'IA, conçue en **Flutter** (multiplateforme Android/iOS/Web). Elle permet aux élèves de :

- 📸 **Créer des quiz** automatiquement à partir de photos de cours
- 🧠 **Réviser intelligemment** grâce à la répétition espacée (algorithme SM-2)
- 🤖 **Consulter un Tuteur IA** pour poser des questions pédagogiques
- ✅ **Corriger des épreuves** automatiquement via l'IA
- 📚 **Gérer une bibliothèque** de fiches et quiz

L'objectif est de **proposer Flow comme outil éducatif numérique aux 3 pays de l'AES** (Mali, Burkina Faso, Niger), pour accompagner la souveraineté éducative et la modernisation des systèmes scolaires dans la région.

---

## 2. 📱 ANALYSE DE L'APPLICATION FLOW

### 2.1 Stack Technique Actuelle

| Composant | Technologie |
|-----------|-------------|
| **Framework** | Flutter (Dart) — SDK ^3.10.4 |
| **Plateformes** | Android, iOS, Web, Windows, macOS, Linux |
| **IA Backend** | API Hugging Face privée (`mon-api-ia`) |
| **State Management** | Provider |
| **Stockage local** | SharedPreferences |
| **Traitement d'images** | image_picker + image (compression) |
| **IA Générative** | Google Generative AI (Gemini) |
| **Animations** | flutter_animate |
| **Typographie** | Google Fonts |
| **i18n** | intl (internationalisation) |

### 2.2 Fonctionnalités Existantes

#### 🏠 Accueil (HomeScreen)
- Salutation personnalisée
- Système de **streak** (série de jours consécutifs)
- Section de **révision générale** avec cartes dues
- Grille d'outils : Créer Quiz, Mes Quiz, Tuteur IA, Correcteur
- Animations fluides et design premium

#### 📸 Création de Quiz (CreateScreen)
- Capture photo depuis la caméra ou la galerie
- **Envoi à l'IA** pour génération automatique de questions
- Compression d'image côté client
- Sauvegarde dans des decks (QuizDeck)
- Configurable : nombre de questions, niveau scolaire

#### 🎯 Quiz & Révision (QuizScreen / FlashcardReviewScreen)
- Mode quiz interactif avec cartes recto/verso
- Évaluation de la qualité de rappel (oublié / difficile / bien / facile)
- **Algorithme SM-2 (Spaced Repetition)** pour planifier les révisions
- Suivi des résultats et progression

#### 🤖 Tuteur IA (TutorScreen)
- Chat conversationnel avec une IA pédagogue
- Persona adaptée : guide par le raisonnement, ne donne pas la réponse
- Adapté au niveau scolaire de l'élève

#### ✅ Correcteur (CorrectorScreen)
- Photo d'une épreuve → correction automatique par IA
- Affichage structuré des résultats
- Notation et explications

#### 📚 Bibliothèque (LibraryScreen)
- Organisation des decks par matière
- Visualisation des flashcards
- Gestion complète (création, suppression)

#### 🎓 Onboarding
- Écran d'introduction au premier lancement
- Design immersif avec animations

### 2.3 Modèle de Données

```
User → id, name, level, coins, streak, badges, subjectProgress
QuizCard → id, question, answer, explanation, repetitions, easeFactor, interval, nextReview
QuizDeck → id, name, cards[]
Flashcard → id, front, back
Correction → result structured data
```

### 2.4 Forces de Flow

| Force | Détail |
|-------|--------|
| ✅ **Offline-first** | Stockage local, fonctionne sans internet constant |
| ✅ **IA intégrée** | Génération automatique de contenu pédagogique |
| ✅ **Multiplateforme** | Android + iOS + Web depuis un seul codebase |
| ✅ **Design soigné** | UI/UX premium, animations fluides |
| ✅ **Algorithme SM-2** | Méthode de révision scientifiquement prouvée |
| ✅ **En français** | Déjà adapté au contexte francophone |
| ✅ **Léger** | Pas de dépendances lourdes |

---

## 3. 🌍 CONTEXTE ÉDUCATIF DES PAYS AES

### 3.1 Données Clés

| Indicateur | 🇲🇱 Mali | 🇧🇫 Burkina Faso | 🇳🇪 Niger |
|------------|---------|-----------------|---------|
| **Population** | ~22M | ~22M | ~26M |
| **Population < 25 ans** | ~67% | ~65% | ~70% |
| **Taux d'alphabétisation** | ~35% | ~41% | ~35% |
| **Taux de scolarisation primaire** | ~75% | ~70% | ~62% |
| **Taux de scolarisation secondaire** | ~38% | ~30% | ~18% |
| **Ratio élève/enseignant** | ~50:1 | ~55:1 | ~40:1 |
| **Pénétration smartphone** | ~35% | ~40% | ~30% |
| **Réseau mobile** | 2G/3G dominant | 3G/4G en villes | 2G/3G dominant |
| **Langue officielle** | Français | Français | Français |
| **Langues nationales** | Bambara, Peul, Songhaï... | Mooré, Dioula, Peul... | Haoussa, Zarma, Peul... |
| **Système scolaire** | Français (bac) | Français (bac) | Français (bac) |

### 3.2 Défis Éducatifs Communs

1. **Pénurie d'enseignants qualifiés** → Ratio élève/enseignant très élevé
2. **Manque de manuels scolaires** → Les élèves copient les cours au tableau
3. **Insécurité dans certaines zones** → Fermeture d'écoles (>8000 au Sahel)
4. **Coût des cours particuliers** → Inaccessible pour la majorité
5. **Examen national enjeu crucial** → BAC, DEF, BEPC = passeport social
6. **Faible connectivité internet** → Zones rurales souvent en 2G
7. **Coupures d'électricité fréquentes** → Impact sur le chargement des appareils

### 3.3 Opportunités

- 📱 **Forte adoption du mobile** parmi les jeunes
- 🇫🇷 **Système francophone** → Flow est déjà en français
- 📖 **Culture de la copie de cours** → La photo de cours est un usage naturel !
- 🎓 **Volonté politique de souveraineté** → L'AES cherche des solutions africaines
- 💰 **Mobile Money très répandu** (Orange Money, Moov Money, Airtel Money)

---

## 4. 📊 OPPORTUNITÉ DE MARCHÉ

### 4.1 Marché Adressable

| Segment | Estimation |
|---------|------------|
| **Élèves secondaire (3 pays)** | ~6 millions |
| **Étudiants universitaires** | ~500 000 |
| **Élèves avec smartphone** | ~2 millions |
| **Cible réaliste Année 1** | 50 000 — 100 000 utilisateurs |
| **Cible Année 3** | 500 000 — 1 000 000 utilisateurs |

### 4.2 Concurrence

| Concurrent | Faiblesse vs Flow |
|------------|-------------------|
| **Duolingo** | Langues uniquement, pas adapté au cursus local |
| **Khan Academy** | En anglais, vidéos lourdes, nécessite bonne connexion |
| **Quizlet** | Pas d'IA, pas d'adaptation locale, payant |
| **Cours particuliers** | Chers (5000-15000 FCFA/h), limités géographiquement |
| **YouTube** | Consomme beaucoup de data, pas interactif |
| **Manuels papier** | Chers, pas toujours disponibles |

### 4.3 Avantage Concurrentiel de Flow

> **Flow est la seule application qui transforme une simple photo de cours en quiz interactif grâce à l'IA, avec un mode offline, dans un contexte 100% francophone et adapté au cursus AES.**

---

## 5. 🔧 ADAPTATIONS NÉCESSAIRES

### 5.1 Adaptations Haute Priorité (Phase 1)

#### A. Contenu Pédagogique Localisé
```
📌 Adapter les matières au programme scolaire de chaque pays :
   - Mali : Programme malien (DEF, Bac)
   - Burkina Faso : Programme burkinabè (BEPC, Bac)  
   - Niger : Programme nigérien (BEPC, Bac)
   
📌 Niveaux scolaires à intégrer :
   - 6ème → 3ème (Collège / DEF / BEPC)
   - 2nde → Terminale (Lycée / Bac)
   - Séries : Scientifique, Littéraire, Économique
```

#### B. Mode Offline Renforcé
```dart
// Fonctionnalités à développer :
- Téléchargement de packs de contenu pour usage hors-ligne
- Mise en cache agressive des quiz générés
- Synchronisation différée quand la connexion revient
- Taille APK optimisée (< 30 MB)
- Compression maximale des données
```

#### C. Optimisation Réseau
```
📌 Gestion des connexions lentes (2G/3G) :
   - Compression d'images plus agressive avant envoi
   - Timeouts adaptés (60s au lieu de 30s)
   - Retry automatique intelligent
   - Mode "économie de data"
   - Indicateur de consommation de données
```

#### D. Multi-niveaux Scolaires
```
Adapter le modèle User pour inclure :
- Pays (ML, BF, NE)
- Système (DEF/BEPC/Bac)
- Classe (6ème → Terminale)
- Série (S, L, SE, etc.)
- Matières selon le cursus
```

### 5.2 Adaptations Moyenne Priorité (Phase 2)

#### E. Langues Locales (partiel)
```
Interface en français (priorité) + éléments en langues locales :
- Bambara (Mali) — pour notifications et encouragements
- Mooré (Burkina Faso) — pour notifications et encouragements
- Haoussa (Niger) — pour notifications et encouragements
→ Les contenus académiques restent en français (langue d'enseignement)
```

#### F. Système de Gamification Culturelle
```
- Monnaie virtuelle : "Cauris" (coquillages traditionnels) → déjà intégré !
- Badges culturels : Griot (maître des connaissances), Sage, etc.
- Classements par école, ville, pays
- Défis entre écoles
```

#### G. Communauté & Partage
```
- Partage de fiches entre élèves
- Groupes d'étude par classe/école
- Fiches de révision créées par la communauté
- Système de validation par les enseignants
```

#### H. Mode Examen
```
- Sujets types BAC/BEPC/DEF par pays
- Conditions d'examen simulées (chrono, no-cheating)
- Corrigés détaillés par l'IA
- Statistiques de préparation
```

### 5.3 Adaptations Basse Priorité (Phase 3)

#### I. Intégration Mobile Money
```
- Orange Money (Mali, BF, Niger)
- Moov Money (BF, Niger)
- Airtel Money (Niger)
→ Pour : abonnements premium, achat de crédits IA
```

#### J. Mode Enseignant
```
- Dashboard pour les professeurs
- Création de quiz pour la classe
- Suivi de progression des élèves
- Distribution de contenu
```

#### K. Mode Radio/Audio
```
Pour les zones à faible connectivité :
- Résumés audio des fiches
- Quiz audio (question lue → réponse vocale)
- Intégration avec les radios scolaires locales
```

---

## 6. 💰 MODÈLE ÉCONOMIQUE

### 6.1 Freemium Adapté au Contexte Sahélien

| Offre | Prix | Fonctionnalités |
|-------|------|----------------|
| **🆓 Flow Gratuit** | 0 FCFA | 5 quiz/mois via IA, révision illimitée, tuteur IA (3 questions/jour) |
| **⭐ Flow Étudiant** | 500 FCFA/mois (~0.75€) | Quiz illimités, tuteur illimité, correcteur |
| **🏫 Flow École** | 2 000 FCFA/élève/an | Licence école, dashboard enseignant, contenu personnalisé |
| **🏛️ Flow Ministère** | Sur devis | Déploiement national, contenu officiel, reporting |

### 6.2 Sources de Revenus

```
1. Abonnements individuels (B2C)          → 30%
2. Licences écoles privées (B2B)          → 20%
3. Contrats ministériels (B2G)            → 35%
4. Partenariats ONG/Bailleurs (B2D)       → 15%
   - UNESCO, UNICEF, AFD, Banque Mondiale
   - Fondations éducatives
```

### 6.3 Modèle pour le B2G (Gouvernements AES)

> **Proposition de valeur aux Ministères de l'Éducation :**

```
"Flow permet de pallier le manque d'enseignants et de manuels 
en donnant à chaque élève un tuteur IA personnel, accessible 
même hors-ligne, adapté au programme national."

📊 KPIs proposés :
- Taux d'utilisation par école
- Amélioration des résultats aux examens
- Réduction du taux d'échec
- Couverture géographique
```

---

## 7. ⚙️ ARCHITECTURE TECHNIQUE & DÉPLOIEMENT

### 7.1 Architecture Cible

```
┌─────────────────────────────────────────────────────┐
│                   UTILISATEURS                       │
│   Android (priorité) │ iOS │ Web (tablettes écoles) │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │   CDN Africain   │  (Cloudflare / local)
              │   Cache API      │
              └────────┬────────┘
                       │
          ┌────────────▼────────────┐
          │   API Gateway (Sahel)    │
          │   Serveur régional       │
          │   Dakar / Abidjan        │
          └────────────┬────────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
┌───▼───┐      ┌──────▼──────┐    ┌──────▼──────┐
│ AI API │      │ User Service │    │ Content DB  │
│ (HF)  │      │ Auth/Profils │    │ Quiz/Fiches │
└───────┘      └─────────────┘    └─────────────┘
```

### 7.2 Optimisations pour le Sahel

```
1. APK Lite (< 25 MB) → Android Go compatible
2. Compression d'images : JPEG quality 40% avant envoi
3. Cache offline : SQLite local + Hive pour les données
4. API Retry : exponential backoff adapté aux réseaux instables
5. Mode économie de data : texte seul, pas d'images inutiles
6. Serveur proxy régional : réduire la latence
7. Support Android 5.0+ (couvre ~95% des appareils au Sahel)
```

### 7.3 Distribution

```
📱 Google Play Store        → Principal canal
📦 APK Direct               → Via site web, WhatsApp, Bluetooth
🌐 Web App (PWA)            → Pour les tablettes des écoles
🏪 Magasins locaux          → Pré-installation sur téléphones reconditionnés
```

---

## 8. 🚀 STRATÉGIE DE LANCEMENT

### 8.1 Phase Pilote (Mois 1-3)

```
📍 Cibles : 
   - 5 écoles à Bamako (Mali)
   - 5 écoles à Ouagadougou (Burkina Faso)
   - 5 écoles à Niamey (Niger)

👥 Utilisateurs pilotes : 500-1000 élèves
📊 Objectif : Valider l'adoption et mesurer l'impact
🤝 Partenaires : Associations d'enseignants, directeurs d'école
```

### 8.2 Phase Croissance (Mois 4-12)

```
📍 Expansion : Capitales + grandes villes secondaires
   - Mali : Bamako, Sikasso, Mopti, Ségou
   - BF : Ouaga, Bobo-Dioulasso, Koudougou
   - Niger : Niamey, Maradi, Zinder, Tahoua

📱 Objectif : 50 000 utilisateurs
🏫 Objectif : 100 écoles partenaires
```

### 8.3 Phase Échelle (Année 2-3)

```
📍 Couverture nationale dans les 3 pays
🏛️ Partenariats avec les Ministères de l'Éducation
🌍 Extension possible : Guinée, Tchad, Sénégal
📱 Objectif : 500 000+ utilisateurs
```

### 8.4 Canaux de Communication

| Canal | Stratégie |
|-------|-----------|
| **WhatsApp** | Groupes scolaires, partage viral de l'APK |
| **Facebook** | Publicités ciblées jeunes, pages de matières |
| **TikTok** | Vidéos courtes "Comment j'ai eu 18/20 avec Flow" |
| **Radios locales** | Spots publicitaires, émissions éducatives |
| **Écoles** | Ambassadeurs étudiants, affiches dans les établissements |
| **Mosquées/Églises** | Annonces communautaires (sensibilisation parents) |
| **Marchés** | Présence physique lors des rentrées scolaires |

---

## 9. ⚠️ RISQUES & MITIGATION

| # | Risque | Impact | Probabilité | Mitigation |
|---|--------|--------|-------------|------------|
| 1 | **Connexion internet limitée** | Élevé | Élevée | Mode offline renforcé, cache agressif |
| 2 | **Faible pénétration smartphone** | Élevé | Moyenne | Partenariats opérateurs, téléphones subventionnés, version Web |
| 3 | **Résistance culturelle au numérique** | Moyen | Moyenne | Sensibilisation parents/enseignants, résultats prouvés |
| 4 | **Instabilité politique/sécuritaire** | Élevé | Moyenne | Application offline, pas de dépendance à une infrastructure locale |
| 5 | **Coût des data mobiles** | Moyen | Élevée | Mode économie, partenariat opérateurs pour data gratuite ("zero-rating") |
| 6 | **Coupures d'électricité** | Moyen | Élevée | App légère, faible consommation batterie |
| 7 | **Concurrence future** | Faible | Faible | First-mover advantage, adaptation locale |
| 8 | **Piratage de l'APK** | Faible | Moyenne | Fonctionnalités IA nécessitent un compte, valeur côté serveur |
| 9 | **Qualité de l'IA sur contenus locaux** | Moyen | Moyenne | Fine-tuning sur les programmes scolaires AES, validation humaine |
| 10 | **Réglementation des données** | Moyen | Faible | Conformité RGPD + lois locales, hébergement régional |

---

## 10. 💵 BUDGET ESTIMÉ

### 10.1 Phase Pilote (3 mois)

| Poste | Coût (FCFA) | Coût (€) |
|-------|-------------|----------|
| Développement (adaptations) | 3 000 000 | 4 575 |
| Hébergement API (3 mois) | 500 000 | 760 |
| Marketing pilote | 500 000 | 760 |
| Déplacements (3 pays) | 1 500 000 | 2 285 |
| Communication / Branding | 300 000 | 457 |
| **TOTAL Phase Pilote** | **5 800 000** | **~8 840** |

### 10.2 Phase Croissance (12 mois)

| Poste | Coût (FCFA) | Coût (€) |
|-------|-------------|----------|
| Développement (nouvelles features) | 12 000 000 | 18 300 |
| Hébergement API (scaling) | 3 000 000 | 4 575 |
| Marketing digital + terrain | 5 000 000 | 7 620 |
| Équipe locale (3 community managers) | 7 200 000 | 10 975 |
| Partenariats écoles | 2 000 000 | 3 050 |
| Juridique / Enregistrement | 1 000 000 | 1 525 |
| **TOTAL Phase Croissance** | **30 200 000** | **~46 045** |

### 10.3 Sources de Financement Potentielles

```
🏦 Fonds souverains AES         → Souveraineté numérique/éducative
🌍 UNESCO / UNICEF              → Programme éducation numérique
🇪🇺 Union Européenne            → Fonds EuropeAid / éducation Sahel
🏢 Orange Digital Center        → Soutien startups tech africaines
🇹🇷 TIKA (Turquie)              → Coopération éducative
🇷🇺 Rossotrudnichestvo          → Coopération avec les pays AES
🇨🇳 Fondation Jack Ma           → Afrique entrepreneur
💰 Investisseurs impact         → EdTech Afrique
🏦 Banques de développement     → BAD, BOAD
```

---

## 11. 📅 CALENDRIER PRÉVISIONNEL

```
2026
═══════════════════════════════════════════════════════════════════

Mars-Avril        │ 🔧 Adaptations techniques
                  │    - Mode offline renforcé
                  │    - Support programmes scolaires AES
                  │    - Optimisation réseau/APK
                  │
Mai               │ 🧪 Tests internes + Beta fermée
                  │    - 50 beta-testeurs (élèves + enseignants)
                  │    - Collecte de feedback
                  │
Juin              │ 🚀 Lancement Pilote
                  │    - 15 écoles (5 par pays)
                  │    - Événement de lancement dans chaque capitale
                  │
Juillet-Sept      │ 📊 Mesure d'impact + itérations
(Vacances)        │    - Analyse des données d'usage
                  │    - Corrections et améliorations
                  │    - Préparation contenu rentrée
                  │
Octobre           │ 🏫 Rentrée scolaire = Grand lancement
                  │    - Expansion 100 écoles
                  │    - Campagne marketing nationale
                  │    - Partenariats enseignants
                  │
Nov-Déc           │ 📈 Phase de croissance
                  │    - Mobile Money intégration
                  │    - Communauté et partage
                  │    - Négociations avec les Ministères

2027
═══════════════════════════════════════════════════════════════════

Jan-Mars          │ 🏛️ Contrats B2G
                  │    - Pilotes gouvernementaux
                  │    - Mode enseignant
                  │
Avril-Déc         │ 🌍 Expansion régionale
                  │    - Guinée, Tchad, Sénégal
                  │    - 500 000+ utilisateurs
```

---

## 12. ✅ CONCLUSION

### Pourquoi Flow est la bonne solution pour l'AES ?

| Argument | Explication |
|----------|-------------|
| 🌍 **Souveraineté éducative** | Solution africaine, par et pour les Africains |
| 🇫🇷 **Déjà francophone** | Pas besoin de traduction majeure |
| 📸 **Usage naturel** | Les élèves photographient déjà leurs cours |
| 🤖 **IA comme tuteur** | Pallier le manque d'enseignants |
| 📴 **Mode offline** | Fonctionne même sans internet |
| 💰 **Prix accessible** | 500 FCFA/mois = prix d'un sandwich |
| 📱 **Mobile-first** | Là où sont les jeunes |
| 🧠 **Science-based** | Algorithme SM-2 prouvé scientifiquement |

### Message Clé

> **« Flow transforme chaque smartphone en tuteur personnel intelligent. 
> Dans un contexte où le Sahel manque de 100 000 enseignants, Flow offre 
> à chaque élève un accompagnement éducatif de qualité, 24h/24, même sans 
> connexion internet. C'est la souveraineté éducative à portée de main. »**

---

### 📞 Contact et Prochaines Étapes

1. **Présentations officielles** aux Ministères de l'Éducation (Mali → BF → Niger)
2. **Recherche de partenaires locaux** dans chaque pays
3. **Demande de financement** auprès des bailleurs identifiés
4. **Développement des adaptations** techniques (2-3 mois)
5. **Lancement du pilote** dans 15 écoles

---

*Ce document est confidentiel et propriété de l'équipe Flow.*
*Pour toute question ou collaboration : [à compléter]*
