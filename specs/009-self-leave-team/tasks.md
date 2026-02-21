# Tasks: Quitter son équipe

**Input**: Design documents from `/specs/009-self-leave-team/`  
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Les tests sont requis pour cette feature (constitution + comportements modifiés).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Peut être exécutée en parallèle (fichiers différents, pas de dépendance bloquante)
- **[Story]**: User story associée (`[US1]`, `[US2]`, `[US3]`)
- Chaque tâche inclut un chemin de fichier précis

---

## Phase 1: Setup (Initialisation)

**Purpose**: Préparer le terrain de tests et les points d’entrée de la feature.

- [X] T001 Créer le squelette des tests de feature dans `test/controllers/memberships_controller_test.rb`
- [X] T002 Créer le squelette des tests UI de feature dans `test/system/self_leave_team_test.rb`
- [X] T003 [P] Préparer les fixtures de membres/équipes utilisées par la feature dans `test/fixtures/memberships.yml`

---

## Phase 2: Foundational (Prérequis bloquants)

**Purpose**: Mettre en place l’infrastructure applicative commune avant les user stories.

**⚠️ CRITICAL**: Aucune user story ne démarre avant la fin de cette phase.

- [X] T004 Ajouter la route auto-service `DELETE /teams/:team_id/leave` dans `config/routes.rb`
- [X] T005 Refactoriser les callbacks d’autorisation pour séparer gestion organisateur et auto-sortie dans `app/controllers/memberships_controller.rb`
- [X] T006 Implémenter l’action `leave` avec ciblage strict `current_user` et lookup sécurisé de l’équipe dans `app/controllers/memberships_controller.rb`
- [X] T007 [P] Ajouter les clés/messages de feedback self-leave dans `config/locales/fr.yml`
- [X] T008 Ajouter les tests contrôleur de base (authentification + accès route `leave`) dans `test/controllers/memberships_controller_test.rb`

**Checkpoint**: Fondation prête — implémentation des user stories possible.

---

## Phase 3: User Story 1 - Quitter volontairement une équipe (Priority: P1) 🎯 MVP

**Goal**: Permettre à un membre non organisateur de quitter son équipe et ne plus y apparaître.

**Independent Test**: Un membre non organisateur déclenche `Quitter`, confirme l’action, est redirigé vers `/teams`, puis n’est plus listé dans les membres de l’équipe.

### Tests for User Story 1

- [X] T009 [P] [US1] Ajouter le test contrôleur de sortie réussie d’un membre non organisateur dans `test/controllers/memberships_controller_test.rb`
- [X] T010 [P] [US1] Ajouter le test système du parcours `Quitter` réussi avec suppression de membership dans `test/system/self_leave_team_test.rb`

### Implementation for User Story 1

- [X] T011 [US1] Ajouter le bouton `Quitter` pour membre non organisateur dans la zone d’actions d’en-tête de `app/views/teams/show.html.erb`
- [X] T012 [US1] Aligner style/position du bouton `Quitter` sur le bouton `Supprimer` dans `app/views/teams/show.html.erb`
- [X] T013 [US1] Brancher le bouton `Quitter` vers la route `leave` avec redirection succès vers `teams#index` dans `app/views/teams/show.html.erb` et `app/controllers/memberships_controller.rb`

**Checkpoint**: US1 fonctionnelle et testable indépendamment.

---

## Phase 4: User Story 2 - Empêcher un organisateur de quitter sa propre équipe (Priority: P1)

**Goal**: Refuser explicitement la sortie de l’organisateur et toute sortie pendant partie active.

**Independent Test**: Un organisateur reçoit un refus explicite et reste membre; un membre non organisateur reçoit aussi un refus si la team a une partie active (`collecting`/`guessing`).

### Tests for User Story 2

- [X] T014 [P] [US2] Ajouter le test contrôleur de refus organisateur via `team.organizer_id` dans `test/controllers/memberships_controller_test.rb`
- [X] T015 [P] [US2] Ajouter le test contrôleur de refus quand partie active existe (`collecting`/`guessing`) dans `test/controllers/memberships_controller_test.rb`
- [X] T016 [P] [US2] Ajouter le test système validant que l’organisateur reste membre après tentative dans `test/system/self_leave_team_test.rb`
- [X] T029 [P] [US2] Ajouter un test négatif de sécurité: une tentative de ciblage d'une appartenance tierce via paramètres forgés est refusée et ne supprime rien dans `test/controllers/memberships_controller_test.rb`

### Implementation for User Story 2

- [X] T017 [US2] Implémenter le garde-fou organisateur (`team.organizer_id == current_user.id`) dans `app/controllers/memberships_controller.rb`
- [X] T018 [US2] Implémenter le garde-fou partie active (`team.has_active_game?`) dans `app/controllers/memberships_controller.rb`
- [X] T019 [US2] Garantir l’absence de suppression de membership sur les chemins de refus dans `app/controllers/memberships_controller.rb`

**Checkpoint**: US2 fonctionnelle et testable indépendamment.

---

## Phase 5: User Story 3 - Retour clair après action (Priority: P2)

**Goal**: Afficher un retour clair (succès/refus), confirmation explicite, et couvrir l’idempotence.

**Independent Test**: Vérifier messages de succès/refus et confirmation exacte `Êtes-vous sûr de vouloir quitter cette équipe ?` sur les scénarios succès et refus.

### Tests for User Story 3

- [X] T020 [P] [US3] Ajouter le test contrôleur d’idempotence (deuxième demande sans effet + message clair) dans `test/controllers/memberships_controller_test.rb`
- [X] T021 [P] [US3] Ajouter le test système du texte exact de confirmation `Êtes-vous sûr de vouloir quitter cette équipe ?` dans `test/system/self_leave_team_test.rb`
- [X] T022 [P] [US3] Ajouter le test système de visibilité des messages flash succès/refus dans `test/system/self_leave_team_test.rb`

### Implementation for User Story 3

- [X] T023 [US3] Ajouter la confirmation Turbo avec texte exact sur le bouton `Quitter` dans `app/views/teams/show.html.erb`
- [X] T024 [US3] Harmoniser les messages flash (succès, refus organisateur, refus partie active, déjà sorti) dans `app/controllers/memberships_controller.rb`
- [X] T025 [US3] Mettre à jour la documentation globale de la feature et la section changelog dans `README.md`

**Checkpoint**: US3 fonctionnelle et testable indépendamment.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Vérification finale, conformité contrat et validation globale.

- [X] T026 [P] Vérifier l’alignement implémentation/contrat de `DELETE /teams/{team_id}/leave` dans `specs/009-self-leave-team/contracts/self-leave-team.openapi.yaml`
- [X] T027 Exécuter les tests ciblés feature référencés dans `specs/009-self-leave-team/quickstart.md`
- [ ] T028 Exécuter la validation manuelle quickstart (scénarios A→E) depuis `specs/009-self-leave-team/quickstart.md`
- [ ] T030 [P] Mesurer SC-003 selon SC-005 (20 exécutions, seuil 19/20 ≤ 2s) et consigner le résultat dans `specs/009-self-leave-team/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Démarre immédiatement
- **Phase 2 (Foundational)**: Dépend de Phase 1 et bloque toutes les user stories
- **Phase 3 (US1)**: Dépend de Phase 2
- **Phase 4 (US2)**: Dépend de Phase 2 (peut avancer en parallèle de US1 après fondation)
- **Phase 5 (US3)**: Dépend de Phase 2, et consolide les feedbacks des flux US1/US2
- **Phase 6 (Polish)**: Dépend des stories sélectionnées pour livraison

### User Story Dependencies

- **US1 (P1)**: Pas de dépendance sur d’autres stories (MVP)
- **US2 (P1)**: Pas de dépendance fonctionnelle stricte sur US1, mais partage les mêmes composants
- **US3 (P2)**: Dépend des flux US1/US2 pour valider les messages finaux de succès/refus

### Within Each User Story

- Écrire les tests de la story puis implémenter
- Contrôleur + route avant assertions UI finales
- Story validée indépendamment avant passage à la suivante

---

## Parallel Opportunities

### US1

- T009 et T010 en parallèle (tests contrôleur/système)
- T011 et T012 en parallèle partiel (même vue, sections non bloquantes), puis T013

### US2

- T014, T015, T016, T029 en parallèle
- T017 et T018 en parallèle, puis T019

### US3

- T020, T021, T022 en parallèle
- T023 et T024 en parallèle, puis T025

---

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
T009
T010

# Implémentation US1
T011
T012
# Puis
T013
```

## Parallel Example: User Story 2

```bash
# Tests US2 en parallèle
T014
T015
T016
T029

# Implémentation US2
T017
T018
# Puis
T019
```

## Parallel Example: User Story 3

```bash
# Tests US3 en parallèle
T020
T021
T022

# Implémentation US3
T023
T024
# Puis
T025
```

---

## Implementation Strategy

### MVP First (US1 uniquement)

1. Finir Phase 1
2. Finir Phase 2
3. Livrer US1 (Phase 3)
4. Valider indépendamment, puis démontrer/déployer MVP

### Incremental Delivery

1. Foundation complète (Phases 1-2)
2. US1 (valeur immédiate utilisateur)
3. US2 (garde-fous métier critiques)
4. US3 (qualité de feedback + docs produit)
5. Polish et validation quickstart

### Parallel Team Strategy

1. Toute l’équipe sur Phases 1-2
2. Ensuite répartition: dev A (US1), dev B (US2), dev C (US3/tests/docs)
3. Intégration finale en Phase 6
