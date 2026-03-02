# Tasks: Modification de proposition avant guessing

**Input**: Design documents from `/specs/014-proposal-edit-window/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests contrôleur/intégration/système requis (comportement modifié).

**Organization**: Tâches groupées par user story pour permettre une implémentation et validation indépendantes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Exécutable en parallèle (fichiers différents, sans dépendance non terminée)
- **[Story]**: User story associée (`[US1]`, `[US2]`, `[US3]`)
- Chaque tâche inclut un chemin de fichier exact

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer les fichiers de test et les points d’entrée de la feature.

- [X] T001 Créer la base de tests d’intégration du flux d’édition dans `test/integration/proposal_edit_window_test.rb`
- [X] T002 Créer les tests contrôleur du flux proposition dans `test/controllers/proposals_controller_test.rb`
- [X] T003 Vérifier l’alignement du contrat proposals edit window avec les routes existantes dans `config/routes.rb` et `specs/014-proposal-edit-window/contracts/proposals-edit-window.openapi.yaml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Mettre en place les fondations communes avant les user stories.

**⚠️ CRITICAL**: Aucune user story ne démarre avant la fin de cette phase.

- [X] T004 Refactoriser le chargement de la proposition du joueur courant dans `app/controllers/proposals_controller.rb` (méthode partagée create/new/show)
- [X] T005 Ajouter la logique de formulaire create/edit unifiée (pré-remplissage + libellés dynamiques) dans `app/views/proposals/new.html.erb`
- [X] T006 Mettre à jour l’action joueur en collecte pour pointer vers le flux d’édition dans `app/views/games/_collecting.html.erb`
- [X] T007 Étendre les validations de phase pour couvrir la modification (pas seulement la création) dans `app/models/proposal.rb`

**Checkpoint**: Fondation prête — implémentation des user stories possible.

---

## Phase 3: User Story 1 - Modifier sa proposition en collecte (Priority: P1) 🎯 MVP

**Goal**: Autoriser la création/mise à jour de la proposition du joueur tant que la partie est en collecte.

**Independent Test**: En phase collecte, un joueur déjà soumis peut modifier plusieurs fois sa proposition; la dernière valeur est conservée.

### Tests for User Story 1

- [X] T008 [P] [US1] Ajouter le test système “modifier une proposition existante en collecte” dans `test/system/proposals_test.rb`
- [X] T009 [P] [US1] Ajouter le test d’intégration “create puis update via le même flux en collecte” dans `test/integration/proposal_edit_window_test.rb`
- [X] T010 [US1] Ajouter le test contrôleur “soumission en collecte crée si absence de proposition” dans `test/controllers/proposals_controller_test.rb`
- [X] T011 [US1] Ajouter le test contrôleur “utilisateur non membre ne peut ni créer ni modifier une proposition” dans `test/controllers/proposals_controller_test.rb`
- [X] T012 [US1] Ajouter le test d’intégration “mises à jour successives ne créent pas d’historique et conservent un seul enregistrement” dans `test/integration/proposal_edit_window_test.rb`

### Implementation for User Story 1

- [X] T013 [US1] Autoriser `new` à afficher le formulaire même si une proposition existe déjà dans `app/controllers/proposals_controller.rb`
- [X] T014 [US1] Implémenter le comportement upsert en collecte (create si absent, update sinon) dans `app/controllers/proposals_controller.rb`
- [X] T015 [US1] Remplacer l’entrée “Voir ma proposition” par “Modifier ma proposition” en collecte dans `app/views/games/_collecting.html.erb`
- [X] T016 [US1] Afficher un message de succès cohérent pour création et modification dans `app/controllers/proposals_controller.rb`

**Checkpoint**: US1 est entièrement fonctionnelle et testable indépendamment.

---

## Phase 4: User Story 2 - Verrouiller la proposition en guessing (Priority: P2)

**Goal**: Refuser toute modification en guessing et refléter visuellement l’état verrouillé.

**Independent Test**: En guessing, une tentative de modification est refusée, la valeur initiale reste inchangée, et aucune action d’édition n’est proposée.

### Tests for User Story 2

- [X] T017 [P] [US2] Ajouter le test d’intégration “soumission en guessing ne modifie pas la proposition existante” dans `test/integration/proposal_edit_window_test.rb`
- [X] T018 [P] [US2] Ajouter le test système “aucune action d’édition disponible en phase guessing” dans `test/system/proposals_test.rb`
- [X] T019 [US2] Ajouter le test contrôleur “soumission en guessing est refusée avec conservation de la valeur” dans `test/controllers/proposals_controller_test.rb`

### Implementation for User Story 2

- [X] T020 [US2] Appliquer le refus explicite au moment de soumission quand la partie est en guessing dans `app/controllers/proposals_controller.rb`
- [X] T021 [US2] Ajouter un état UI explicite de verrouillage de proposition en guessing dans `app/views/games/_guessing.html.erb`
- [X] T022 [US2] Vérifier qu’aucun lien d’édition n’est rendu hors collecte dans `app/views/games/_collecting.html.erb` et `app/views/games/_guessing.html.erb`

**Checkpoint**: US2 est entièrement fonctionnelle et testable indépendamment.

---

## Phase 5: User Story 3 - Respecter la transition de phase (Priority: P3)

**Goal**: Garantir que la règle est évaluée à l’instant effectif de soumission, y compris pendant une bascule collecte → guessing.

**Independent Test**: Une soumission préparée en collecte mais envoyée après bascule vers guessing est refusée.

### Tests for User Story 3

- [X] T023 [P] [US3] Ajouter le test d’intégration “bascule de phase entre affichage formulaire et submit” dans `test/integration/proposal_edit_window_test.rb`
- [X] T024 [P] [US3] Ajouter le test système “soumettre la même URL en collecte reste accepté” dans `test/system/proposals_test.rb`
- [X] T025 [US3] Ajouter le test contrôleur “absence de proposition + guessing => aucune création” dans `test/controllers/proposals_controller_test.rb`

### Implementation for User Story 3

- [X] T026 [US3] Recharger l’état de la partie juste avant mutation pour éviter les soumissions avec état périmé dans `app/controllers/proposals_controller.rb`
- [X] T027 [US3] Protéger le flux upsert via transaction et garde-fou de phase atomique dans `app/controllers/proposals_controller.rb`

**Checkpoint**: US3 est entièrement fonctionnelle et testable indépendamment.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalisation transverse, documentation, validation.

- [X] T028 [P] Mettre à jour la description de feature dans `README.md` (sections Features et Rules)
- [X] T029 [P] Mettre à jour le changelog `v1.2.3` dans `README.md`
- [X] T030 Décrire et exécuter le protocole de mesure UX `SC-003` dans `specs/014-proposal-edit-window/quickstart.md`
- [X] T031 Décrire et exécuter le protocole de mesure performance `SC-005` (p95 < 500 ms) dans `specs/014-proposal-edit-window/quickstart.md`
- [X] T032 Exécuter la validation quickstart consolidée et consigner les résultats dans `specs/014-proposal-edit-window/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: aucun prérequis
- **Phase 2 (Foundational)**: dépend de Phase 1 — bloque toutes les user stories
- **Phase 3/4/5 (User Stories)**: dépendent de Phase 2
- **Phase 6 (Polish)**: dépend des user stories livrées

### User Story Dependencies

- **US1 (P1)**: dépend uniquement de la fondation
- **US2 (P2)**: dépend de la fondation et s’appuie sur le flux d’édition de US1
- **US3 (P3)**: dépend de US1/US2 pour valider la bascule temporelle sur le flux final

### Story Completion Order

1. US1 → 2. US2 → 3. US3

### Within Each User Story

- Tests d’abord, puis implémentation
- Contrôleur/modèle avant finalisation UX
- Story validée avant passage à la priorité suivante

---

## Parallel Opportunities

- **Setup**: T001 et T002 peuvent être menées en parallèle
- **Foundational**: T005 et T007 peuvent avancer en parallèle après T004
- **US1**: T008/T009 en parallèle; T015 peut être mené en parallèle de T016 après T014
- **US2**: T017/T018 en parallèle; T021 et T022 en parallèle après T020
- **US3**: T023/T024 en parallèle; T026 et T027 séquentielles
- **Polish**: T028 et T029 en parallèle

---

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
T008 test/system/proposals_test.rb
T009 test/integration/proposal_edit_window_test.rb

# Implémentation partielle en parallèle (après T014)
T015 app/views/games/_collecting.html.erb
T016 app/controllers/proposals_controller.rb
```

---

## Parallel Example: User Story 2

```bash
# Tests US2 en parallèle
T017 test/integration/proposal_edit_window_test.rb
T018 test/system/proposals_test.rb

# Implémentation UI en parallèle (après T020)
T021 app/views/games/_guessing.html.erb
T022 app/views/games/_collecting.html.erb
```

---

## Parallel Example: User Story 3

```bash
# Tests US3 en parallèle
T023 test/integration/proposal_edit_window_test.rb
T024 test/system/proposals_test.rb

# Implémentation séquentielle côté contrôleur
T026 app/controllers/proposals_controller.rb
T027 app/controllers/proposals_controller.rb
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Finir Phase 1 + Phase 2
2. Livrer US1 (T008 → T016)
3. Valider US1 indépendamment

### Incremental Delivery

1. Ajouter US2 (verrouillage guessing + état UI)
2. Ajouter US3 (cohérence temporelle au submit)
3. Finaliser docs + validation quickstart

### Parallel Team Strategy

1. Dev A: tests (`test/controllers`, `test/integration`, `test/system`)
2. Dev B: contrôleur/modèle (`app/controllers/proposals_controller.rb`, `app/models/proposal.rb`)
3. Dev C: vues/docs (`app/views/games/*`, `app/views/proposals/new.html.erb`, `README.md`)
