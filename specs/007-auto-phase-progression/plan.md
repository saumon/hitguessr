# Implementation Plan: Progression Automatique des Phases de Jeu

**Branch**: `007-auto-phase-progression` | **Date**: 2026-02-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-auto-phase-progression/spec.md`

## Summary

Implémenter la progression automatique des phases de jeu lorsque 100% des joueurs ont soumis leur contribution. Lors de la phase de collecte, si tous les membres de l'équipe ont soumis leur proposition, la partie passe automatiquement en phase de devinettes. Lors de la phase de devinettes, si toutes les devinettes attendues ont été soumises, la partie se termine automatiquement. Les transitions manuelles par l'organisateur restent disponibles.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.2  
**Primary Dependencies**: Turbo/Hotwire, Devise, SQLite3, Tailwind CSS  
**Storage**: SQLite3 (development), compatible PostgreSQL en production  
**Testing**: Minitest (Rails default), Capybara + Selenium pour tests système  
**Target Platform**: Web application (Rails monolith)
**Project Type**: Web application (Rails monolith - single project)  
**Performance Goals**: Transitions automatiques < 5 secondes (synchrone, dans la requête)  
**Constraints**: Row-level locking pour gérer la concurrence des soumissions simultanées  
**Scale/Scope**: Équipes de 2-20 joueurs typiquement

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable (ajout de méthodes dans modèles existants + callbacks)
- [x] Testing: test strategy defined for all changed behaviors (tests unitaires modèle + tests système)
- [x] UX consistency: UI/UX alignment and accessibility checks planned (pas de changement d'interface, juste progression automatique)
- [x] Performance: budgets and measurement plan defined (< 5s, synchrone)
- [x] Quality gates: lint/format/CI checks identified (RuboCop, tests Minitest)

## Project Structure

### Documentation (this feature)

```text
specs/007-auto-phase-progression/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - pas d'API)
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
app/
├── models/
│   ├── game.rb          # Méthodes de détection et transition automatique
│   ├── proposal.rb      # Callback after_create pour vérifier progression
│   └── guess.rb         # Callback after_create pour vérifier terminaison
├── controllers/
│   ├── proposals_controller.rb  # US3: flash notice si auto-progress
│   └── guesses_controller.rb    # US3: flash notice si auto-finish
└── views/
    └── games/           # Inchangé (affichage existant)

test/
├── models/
│   └── game_test.rb     # Tests pour nouvelles méthodes
├── system/
│   └── auto_phase_progression_test.rb  # Tests E2E
└── integration/         # Tests de concurrence si nécessaire
```

**Structure Decision**: Single Rails monolith. Toute la logique est ajoutée dans les modèles existants avec des callbacks. Pas de nouveaux controllers ou routes nécessaires.

## Complexity Tracking

> Aucune violation de la constitution. Le scope est minimal : ajout de méthodes dans les modèles existants sans nouvelle architecture.

## Constitution Re-Check (Post-Design)

### Réévaluation après Phase 1 design - 2026-02-14

- [x] Code quality: ✅ Design final respecte la single responsibility (Game gère ses transitions, callbacks dans Proposal/Guess délèguent)
- [x] Testing: ✅ Stratégie de test définie dans quickstart.md (unitaires + système)
- [x] UX consistency: ✅ Pas de changement d'interface, comportement transparent pour l'utilisateur
- [x] Performance: ✅ Synchrone dans la requête, < 5s garanti par le locking simple
- [x] Quality gates: ✅ RuboCop + Minitest existants couvrent les changements

**Statut**: ✅ Prêt pour Phase 2 (génération des tâches)
