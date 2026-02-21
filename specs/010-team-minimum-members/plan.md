# Implementation Plan: Seuil minimum de membres pour démarrer une partie

**Branch**: `010-team-minimum-members` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/010-team-minimum-members/spec.md`

## Summary

Ajouter une règle métier bloquante: une partie ne peut être créée que si l'équipe compte au moins 3 membres actifs (ici: memberships existants), avec vérification serveur transactionnelle au moment de `GamesController#create`, message explicite en cas de refus, et cohérence UX entre `teams/show` et `games/new`. L'implémentation reste minimale dans l'architecture Rails existante (validation/guard métier + tests ciblés + documentation README/changelog en anglais).

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.x  
**Primary Dependencies**: Rails, ActiveRecord, Devise, Turbo, Stimulus, Tailwind CSS, SQLite3  
**Storage**: SQLite (dev/test), ActiveRecord  
**Testing**: Minitest (model/controller/system), Capybara + Selenium pour system tests  
**Target Platform**: Application web Rails (dev macOS/Linux, déploiement Docker/Kamal)  
**Project Type**: Monolithe web Rails  
**Performance Goals**: SC-003 maintenu: message résultat visible < 2s dans ≥95% des tentatives  
**Constraints**:

- Seuil fixe à 3 (non configurable)
- Comptage sur memberships existants (pas de statut membership dans le schéma actuel)
- Vérification côté serveur dans la transaction de création
- Conserver toutes les règles de lancement existantes (organisateur, partie active unique, etc.)
- Messages explicites succès/refus
**Scale/Scope**: 1 flux principal de création de partie, ~8-12 fichiers (model/controller/views/tests/docs/spec artefacts)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: changement ciblé, compatible patterns Rails existants, sans couche supplémentaire inutile
- [x] Testing: couverture prévue model + controller + system pour les comportements modifiés
- [x] UX consistency: feedback explicite + alignement des écrans `teams/show` et `games/new`
- [x] Performance: budget SC-003 explicite, ajout d'un comptage membership indexé et mesure p95 prévue
- [x] Quality gates: exécution des tests ciblés puis suite rails test/CI prévue

## Project Structure

### Documentation (this feature)

```text
specs/010-team-minimum-members/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── team-minimum-members.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── games_controller.rb
├── models/
│   └── game.rb
└── views/
    ├── teams/show.html.erb
    └── games/new.html.erb

config/
└── locales/
    ├── fr.yml
    └── en.yml

test/
├── models/
│   └── game_test.rb
├── controllers/
│   └── games_controller_test.rb
└── system/
    └── teams_test.rb

README.md
```

**Structure Decision**: Conserver la structure Rails monolithique existante; implémentation au plus près des composants déjà responsables du lancement de partie (model/controller/views/tests), sans migration de schéma.

## Phase 0: Research Plan

1. Valider le meilleur point d'application de la règle (invariant modèle + garde contrôleur).
2. Définir la stratégie de concurrence/transaction pour éviter les courses de type TOCTOU.
3. Trancher la définition opérationnelle de "membres actifs/confirmés" dans le schéma actuel.
4. Fixer la stratégie UX/messages et la portée i18n.
5. Définir la stratégie de tests minimaux robustes et de mesure performance liée à SC-003.
6. Confirmer la convention documentaire README/changelog en anglais.

Livrable: `research.md` (décisions + rationnels + alternatives).

## Phase 1: Design & Contracts Plan

1. Formaliser les entités impactées et invariants dans `data-model.md`.
2. Spécifier le contrat HTTP de création de partie avec règle des 3 membres dans `contracts/`.
3. Détailler les scénarios de validation manuelle et commandes de test dans `quickstart.md`.
4. Préparer la mise à jour README/changelog alignée avec la feature #010.

Livrables: `data-model.md`, `contracts/team-minimum-members.openapi.yaml`, `quickstart.md`.

## Post-Design Constitution Check

- [x] Code quality: design simple, pas d'abstraction inutile, invariants centralisés
- [x] Testing: plan de tests couvre succès, refus, cas frontière (2/3 membres), non-régression
- [x] UX consistency: messages explicites et comportement homogène sur les points d'entrée UI
- [x] Performance: coût de vérification limité (count indexé), budget SC-003 conservé
- [x] Quality gates: lint/tests CI identifiés, validations ciblées prévues

## Complexity Tracking

Aucune violation constitutionnelle nécessitant dérogation.
