# Implementation Plan: Modification de proposition avant guessing

**Branch**: `[014-proposal-edit-window]` | **Date**: 2026-03-02 | **Spec**: [/specs/014-proposal-edit-window/spec.md](/specs/014-proposal-edit-window/spec.md)
**Input**: Feature specification from `/specs/014-proposal-edit-window/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Permettre à un joueur de modifier sa proposition pendant la phase `collecting`, puis verrouiller toute modification dès `guessing`, en appliquant la règle au moment effectif de soumission. Le même flux accepte aussi le cas sans proposition existante en `collecting` en créant la proposition. L’implémentation cible un comportement de type upsert côté `ProposalsController` sans historisation, avec garde-fous d’autorisation et de phase inchangés.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.2, ERB + Hotwire/Stimulus (importmap)  
**Primary Dependencies**: rails, devise, turbo-rails, stimulus-rails, tailwindcss-rails  
**Storage**: SQLite via ActiveRecord (aucune migration prévue)  
**Testing**: Minitest (`test/controllers`, `test/integration`, `test/system`)  
**Target Platform**: Application web desktop + mobile (navigateurs modernes)
**Project Type**: Monolithe web Rails  
**Performance Goals**: p95 < 500 ms pour les soumissions valides de proposition (création/mise à jour via flux upsert) en recette; validation de phase et autorisation en temps constant; alignement avec `SC-001..SC-005` de la spec  
**Constraints**: Règles d’autorisation existantes inchangées; verrouillage strict en `guessing`; création autorisée en `collecting` via le même flux; aucune historisation des modifications  
**Scale/Scope**: Changement localisé à `ProposalsController`, vues de proposition et tests associés + documentation produit (`README.md`, changelog `v1.2.3`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

Pré-Phase 0: PASS

- [x] Code quality: approche upsert localisée sur flux proposition, sans modification transversale du domaine.
- [x] Testing: scénarios P1/P2/P3 couverts par tests contrôleur/intégration et transition de phase.
- [x] UX consistency: formulaire proposition conserve les patterns UI existants; état verrouillé explicite en `guessing`.
- [x] Performance: pas de nouveau traitement coûteux ni de requêtes supplémentaires non nécessaires.
- [x] Quality gates: exécution prévue de tests ciblés puis suite globale; rubocop disponible si requis.

## Project Structure

### Documentation (this feature)

```text
specs/014-proposal-edit-window/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── proposals-edit-window.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── proposals_controller.rb
├── models/
│   ├── proposal.rb
│   └── game.rb
└── views/
  └── proposals/
    └── new.html.erb

config/
└── routes.rb

test/
├── controllers/
│   └── proposals_controller_test.rb
└── integration/
  └── proposal_edit_window_test.rb

README.md
specs/014-proposal-edit-window/
```

**Structure Decision**: Conserver le monolithe Rails existant. La feature est implémentée sur le flux `proposals` (contrôleur + vue + validations déjà présentes), sans nouveau service ni nouvelle couche.

## Phase 0: Research Output

`research.md` capture les décisions sur:

1. Stratégie contrôleur pour autoriser modification en `collecting` et bloquer en `guessing`
2. Sémantique upsert (création si absent, mise à jour sinon) dans le même flux
3. Absence d’historisation (valeur courante uniquement)
4. Gestion des courses de transition de phase (contrôle à la soumission)
5. Stratégie de tests et impacts documentation release

## Phase 1: Design & Contracts Output

- `data-model.md`: entités métier impactées, invariants et transitions
- `contracts/proposals-edit-window.openapi.yaml`: contrat des endpoints impactés (`new`, `create` avec comportement upsert) et règles de réponse
- `quickstart.md`: guide d’implémentation/validation et checklist QA
- Mise à jour du contexte agent via `.specify/scripts/bash/update-agent-context.sh copilot`

## Constitution Check (Post-Design)

Post-Phase 1: PASS

- [x] Code quality: design centré sur règles métiers de phase avec responsabilités claires.
- [x] Testing: couverture prévue des scénarios de création/modification/verrouillage et transition.
- [x] UX consistency: même parcours joueur, actions cohérentes avec état de phase affiché.
- [x] Performance: aucun coût algorithmique nouveau significatif; opérations DB simples sur clé unique `(game_id, player_id)`.
- [x] Quality gates: validation via tests ciblés + non-régression du flux existant.

## Documentation Requirement

- Le `README.md` DOIT décrire la feature de fenêtre d’édition de proposition.
- Le changelog du `README.md` DOIT contenir une entrée `v1.2.3` incluant cette feature.
- Ces mises à jour documentaires font partie intégrante de ce plan.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |
