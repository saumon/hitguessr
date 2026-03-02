# Implementation Plan: Alerte de doublon de proposition

**Branch**: `[013-duplicate-guess-warning]` | **Date**: 2026-03-02 | **Spec**: [/specs/013-duplicate-guess-warning/spec.md](/specs/013-duplicate-guess-warning/spec.md)
**Input**: Feature specification from `/specs/013-duplicate-guess-warning/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Ajouter un indicateur de doublon en temps réel dans le formulaire de devinettes et une modal de confirmation bloquante à la soumission quand des doublons existent, tout en autorisant la soumission finale. La détection est strictement côté client (égalité stricte, sans normalisation) et n’introduit ni migration ni changement d’API serveur. La livraison inclut aussi la documentation de la feature dans le README et son entrée dans le changelog README pour `v1.2.3`.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.2, ERB + Hotwire/Stimulus (importmap)  
**Primary Dependencies**: rails, stimulus-rails, turbo-rails, tailwindcss-rails, devise  
**Storage**: SQLite via ActiveRecord (pas de changement de schéma prévu)  
**Testing**: Minitest (`test/`), tests système Capybara/Selenium pour le flux UI  
**Target Platform**: Application web desktop + mobile (navigateurs modernes)
**Project Type**: Monolithe web Rails  
**Performance Goals**: Respecter `SC-001` (mise à jour indicateur < 1s dans 95% des interactions) ; ouverture modal perçue immédiate à la soumission  
**Constraints**: Détection doublons client-only ; comparaison stricte (casse/espaces/accents) ; warning bloquant avant POST mais soumission autorisée après confirmation ; accessibilité clavier de la modal  
**Scale/Scope**: Un écran impacté principal (`guesses/new`) + docs README (Features + Changelog `v1.2.3`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: scope is small, readable, and maintainable
- [x] Testing: test strategy defined for all changed behaviors
- [x] UX consistency: UI/UX alignment and accessibility checks planned
- [x] Performance: budgets and measurement plan defined
- [x] Quality gates: lint/format/CI checks identified

Pré-Phase 0: PASS

- [x] Code quality: changement localisé à la vue de devinettes + contrôleur Stimulus dédié, sans couplage serveur supplémentaire.
- [x] Testing: plan de tests système pour détection temps réel, affichage modal, confirmation et absence d’avertissement sans doublon.
- [x] UX consistency: réutilisation des classes Tailwind/neon existantes, modal avec actions explicites `Annuler` / `Confirmer`, navigation clavier.
- [x] Performance: algorithme O(n) côté client (comptage des sélections), budget aligné sur `SC-001`.
- [x] Quality gates: exécution prévue de `bin/rails test` (ou tests ciblés), plus `bin/rubocop` si nécessaire.

## Project Structure

### Documentation (this feature)

```text
specs/013-duplicate-guess-warning/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── guesses-duplicate-warning.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── guesses_controller.rb
├── javascript/
│   └── controllers/
│       ├── index.js
│       └── guess_duplicates_controller.js   # nouveau
└── views/
  └── guesses/
    └── new.html.erb

test/
├── system/
│   └── guesses_duplicate_warning_test.rb    # nouveau
└── controllers/

README.md                                     # feature + changelog v1.2.3
specs/013-duplicate-guess-warning/
```

**Structure Decision**: Monolithe Rails existant conservé. La feature est implémentée via la vue de devinettes et un contrôleur Stimulus local à la page, sans nouveau service backend ni migration.

## Phase 0: Research Output

`research.md` capture les décisions sur:

1. Algorithme client-only de détection des doublons
2. Règle de comparaison stricte des noms
3. Stratégie modal de confirmation bloquante avec détail des conflits
4. Absence de changement API/DB
5. Stratégie de tests et de mesure de performance perçue

## Phase 1: Design & Contracts Output

- `data-model.md`: états UI et entités de détection des doublons (groupes, lignes impactées)
- `contracts/guesses-duplicate-warning.openapi.yaml`: contrat des endpoints impactés (`GET /games/{game_id}/guesses/new`, `POST /games/{game_id}/guesses`) et comportement client-side
- `quickstart.md`: guide d’implémentation, validation, critères d’acceptation, protocole de mesure `SC-001` et protocole de test guidé `SC-004`
- Mise à jour du contexte agent via `.specify/scripts/bash/update-agent-context.sh copilot`

## Constitution Check (Post-Design)

Post-Phase 1: PASS

- [x] Code quality: conception orientée composant Stimulus unique et marquage DOM explicite.
- [x] Testing: scénarios P1/P2/P3 mappés vers tests système déterministes.
- [x] UX consistency: indicateurs inline + modal cohérente avec UI existante, sans nouveaux patterns visuels.
- [x] Performance: recalcul local borné au nombre de propositions affichées.
- [x] Quality gates: commandes de validation documentées dans `quickstart.md`.

## Documentation Requirement

- La feature DOIT être décrite dans `README.md` (section Features et/ou Gameplay Rules).
- La feature DOIT être listée dans le changelog de `README.md` sous `v1.2.3`.
- Ces mises à jour sont incluses dans le périmètre d’implémentation de cette spec.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |
