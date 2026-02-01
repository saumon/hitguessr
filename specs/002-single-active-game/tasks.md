# Tasks: Limite d'une partie active par organisateur

**Input**: Design documents from `/specs/002-single-active-game/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Tests**: Tests inclus pour chaque user story (projet avec tests Minitest existants).

**Organization**: Tâches groupées par user story pour permettre l'implémentation et les tests indépendants.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Peut s'exécuter en parallèle (fichiers différents, pas de dépendances)
- **[Story]**: User story associée (US1, US2, US3)
- Chemins exacts inclus dans les descriptions

## Path Conventions

- **Rails monolith**: `app/`, `test/` à la racine du dépôt
- Structure existante documentée dans plan.md

---

## Phase 1: Setup

**Purpose**: Aucune configuration supplémentaire requise - projet Rails existant

Cette fonctionnalité ne nécessite pas de setup particulier. Le projet HitGuessr est déjà configuré avec Rails 8.1.2, Minitest, et Tailwind CSS.

**Checkpoint**: ✅ Setup existant suffisant - passer directement à la Phase 2

---

## Phase 2: Foundational (Modèles)

**Purpose**: Ajouter les méthodes et validations de base qui seront utilisées par toutes les user stories

**⚠️ CRITICAL**: Ces tâches DOIVENT être complétées avant toute implémentation de user story

- [ ] T001 [P] Ajouter le scope `active` au modèle Game dans app/models/game.rb
- [ ] T002 [P] Ajouter les méthodes `active_game` et `has_active_game?` au modèle Team dans app/models/team.rb
- [ ] T003 Ajouter la validation `only_one_active_game_per_team` au modèle Game dans app/models/game.rb

**Checkpoint**: Foundation ready - les méthodes helper sont disponibles pour les tests et l'UI

---

## Phase 3: User Story 1 - Empêcher le lancement d'une nouvelle partie (Priority: P1) 🎯 MVP

**Goal**: Bloquer la création d'une partie si une partie active existe déjà pour l'équipe

**Independent Test**: Lancer une partie, puis tenter d'en créer une seconde → la création est refusée avec message d'erreur

### Tests pour User Story 1

- [ ] T004 [P] [US1] Test unitaire: validation bloque création si partie collecting existe dans test/models/game_test.rb
- [ ] T005 [P] [US1] Test unitaire: validation bloque création si partie guessing existe dans test/models/game_test.rb
- [ ] T006 [P] [US1] Test unitaire: validation autorise création si aucune partie active dans test/models/game_test.rb
- [ ] T007 [P] [US1] Test unitaire: validation autorise création si partie finished uniquement dans test/models/game_test.rb

### Implémentation pour User Story 1

- [ ] T008 [US1] Vérifier que la validation affiche le bon message d'erreur dans app/models/game.rb

**Checkpoint**: La règle métier "une seule partie active" est fonctionnelle et testée

---

## Phase 4: User Story 2 - Visibilité de l'état de la partie en cours (Priority: P2)

**Goal**: Afficher clairement si une partie est en cours et désactiver le bouton de lancement

**Independent Test**: Ouvrir la page équipe avec une partie active → le bouton est grisé avec tooltip

### Tests pour User Story 2

- [X] T009 [P] [US2] Test unitaire: `Team#active_game` retourne la partie active dans test/models/team_test.rb
- [X] T010 [P] [US2] Test unitaire: `Team#has_active_game?` retourne true si partie active dans test/models/team_test.rb
- [X] T011 [P] [US2] Test unitaire: `Team#has_active_game?` retourne false si aucune partie active dans test/models/team_test.rb
- [X] T012 [P] [US2] Test système: bouton désactivé avec tooltip si partie active dans test/system/single_active_game_test.rb

### Implémentation pour User Story 2

- [X] T013 [US2] Modifier la vue teams/show pour afficher bouton conditionnel avec tooltip dans app/views/teams/show.html.erb
- [X] T014 [US2] Ajouter indicateur de partie en cours avec lien vers la partie active dans app/views/teams/show.html.erb

**Checkpoint**: L'interface indique visuellement l'état de la partie en cours

---

## Phase 5: User Story 3 - Lancer une nouvelle partie après fin (Priority: P3)

**Goal**: Permettre le lancement d'une nouvelle partie dès que la précédente est terminée

**Independent Test**: Terminer une partie → le bouton redevient actif → nouvelle partie créée avec succès

### Tests pour User Story 3

- [X] T015 [P] [US3] Test système: bouton actif après fin de partie dans test/system/single_active_game_test.rb
- [X] T016 [P] [US3] Test système: création réussie après fin de partie dans test/system/single_active_game_test.rb

### Implémentation pour User Story 3

Aucune implémentation supplémentaire requise - couvert par les phases précédentes.

**Checkpoint**: Le cycle complet (partie → fin → nouvelle partie) fonctionne

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalisation et validation globale

- [X] T017 [P] Exécuter bin/rails test test/models/game_test.rb pour valider tous les tests Game
- [X] T018 [P] Exécuter bin/rails test test/models/team_test.rb pour valider tous les tests Team
- [X] T019 Exécuter bin/rails test test/system/single_active_game_test.rb pour valider les tests E2E
- [X] T020 [P] Vérifier que RuboCop passe sur les fichiers modifiés
- [X] T021 Valider manuellement le scénario complet via quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: ✅ Skip - projet existant
- **Phase 2 (Foundational)**: Pas de dépendances - peut commencer immédiatement
- **Phase 3 (US1)**: Dépend de Phase 2 (T001, T002, T003)
- **Phase 4 (US2)**: Dépend de Phase 2 (T002)
- **Phase 5 (US3)**: Dépend de Phase 3 et Phase 4
- **Phase 6 (Polish)**: Dépend de toutes les phases précédentes

### User Story Dependencies

- **User Story 1 (P1)**: Dépend de Phase 2 - Pas de dépendance sur autres stories
- **User Story 2 (P2)**: Dépend de Phase 2 - Indépendant de US1
- **User Story 3 (P3)**: Validation E2E qui combine US1 + US2

### Within Each User Story

- Tests écrits en premier (RED)
- Implémentation pour faire passer les tests (GREEN)
- Refactoring si nécessaire (REFACTOR)

### Parallel Opportunities

- T001 et T002 peuvent s'exécuter en parallèle (fichiers différents)
- T004, T005, T006, T007 peuvent s'exécuter en parallèle (même fichier mais tests indépendants)
- T009, T010, T011 peuvent s'exécuter en parallèle
- T017, T018, T020 peuvent s'exécuter en parallèle

---

## Parallel Example: Phase 2 (Foundational)

```bash
# Lancer les tâches T001 et T002 en parallèle (fichiers différents):
# T001: Ajouter scope active à Game (app/models/game.rb)
# T002: Ajouter helper methods à Team (app/models/team.rb)
```

---

## Parallel Example: User Story 1 Tests

```bash
# Lancer tous les tests US1 en parallèle:
# T004: Test validation bloque si collecting
# T005: Test validation bloque si guessing
# T006: Test validation autorise si aucune active
# T007: Test validation autorise si finished uniquement
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Compléter Phase 2: Foundational (T001, T002, T003)
2. Compléter Phase 3: User Story 1 (T004-T008)
3. **STOP et VALIDER**: Tester la règle métier indépendamment
4. Déployer si prêt - la contrainte d'unicité est active

### Incremental Delivery

1. Phase 2 → Foundation ready
2. Ajouter US1 → Tester → Déployer (MVP!)
3. Ajouter US2 → Tester → Déployer (UX améliorée)
4. Ajouter US3 → Tester → Déployer (cycle complet validé)

### Recommended Sequence (Single Developer)

```text
T001 → T002 → T003 (Foundation)
  ↓
T004-T007 (US1 Tests) → T008 (US1 Implementation)
  ↓
T009-T012 (US2 Tests) → T013-T014 (US2 Implementation)
  ↓
T015-T016 (US3 Tests)
  ↓
T017-T021 (Polish)
```

---

## Notes

- Toutes les tâches suivent le format: `- [ ] [TaskID] [P?] [Story?] Description avec chemin de fichier`
- Aucune migration de base de données requise
- Pas de nouveaux fichiers majeurs à créer (sauf test système)
- Impact limité: 2 modèles, 1 vue, 1 nouveau fichier test système
