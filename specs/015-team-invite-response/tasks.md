# Tasks: Gestion des invitations d’équipe

**Input**: Design documents from `/specs/015-team-invite-response/`
**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests are REQUIRED for any new or changed behavior in this feature.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Each task includes exact file path(s)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer les artefacts minimaux de base pour la feature.

- [X] T001 Créer le fichier de tests contrôleur dédié aux invitations dans `test/controllers/invitations_controller_test.rb`
- [X] T002 [P] Préparer les scénarios système invitations dans `test/system/teams_test.rb`
- [X] T003 [P] Initialiser les clés de traduction invitation dans `config/locales/fr.yml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fondations techniques bloquantes pour toutes les user stories.

**⚠️ CRITICAL**: Aucun travail de user story ne commence avant la fin de cette phase.

- [X] T004 Implémenter la migration complète (FK, enum status, responded_at, index unicité pending) dans `db/migrate/*_create_team_invitations.rb`
- [X] T005 [P] Implémenter enum, validations, scopes et invariants dans `app/models/team_invitation.rb`
- [X] T006 [P] Ajouter les associations `team_invitations` dans `app/models/team.rb` et `app/models/user.rb`
- [X] T007 Ajouter les routes invitations (`create`, `accept`, `refuse`) dans `config/routes.rb`
- [X] T008 Ajouter les fixtures d’invitations (`pending/accepted/refused`) dans `test/fixtures/team_invitations.yml`
- [X] T009 Préparer le chargement des collections d’invitations dans `app/controllers/teams_controller.rb`

**Checkpoint**: Fondation prête — implémentation des user stories possible.

---

## Phase 3: User Story 1 - Répondre à une invitation d’équipe (Priority: P1) 🎯 MVP

**Goal**: Permettre au membre invité d’accepter/refuser depuis `/teams` avec effet immédiat.

**Independent Test**: Créer une invitation en attente, se connecter comme invité, accepter puis refuser (cas distinct), vérifier le statut et l’adhésion active.

### Tests for User Story 1

- [X] T010 [P] [US1] Ajouter les tests contrôleur accept/refuse (propriétaire uniquement, invitation déjà traitée) dans `test/controllers/invitations_controller_test.rb`
- [X] T011 [P] [US1] Ajouter les tests système accept/refuse depuis `/teams` dans `test/system/teams_test.rb`
- [X] T033 [P] [US1] Ajouter un test multi-équipes garantissant qu’une acceptation n’affecte pas les autres invitations en attente dans `test/controllers/invitations_controller_test.rb`

### Implementation for User Story 1

- [X] T012 [US1] Implémenter l’action `accept` atomique avec création de membership actif dans `app/controllers/invitations_controller.rb`
- [X] T013 [US1] Implémenter l’action `refuse` atomique avec horodatage de réponse dans `app/controllers/invitations_controller.rb`
- [X] T014 [US1] Afficher les actions `Accepter`/`Refuser` pour les invitations du `current_user` dans `app/views/teams/show.html.erb`
- [X] T015 [US1] Charger les invitations reçues en attente de l’utilisateur dans `app/controllers/teams_controller.rb`
- [X] T016 [US1] Ajouter les messages i18n de réponse invitation dans `config/locales/fr.yml`

**Checkpoint**: US1 est fonctionnelle et testable indépendamment (MVP).

---

## Phase 4: User Story 2 - Envoyer une invitation lors de l’ajout d’un membre (Priority: P2)

**Goal**: Transformer l’ajout membre organisateur en création d’invitation `pending` (sans adhésion immédiate).

**Independent Test**: En tant qu’organisateur, ajouter un membre depuis `/teams`, vérifier qu’une invitation est créée et qu’aucun membership actif n’est créé avant acceptation.

### Tests for User Story 2

- [X] T017 [P] [US2] Ajouter les tests contrôleur de création invitation (organisateur-only, doublon pending, membre déjà actif) dans `test/controllers/invitations_controller_test.rb`
- [X] T018 [P] [US2] Mettre à jour les tests de flux d’ajout membre pour interdire l’adhésion directe dans `test/controllers/memberships_controller_test.rb`
- [X] T034 [P] [US2] Ajouter un test de non-expiration automatique: une invitation reste `pending` tant qu’aucune réponse explicite n’est soumise dans `test/controllers/invitations_controller_test.rb`

### Implementation for User Story 2

- [X] T019 [US2] Implémenter l’action `create` (lookup email, garde organisateur, création pending) dans `app/controllers/invitations_controller.rb`
- [X] T020 [US2] Basculer le formulaire “Ajouter un membre” vers la route invitations dans `app/views/teams/show.html.erb`
- [X] T021 [US2] Retirer la création directe de membership du flux d’ajout dans `app/controllers/memberships_controller.rb`
- [X] T022 [US2] Renforcer la validation “pas d’invitation si déjà membre actif” dans `app/models/team_invitation.rb`
- [X] T023 [US2] Ajouter les messages i18n de création invitation (succès/erreurs) dans `config/locales/fr.yml`

**Checkpoint**: US1 et US2 fonctionnent indépendamment.

---

## Phase 5: User Story 3 - Visualiser les membres en attente dans le bloc Membres (Priority: P3)

**Goal**: Afficher distinctement actifs vs en attente sur `/teams` avec visibilité limitée aux rôles autorisés.

**Independent Test**: Avec une équipe ayant membres actifs + invitations pending, vérifier l’affichage différencié et la restriction de visibilité selon le rôle.

### Tests for User Story 3

- [X] T024 [P] [US3] Ajouter les tests système d’affichage “en attente” et de transition vers actif après acceptation dans `test/system/teams_test.rb`
- [X] T025 [P] [US3] Ajouter les tests contrôleur de visibilité des pending invitations par rôle dans `test/controllers/teams_controller_test.rb`

### Implementation for User Story 3

- [X] T026 [US3] Implémenter la section “Membres en attente” et badges de statut dans `app/views/teams/show.html.erb`
- [X] T027 [US3] Filtrer la visibilité des pending invitations (membres actifs + organisateur uniquement) dans `app/controllers/teams_controller.rb`
- [X] T028 [US3] Ajuster le compteur et la présentation actifs/en attente dans `app/views/teams/show.html.erb`

**Checkpoint**: Toutes les user stories sont indépendamment fonctionnelles.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finitions globales, documentation produit et validation finale.

- [X] T035 Ajouter une étape explicite de revue visuelle/interaction (desktop + mobile, états feedback) dans `specs/015-team-invite-response/quickstart.md`
- [X] T036 [P] Ajouter et exécuter les quality gates (lint/format/tests) dans `specs/015-team-invite-response/quickstart.md`
- [X] T037 [P] Ajouter la procédure de mesure performance pour SC-003 et SC-005 (méthode + seuils) dans `specs/015-team-invite-response/quickstart.md`
- [X] T031 [P] Aligner `specs/015-team-invite-response/contracts/invitations.openapi.yaml` avec les routes/messages effectivement implémentés
- [X] T032 [P] Mettre à jour le scénario de validation final dans `specs/015-team-invite-response/quickstart.md`
- [X] T029 Documenter la feature “invitations d’équipe” dans la section Features de `README.md`
- [X] T030 Ajouter l’entrée Changelog `v1.3.0` (avec lien vers `specs/015-team-invite-response/spec.md`) dans `README.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: aucune dépendance
- **Phase 2 (Foundational)**: dépend de Phase 1 — bloque toutes les user stories
- **Phases 3–5 (User Stories)**: dépendent de Phase 2
- **Phase 6 (Polish)**: dépend de la complétion des stories ciblées

### User Story Dependencies

- **US1 (P1)**: démarre après Phase 2; indépendante des autres stories
- **US2 (P2)**: démarre après Phase 2; dépend logiquement du socle invitation mais pas de l’UI US3
- **US3 (P3)**: démarre après Phase 2; exploite les données invitation, testable avec fixtures même sans finalisation complète US2

### Within Each User Story

- Tests d’abord (ils doivent échouer avant implémentation)
- Contrôleur/modèle avant vue
- Règles d’autorisation avant finalisation UX
- Validation de story indépendante avant passage à la suivante

### Parallel Opportunities

- **Setup**: `T002` et `T003` en parallèle
- **Foundational**: `T005` et `T006` en parallèle; `T008` peut démarrer après `T004`
- **US1**: `T010`, `T011` et `T033` en parallèle
- **US2**: `T017`, `T018` et `T034` en parallèle
- **US3**: `T024` et `T025` en parallèle
- **Polish**: `T031`, `T032`, `T036` et `T037` en parallèle

---

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
T010 test/controllers/invitations_controller_test.rb
T011 test/system/teams_test.rb
T033 test/controllers/invitations_controller_test.rb

# Puis implémentation séquentielle contrôleur -> vue
T012 -> T013 -> T014 -> T015 -> T016
```

## Parallel Example: User Story 2

```bash
# Tests US2 en parallèle
T017 test/controllers/invitations_controller_test.rb
T018 test/controllers/memberships_controller_test.rb
T034 test/controllers/invitations_controller_test.rb

# Implémentation US2
T019 -> T020 -> T021 -> T022 -> T023
```

## Parallel Example: User Story 3

```bash
# Tests US3 en parallèle
T024 test/system/teams_test.rb
T025 test/controllers/teams_controller_test.rb

# Implémentation US3
T026 -> T027 -> T028
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Compléter Phase 1 + Phase 2
2. Livrer Phase 3 (US1)
3. Valider indépendamment (accept/refuse + verrou concurrence)
4. Démo possible

### Incremental Delivery

1. Foundation prête (Phases 1–2)
2. Livrer US1 (MVP)
3. Livrer US2 (invitation à la place d’ajout direct)
4. Livrer US3 (lisibilité et visibilité pending)
5. Exécuter revue UX + quality gates + mesures perf (`T035–T037`)
6. Aligner contrat et quickstart (`T031–T032`)
7. Terminer par la documentation `README.md` + changelog `v1.3.0` (`T029–T030`)

### Parallel Team Strategy

1. Binôme A: modèle/migration/routes (Phase 2)
2. Binôme B: tests US1/US2 pendant fin de fondation
3. Ensuite répartition par story (US1, US2, US3)
4. Merge final sur Phase 6

### Single Dev (Ultra-Linéaire)

- **Checkpoint A (setup + fondation)**
  - `T001` → `T002` → `T003` → `T004` → `T005` → `T006` → `T007` → `T008` → `T009`

- **Checkpoint B (US1)**
  - Tests d’abord: `T010` → `T011` → `T033`
  - Implémentation: `T012` → `T013` → `T014` → `T015` → `T016`

- **Checkpoint C (US2)**
  - Tests d’abord: `T017` → `T018` → `T034`
  - Implémentation: `T019` → `T020` → `T021` → `T022` → `T023`

- **Checkpoint D (US3)**
  - Tests d’abord: `T024` → `T025`
  - Implémentation: `T026` → `T027` → `T028`

- **Checkpoint E (polish & release docs)**
  - Qualité & perf: `T035` → `T036` → `T037`
  - Alignement artefacts: `T031` → `T032`
  - Documentation release: `T029` → `T030`

Cadence suggérée (single dev):

- Demi-journée 1: Checkpoint A
- Demi-journée 2: Checkpoint B
- Demi-journée 3: Checkpoint C
- Demi-journée 4: Checkpoint D
- Demi-journée 5: Checkpoint E + stabilisation finale

---

## Notes

- Tous les items respectent le format checklist `- [X] Txxx ...`.
- Les labels `[US1]`, `[US2]`, `[US3]` sont présents uniquement dans les phases user story.
- Les tâches de documentation produit demandées (README + changelog `v1.3.0`) sont incluses en Phase 6.
