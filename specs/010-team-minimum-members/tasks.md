# Tasks: Seuil minimum de membres pour démarrer une partie

**Input**: Design documents from `/specs/010-team-minimum-members/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are REQUIRED for changed behavior in this project (constitution + feature scope).

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer les bases partagées (messages, données de test, documentation de feature)

- [X] T001 Ajouter les clés i18n de la feature dans config/locales/fr.yml et config/locales/en.yml
- [X] T002 [P] Préparer les données de test pour équipes à 1/2/3 membres dans test/fixtures/teams.yml et test/fixtures/memberships.yml
- [X] T003 [P] Aligner le contrat de création de partie avec les messages attendus dans specs/010-team-minimum-members/contracts/team-minimum-members.openapi.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Implémenter les prérequis techniques bloquants avant les user stories

**⚠️ CRITICAL**: No user story work starts before this phase is complete.

- [X] T004 Ajouter la constante de seuil fixe (3) et la validation d'éligibilité à la création dans app/models/game.rb
- [X] T005 [P] Ajouter un helper de comptage d'effectif équipe réutilisable dans app/models/team.rb
- [X] T006 Implémenter la vérification serveur transactionnelle de seuil lors de create dans app/controllers/games_controller.rb
- [X] T007 [P] Ajouter/mettre à jour les tests modèle de base pour la règle de seuil dans test/models/game_test.rb

**Checkpoint**: Les règles métier fondamentales sont en place; les stories peuvent avancer.

---

## Phase 3: User Story 1 - Démarrer une partie avec équipe éligible (Priority: P1) 🎯 MVP

**Goal**: Permettre le lancement normal d'une partie quand l'équipe a au moins 3 membres.

**Independent Test**: Avec une équipe à 3 membres (ou plus), la création réussit et une partie est créée.

### Tests for User Story 1

- [X] T008 [P] [US1] Ajouter un test contrôleur de succès à exactement 3 membres dans test/controllers/games_controller_test.rb
- [X] T009 [P] [US1] Ajouter un test contrôleur de succès à plus de 3 membres dans test/controllers/games_controller_test.rb
- [X] T010 [P] [US1] Ajouter un test système du flux organisateur éligible dans test/system/teams_test.rb

### Implementation for User Story 1

- [X] T011 [US1] Mettre à jour le chemin de succès de création de partie dans app/controllers/games_controller.rb
- [X] T012 [US1] Adapter l'état du bouton de lancement sur équipe éligible dans app/views/teams/show.html.erb
- [X] T013 [US1] Adapter l'écran de lancement pour équipe éligible dans app/views/games/new.html.erb

**Checkpoint**: US1 est démontrable indépendamment (lancement réussi pour équipes éligibles).

---

## Phase 4: User Story 2 - Bloquer un démarrage avec équipe insuffisante (Priority: P1)

**Goal**: Empêcher strictement la création d'une partie pour une équipe de moins de 3 membres.

**Independent Test**: Avec une équipe à 1 ou 2 membres, la création est refusée sans nouveau record `Game`.

### Tests for User Story 2

- [X] T014 [P] [US2] Ajouter des tests contrôleur de refus à 1 et 2 membres (sans création) dans test/controllers/games_controller_test.rb
- [X] T015 [P] [US2] Ajouter un test modèle pour la frontière <3 membres sur create dans test/models/game_test.rb
- [X] T016 [P] [US2] Ajouter un test système de blocage visuel et fonctionnel pour équipe insuffisante dans test/system/teams_test.rb
- [X] T016a [P] [US2] Ajouter un test de non-régression de la règle existante "single active game" avec équipe à 3+ membres dans test/controllers/games_controller_test.rb

### Implementation for User Story 2

- [X] T017 [US2] Implémenter le refus explicite sans effet de bord lors de create dans app/controllers/games_controller.rb
- [X] T018 [US2] Afficher l'état bloqué (équipe insuffisante) dans la section lancement de app/views/teams/show.html.erb
- [X] T019 [US2] Afficher l'état bloqué (équipe insuffisante) dans app/views/games/new.html.erb

**Checkpoint**: US2 est démontrable indépendamment (refus systématique <3 membres, aucun game créé).

---

## Phase 5: User Story 3 - Recevoir un retour explicite (Priority: P2)

**Goal**: Afficher un message clair de succès ou de refus selon le résultat du lancement.

**Independent Test**: Vérifier le message de refus (<3) et le message de confirmation (>=3).

### Tests for User Story 3

- [X] T020 [P] [US3] Ajouter des assertions de message succès/refus côté contrôleur dans test/controllers/games_controller_test.rb
- [X] T021 [P] [US3] Ajouter des assertions de messages visibles côté système dans test/system/teams_test.rb

### Implementation for User Story 3

- [X] T022 [US3] Finaliser les messages i18n explicites de succès/refus dans config/locales/fr.yml et config/locales/en.yml
- [X] T023 [US3] Brancher les clés i18n dans la réponse create de app/controllers/games_controller.rb

**Checkpoint**: US3 est démontrable indépendamment (messages explicites cohérents pour succès et refus).

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finitions transverses, documentation, validation finale.

- [X] T024 [P] Mettre à jour la documentation produit de la feature et l'entrée changelog dans README.md
- [X] T025 [P] Vérifier et ajuster les scénarios de validation manuelle dans specs/010-team-minimum-members/quickstart.md
- [X] T026 [P] Aligner les exemples de contrat avec le comportement final dans specs/010-team-minimum-members/contracts/team-minimum-members.openapi.yaml
- [X] T027 [P] Exécuter une revue accessibilité du flux lancement (clavier, focus visible, contraste, feedback lisible) et consigner le résultat dans specs/010-team-minimum-members/quickstart.md
- [X] T028 Définir et documenter le protocole SC-003 (échantillon, méthode, calcul p95, seuil pass/fail) dans specs/010-team-minimum-members/quickstart.md
- [X] T029 Exécuter la mesure SC-003 et consigner la preuve (p95 et taux <=2s) dans specs/010-team-minimum-members/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: peut démarrer immédiatement.
- **Phase 2 (Foundational)**: dépend de Phase 1 et bloque toutes les user stories.
- **Phase 3-5 (User Stories)**: dépendent de la fin de Phase 2.
- **Phase 6 (Polish)**: dépend de la fin des stories visées et inclut les gates obligatoires accessibilité + performance (SC-003).

### User Story Dependencies

- **US1 (P1)**: démarre après Phase 2; constitue le MVP.
- **US2 (P1)**: démarre après Phase 2; indépendante de US1 fonctionnellement.
- **US3 (P2)**: démarre après Phase 2; peut s'appuyer sur US1/US2 pour valider les messages finaux.

### Suggested Story Completion Order

1. US1 (MVP lancement éligible)
2. US2 (blocage insuffisant)
3. US3 (messages explicites)

---

## Parallel Execution Examples

### User Story 1

```bash
# Tests US1 en parallèle
T008 + T009 + T010
```

### User Story 2

```bash
# Tests US2 en parallèle
T014 + T015 + T016
```

### User Story 3

```bash
# Tests US3 en parallèle
T020 + T021
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Terminer Phase 1 + Phase 2
2. Implémenter US1 (Phase 3)
3. Valider indépendamment US1
4. Démontrer/livrer MVP

### Incremental Delivery

1. Base technique: Phases 1-2
2. Ajouter US1 puis valider
3. Ajouter US2 puis valider
4. Ajouter US3 puis valider
5. Terminer par la phase Polish

### Parallel Team Strategy

1. Toute l'équipe termine Setup + Foundational
2. Ensuite répartition parallèle possible:
   - Dev A: US1
   - Dev B: US2
   - Dev C: US3
