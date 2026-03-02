# Tasks: Alerte de doublon de proposition

**Input**: Design documents from `/specs/013-duplicate-guess-warning/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Tests système requis (comportement UI modifié).

**Organization**: Tâches groupées par user story pour une implémentation et validation indépendantes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Exécutable en parallèle (fichiers différents, sans dépendance non terminée)
- **[Story]**: User story associée (`[US1]`, `[US2]`, `[US3]`)
- Chaque tâche inclut un chemin de fichier exact

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Préparer les fichiers cibles et la base de test de la feature.

- [X] T001 Créer le fichier `test/system/guesses_duplicate_warning_test.rb` avec la classe de test système et l’authentification de base
- [X] T002 Créer le fichier `app/javascript/controllers/guess_duplicates_controller.js` avec un contrôleur Stimulus minimal (connect/disconnect)
- [X] T003 Enregistrer le contrôleur dans `app/javascript/controllers/index.js` (chargement automatique `guess-duplicates`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Poser les fondations communes nécessaires à toutes les user stories.

**⚠️ CRITICAL**: Aucune user story ne démarre avant la fin de cette phase.

- [X] T004 Implémenter le calcul d’état `DuplicateWarningState` (groupes, propositions impactées, booléen global) basé sur `guessed_author_id` dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T005 Ajouter les hooks DOM partagés (`data-controller`, `data-target`, `data-action`) sur le formulaire dans `app/views/guesses/new.html.erb`
- [X] T006 Ajouter les attributs de test stables (`data-testid`) pour indicateurs et modal dans `app/views/guesses/new.html.erb`

**Checkpoint**: Fondation prête — US1/US2/US3 peuvent être implémentées.

---

## Phase 3: User Story 1 - Signaler les doublons en temps réel (Priority: P1) 🎯 MVP

**Goal**: Afficher/retirer l’indicateur de doublon immédiatement lors des changements de sélection.

**Independent Test**: En modifiant les radios sur plusieurs propositions dans `/games/:id/guesses/new`, l’indicateur apparaît/disparaît en temps réel sans soumission.

### Tests for User Story 1

- [X] T007 [US1] Ajouter un test système “doublon sur deux propositions affiche deux indicateurs” dans `test/system/guesses_duplicate_warning_test.rb`
- [X] T008 [US1] Ajouter un test système “résolution d’un doublon retire les indicateurs concernés” dans `test/system/guesses_duplicate_warning_test.rb`

### Implementation for User Story 1

- [X] T009 [US1] Implémenter l’écoute des changements radio et le recalcul en continu dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T010 [US1] Implémenter l’affichage/masquage de l’indicateur inline par proposition dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T011 [US1] Ajouter le markup d’indicateur visible sur chaque carte proposition dans `app/views/guesses/new.html.erb`

**Checkpoint**: US1 est démontrable et testable indépendamment.

---

## Phase 4: User Story 2 - Avertir à la soumission (Priority: P2)

**Goal**: Afficher une modal bloquante détaillant les doublons avant envoi du formulaire.

**Independent Test**: Avec doublons, le submit ouvre la modal détaillée; sans doublon, le submit ne montre pas de modal.

### Tests for User Story 2

- [X] T012 [US2] Ajouter un test système “soumission avec doublons ouvre la modal de confirmation” dans `test/system/guesses_duplicate_warning_test.rb`
- [X] T013 [US2] Ajouter un test système “soumission sans doublon bypass la modal” dans `test/system/guesses_duplicate_warning_test.rb`
- [X] T014 [US2] Ajouter un test système “la modal liste nom + propositions concernées” dans `test/system/guesses_duplicate_warning_test.rb`

### Implementation for User Story 2

- [X] T015 [US2] Intercepter l’événement submit et bloquer l’envoi quand `has_duplicates=true` dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T016 [US2] Construire le rendu de la liste détaillée des doublons (nom + numéros/lignes de proposition) dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T017 [US2] Ajouter le markup complet de modal (contenu, boutons Annuler/Confirmer, accessibilité) dans `app/views/guesses/new.html.erb`

**Checkpoint**: US2 est démontrable et testable indépendamment.

---

## Phase 5: User Story 3 - Autoriser les doublons intentionnels (Priority: P3)

**Goal**: Permettre la soumission finale si l’utilisateur confirme malgré les doublons.

**Independent Test**: Avec doublons, `Confirmer` soumet effectivement les devinettes et redirige vers la partie.

### Tests for User Story 3

- [X] T018 [US3] Ajouter un test système “Annuler ferme la modal sans soumettre” dans `test/system/guesses_duplicate_warning_test.rb`
- [X] T019 [US3] Ajouter un test système “Confirmer soumet malgré doublons” dans `test/system/guesses_duplicate_warning_test.rb`

### Implementation for User Story 3

- [X] T020 [US3] Implémenter l’action `Annuler` (fermeture modal + focus retour) dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T021 [US3] Implémenter l’action `Confirmer` (soumission forcée une seule fois) dans `app/javascript/controllers/guess_duplicates_controller.js`
- [X] T022 [US3] Ajouter les attributs d’action Stimulus des boutons `Annuler`/`Confirmer` dans `app/views/guesses/new.html.erb`

**Checkpoint**: US3 est démontrable et testable indépendamment.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalisation transverse, documentation, validation rapide.

- [X] T023 [P] Documenter la feature dans la section Features/Gameplay de `README.md`
- [X] T024 [P] Ajouter la feature dans la section `v1.2.3` du changelog de `README.md`
- [X] T025 Exécuter la validation rapide décrite dans `specs/013-duplicate-guess-warning/quickstart.md` et consigner le résultat dans `specs/013-duplicate-guess-warning/quickstart.md` (section Validation Results)
- [X] T026 [P] Mesurer `SC-001` (latence de mise à jour indicateur) via protocole reproductible et documenter les résultats dans `specs/013-duplicate-guess-warning/quickstart.md`
- [X] T027 [P] Exécuter un test utilisateur guidé pour `SC-004` (détection correcte de doublons) et documenter le taux obtenu dans `specs/013-duplicate-guess-warning/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: démarrage immédiat
- **Phase 2 (Foundational)**: dépend de Phase 1 — bloque toutes les user stories
- **Phase 3/4/5 (User Stories)**: dépendent de Phase 2
- **Phase 6 (Polish)**: dépend des user stories livrées

### User Story Dependencies

- **US1 (P1)**: dépend uniquement de la fondation
- **US2 (P2)**: dépend de la fondation et réutilise l’état doublon de US1
- **US3 (P3)**: dépend de la modal US2

### Within Each User Story

- Tests système d’abord, puis implémentation
- Contrôleur Stimulus avant finalisation du markup associé
- Story validée avant passage à la priorité suivante

### Story Completion Order

1. US1 → 2. US2 → 3. US3

---

## Parallel Opportunities

- **Setup**: T001 et T002 peuvent être réalisés en parallèle (fichiers différents)
- **Foundational**: T005 et T006 peuvent être parallélisées après T004
- **US1**: T007 et T008 en parallèle; T010 et T011 en parallèle après T009
- **US2**: T012/T013/T014 en parallèle; T016 et T017 en parallèle après T015
- **US3**: T018 et T019 en parallèle; T020 et T022 en parallèle avant T021
- **Polish**: T023, T024, T026 et T027 en parallèle

---

## Parallel Example: User Story 1

```bash
# Tests US1 en parallèle
T007 test/system/guesses_duplicate_warning_test.rb
T008 test/system/guesses_duplicate_warning_test.rb

# Implémentation US1 partiellement parallèle (après T009)
T010 app/javascript/controllers/guess_duplicates_controller.js
T011 app/views/guesses/new.html.erb
```

---

## Parallel Example: User Story 2

```bash
# Tests US2 en parallèle
T012 test/system/guesses_duplicate_warning_test.rb
T013 test/system/guesses_duplicate_warning_test.rb
T014 test/system/guesses_duplicate_warning_test.rb

# Implémentation US2 partiellement parallèle (après T015)
T016 app/javascript/controllers/guess_duplicates_controller.js
T017 app/views/guesses/new.html.erb
```

---

## Parallel Example: User Story 3

```bash
# Tests US3 en parallèle
T018 test/system/guesses_duplicate_warning_test.rb
T019 test/system/guesses_duplicate_warning_test.rb

# Implémentation US3 partiellement parallèle
T020 app/javascript/controllers/guess_duplicates_controller.js
T022 app/views/guesses/new.html.erb
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Finir Phase 1 + Phase 2
2. Livrer US1 (T007 → T011)
3. Valider le comportement temps réel indépendamment

### Incremental Delivery

1. Ajouter US2 (modal bloquante détaillée)
2. Ajouter US3 (confirmation autorisant la soumission)
3. Finaliser documentation README + changelog `v1.2.3`

### Team Parallel Strategy

1. Un dev sur tests système (`test/system/guesses_duplicate_warning_test.rb`)
2. Un dev sur contrôleur Stimulus (`app/javascript/controllers/guess_duplicates_controller.js`)
3. Un dev sur vue/README (`app/views/guesses/new.html.erb`, `README.md`)
