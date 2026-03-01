# Tasks: Randomisation de l’ordre des propositions

**Input**: Design documents from `/specs/011-randomize-guess-order/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/randomize-guess-order.openapi.yaml, quickstart.md

**Tests**: Les tests sont requis (constitution du projet: tout comportement modifié doit être couvert).

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer le terrain de la feature et les artefacts de migration.

- [X] T001 Vérifier et documenter la baseline des tests ciblés dans specs/011-randomize-guess-order/quickstart.md
- [X] T002 Générer et implémenter la migration d'ajout de `guess_order_position` + index `(game_id, guess_order_position)` dans db/migrate/*_add_guess_order_position_to_proposals.rb
- [X] T003 [P] Vérifier la baseline documentaire de release (`README.md` et entrée `v1.2.2`) dans specs/011-randomize-guess-order/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fondations techniques communes à toutes les user stories.

**⚠️ CRITICAL**: Aucun travail US1/US2/US3 ne démarre avant la fin de cette phase.

- [X] T004 Implémenter la logique d'assignation d'ordre figé au passage en `guessing` dans app/models/game.rb
- [X] T005 Implémenter les helpers de lecture ordonnée des propositions de devinette dans app/models/game.rb
- [X] T006 [P] Ajouter les validations de cohérence `guess_order_position` dans app/models/proposal.rb
- [X] T007 Adapter le contrat de transition de phase à la persistance de l'ordre dans specs/011-randomize-guess-order/contracts/randomize-guess-order.openapi.yaml

**Checkpoint**: Fondation prête — les user stories peuvent être implémentées.

---

## Phase 3: User Story 1 - Masquer l’ordre de soumission (Priority: P1) 🎯 MVP

**Goal**: Afficher un ordre non corrélé à l’ordre de soumission, identique pour tous les joueurs d’une même manche.

**Independent Test**: Sur une manche avec au moins 3 propositions dans un ordre de soumission connu, l’ordre affiché en devinette est différent de l’ordre chronologique et identique entre deux joueurs.

### Tests for User Story 1

- [X] T010 [P] [US1] Ajouter un test modèle d'assignation aléatoire des positions au `start_guessing!` dans test/models/game_test.rb
- [X] T011 [P] [US1] Ajouter un test contrôleur garantissant le même ordre pour deux joueurs sur `GET /games/:game_id/guesses/new` dans test/controllers/guesses_controller_test.rb
- [X] T012 [P] [US1] Ajouter un test système de non-corrélation avec l'ordre de soumission dans test/system/guess_order_randomization_test.rb

### Implementation for User Story 1

- [X] T013 [US1] Persister les positions 1..N mélangées une seule fois lors de `Game#start_guessing!` dans app/models/game.rb
- [X] T014 [US1] Charger les propositions selon l'ordre figé dans GuessesController#new dans app/controllers/guesses_controller.rb
- [X] T015 [US1] Afficher la liste de devinettes basée sur l'ordre fourni par le contrôleur dans app/views/guesses/new.html.erb
- [X] T016 [US1] Garantir qu'aucun tri par timestamp n'est utilisé pour la devinette dans app/controllers/guesses_controller.rb

**Checkpoint**: US1 est fonctionnelle et testable indépendamment.

---

## Phase 4: User Story 2 - Stabilité de l’affichage pendant la manche (Priority: P2)

**Goal**: Garder strictement le même ordre pendant toute la manche, y compris après reload.

**Independent Test**: Recharger `guesses/new` plusieurs fois pendant la même manche ne change jamais la séquence affichée.

### Tests for User Story 2

- [X] T017 [P] [US2] Ajouter un test contrôleur de stabilité de l'ordre sur rechargements successifs dans test/controllers/guesses_controller_test.rb
- [X] T018 [P] [US2] Ajouter un test système de stabilité visuelle après refresh dans test/system/guess_order_randomization_test.rb
- [X] T019 [P] [US2] Ajouter un test modèle empêchant toute réassignation après freeze initial dans test/models/game_test.rb

### Implementation for User Story 2

- [X] T020 [US2] Rendre idempotente l'assignation d'ordre (pas de recalcul si déjà figé) dans app/models/game.rb
- [X] T021 [US2] Assurer l'utilisation exclusive de `guess_order_position` pour la devinette dans app/controllers/guesses_controller.rb
- [X] T022 [US2] Ajouter un fallback déterministe `id ASC` en cas d'égalité/incomplétude dans app/controllers/guesses_controller.rb

**Checkpoint**: US1 + US2 sont fonctionnelles et testables indépendamment.

---

## Phase 5: User Story 3 - Continuité du gameplay entre manches (Priority: P3)

**Goal**: Recalculer un ordre indépendant à chaque nouvelle manche.

**Independent Test**: Deux manches différentes n’utilisent pas la même séquence figée par défaut et chaque manche conserve sa propre séquence.

### Tests for User Story 3

- [X] T023 [P] [US3] Ajouter un test modèle d'indépendance des ordres entre deux parties dans test/models/game_test.rb
- [X] T024 [P] [US3] Ajouter un test système comparant l'ordre entre deux manches successives dans test/system/guess_order_randomization_test.rb
- [X] T025 [P] [US3] Ajouter un test edge case 0/1 proposition sans erreur d'affichage dans test/controllers/guesses_controller_test.rb

### Implementation for User Story 3

- [X] T026 [US3] Réinitialiser implicitement l'état d'ordre sur nouvelles propositions de nouvelle manche dans app/models/proposal.rb
- [X] T027 [US3] Vérifier le refus explicite de soumission hors phase `collecting` dans app/controllers/proposals_controller.rb
- [X] T028 [US3] Harmoniser les messages de feedback liés à l'ordre figé dans config/locales/fr.yml

**Checkpoint**: Toutes les user stories sont indépendamment fonctionnelles.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalisation transversale, qualité et documentation.

- [X] T029 [P] Mettre à jour la section règles gameplay avec l'ordre randomisé/figé dans README.md
- [X] T030 Mettre à jour le changelog version 1.2.2 avec la feature #011 dans README.md
- [X] T031 [P] Aligner la spec et les artefacts (plan/data-model/contracts/quickstart) après implémentation dans specs/011-randomize-guess-order/spec.md
- [X] T032 Exécuter la suite de tests ciblée et consigner le résultat dans specs/011-randomize-guess-order/quickstart.md
- [X] T033 Mesurer le p95 de `GET /games/:game_id/guesses/new` (20 runs, 30 propositions) et consigner la preuve dans specs/011-randomize-guess-order/quickstart.md
- [X] T034 Mesurer le p95 d'assignation d'ordre au passage `collecting -> guessing` (20 runs, 30 propositions) et consigner la preuve dans specs/011-randomize-guess-order/quickstart.md
- [X] T035 Exécuter le protocole SC-004 (>=10 joueurs, 20 manches) et consigner les résultats agrégés dans specs/011-randomize-guess-order/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: démarre immédiatement.
- **Phase 2 (Foundational)**: dépend de Phase 1; bloque toutes les user stories.
- **Phases 3-5 (US1-US3)**: dépendent de Phase 2.
- **Phase 6 (Polish)**: dépend des phases user stories visées.

### User Story Dependencies

- **US1 (P1)**: dépend uniquement de la fondation.
- **US2 (P2)**: dépend de US1 (réutilise l’ordre persistant déjà implémenté).
- **US3 (P3)**: dépend de US1; peut démarrer en parallèle de la fin US2 sauf pour tests communs sur les mêmes fichiers.

### Within Each User Story

- Écrire les tests d’abord, les faire échouer.
- Implémenter modèle/contrôleur/vue.
- Valider les tests de la story avant passage à la suivante.

---

## Parallel Opportunities

- **Phase 1**: T003 en parallèle de T001-T002.
- **Phase 2**: T006 et T007 en parallèle de T004-T005 après T002.
- **US1**: T010/T011/T012 en parallèle; T014 et T015 enchaînés après T013.
- **US2**: T017/T018/T019 en parallèle; T021/T022 après T020.
- **US3**: T023/T024/T025 en parallèle; T027/T028 en parallèle après T026.
- **Polish**: T029 et T031 en parallèle; T032 avant mesures; T033/T034/T035 en clôture.

---

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
T010 test/models/game_test.rb
T011 test/controllers/guesses_controller_test.rb
T012 test/system/guess_order_randomization_test.rb

# Puis implémentation
T013 app/models/game.rb
T014 app/controllers/guesses_controller.rb
T015 app/views/guesses/new.html.erb
```

## Parallel Example: User Story 2

```bash
# Tests US2 en parallèle
T017 test/controllers/guesses_controller_test.rb
T018 test/system/guess_order_randomization_test.rb
T019 test/models/game_test.rb
```

## Parallel Example: User Story 3

```bash
# Tests US3 en parallèle
T023 test/models/game_test.rb
T024 test/system/guess_order_randomization_test.rb
T025 test/controllers/guesses_controller_test.rb
```

---

## Implementation Strategy

### MVP First (US1)

1. Terminer Phase 1 + Phase 2.
2. Implémenter US1 (Phase 3).
3. Valider les tests US1 et démontrer l’équité de l’ordre.

### Incremental Delivery

1. Livrer US1 (MVP).
2. Ajouter US2 (stabilité stricte reload).
3. Ajouter US3 (indépendance inter-manches).
4. Finaliser documentation + validations (Phase 6).

### Parallel Team Strategy

1. Toute l’équipe finalise la fondation.
2. Ensuite:
   - Dev A: cœur modèle/transition (`game.rb`)
   - Dev B: contrôleur/vue devinette
   - Dev C: tests système + doc
