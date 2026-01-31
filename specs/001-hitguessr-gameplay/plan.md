# Implementation Plan: HitGuessr - jeu de devinettes musicales en équipe

**Branch**: `001-hitguessr-gameplay` | **Date**: 2026-01-31 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-hitguessr-gameplay/spec.md`

## Summary

Application web de jeu musical en équipe permettant à des joueurs de soumettre des propositions musicales (liens YouTube ou autre), puis de deviner qui a proposé quelle musique. Le système gère trois phases (collecte, devinettes, résultats) avec classement final. Stack technique : Ruby on Rails 8.1.2 avec SQLite, Devise pour l'authentification, et TailwindCSS v4.1 pour le styling.

## Technical Context

**Language/Version**: Ruby 3.4.6  
**Framework**: Ruby on Rails 8.1.2  
**Primary Dependencies**: Devise (authentification), TailwindCSS v4.1 (styling)  
**Storage**: SQLite (single-instance, local-first)  
**Testing**: Minitest (Rails default), System tests avec Capybara  
**Target Platform**: Web (navigateur moderne, responsive)  
**Project Type**: Web application (monolithique Rails)  
**Performance Goals**: Résultats affichés en <2s (SC-004)  
**Constraints**: Application single-instance, pas de microservices, pas d'optimisation prématurée  
**Scale/Scope**: Petite équipe ou développeur solo, équipes de 3-10 joueurs par partie

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
  - Rails conventions (MVC, RESTful routes) garantissent lisibilité
  - Modèles ActiveRecord simples, contrôleurs directs
  - 6 modèles, 6 contrôleurs métier + ApplicationController - scope maîtrisé
- [x] Testing: test strategy defined for all changed behaviors
  - Minitest pour tests unitaires (modèles, validations)
  - System tests Capybara pour flux utilisateur (phases de jeu)
  - Coverage: transitions de phase, validations URL, calcul scores
- [x] UX consistency: UI/UX alignment and accessibility checks planned
  - TailwindCSS v4.1 pour design cohérent
  - Contraste et navigation clavier vérifiés sur écrans principaux
  - Wireframes définis dans contracts/views.md
- [x] Performance: budgets and measurement plan defined
  - SC-004: résultats en <2s pour 95% des sessions
  - Mesure via logs Rails et tests de charge simples
  - SQLite suffisant pour scope single-instance
- [x] Quality gates: lint/format/CI checks identified
  - RuboCop pour linting Ruby
  - ERB Lint pour templates
  - CI avec `rails test` obligatoire avant merge

**Post-design re-evaluation**: ✅ All gates pass. Design artifacts (data-model.md, contracts/) align with constitution requirements.

## Project Structure

### Documentation (this feature)

```text
specs/001-hitguessr-gameplay/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Rails 8.1.2 standard structure
app/
├── controllers/
│   ├── application_controller.rb
│   ├── teams_controller.rb
│   ├── memberships_controller.rb
│   ├── games_controller.rb
│   ├── proposals_controller.rb
│   ├── guesses_controller.rb
│   └── results_controller.rb
├── models/
│   ├── user.rb
│   ├── team.rb
│   ├── membership.rb
│   ├── game.rb
│   ├── proposal.rb
│   └── guess.rb
├── views/
│   ├── layouts/
│   ├── teams/
│   ├── games/
│   ├── proposals/
│   └── guesses/
└── helpers/

config/
├── routes.rb
└── database.yml

db/
├── migrate/
└── schema.rb

test/
├── controllers/
├── models/
├── system/
└── test_helper.rb
```

**Structure Decision**: Application Rails monolithique standard. Les contrôleurs suivent les ressources RESTful (Teams, Games, Proposals, Guesses). Les modèles ActiveRecord reflètent les entités métier. Tests organisés par type (models, controllers, system).

## Complexity Tracking

> Aucune violation de la constitution identifiée. Le scope reste simple et maintenable.

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| - | - | - |
