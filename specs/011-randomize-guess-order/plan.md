# Implementation Plan: Randomisation de l’ordre des propositions

**Branch**: `011-randomize-guess-order` | **Date**: 2026-03-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/011-randomize-guess-order/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Garantir un ordre de propositions aléatoire, partagé entre joueurs et stable pendant toute la manche de devinette, en persistant un rang d’affichage figé au passage en phase `guessing`. L’implémentation cible le flux Rails existant (`Game#start_guessing!`, récupération des propositions pour `GuessesController#new`, refus des soumissions tardives) avec migration minimale, tests ciblés (model/controller/system) et mise à jour documentaire produit.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.x  
**Primary Dependencies**: Rails, ActiveRecord, Devise, Turbo, Stimulus, Tailwind CSS, SQLite3  
**Storage**: SQLite (dev/test), ActiveRecord (migration pour persistance d’ordre de devinette)  
**Testing**: Minitest (`test/models`, `test/controllers`, `test/system`)  
**Target Platform**: Application web Rails (navigateurs modernes desktop/mobile)  
**Project Type**: Monolithe web Rails  
**Performance Goals**:

- p95 rendu du formulaire de devinettes (`GET /games/:game_id/guesses/new`) < 200ms pour jusqu’à 30 propositions
- assignment initial de l’ordre au passage `collecting -> guessing` < 100ms pour 30 propositions
- stabilité d’ordre en rechargement: 100% (SC-003)
**Constraints**:
- ordre unique par manche, commun à tous les joueurs
- fermeture des soumissions dès l’entrée en phase `guessing`
- ordre persisté et relu (pas de recalcul à la volée par requête)
- pas d’exposition d’information temporelle de soumission via l’ordre affiché
- changement minimal, sans refonte UI ni nouvelle API publique JSON
**Scale/Scope**: 1 flux gameplay principal, ~8-12 fichiers applicatifs + 1 migration + tests + documentation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: design ciblé autour de `Game`, `Proposal` et `GuessesController`, sans abstraction additionnelle
- [x] Testing: stratégie définie pour randomisation, stabilité, refus hors collecte et non-régression gameplay
- [x] UX consistency: aucun nouveau composant; conservation des patterns d’écran/flash existants et vérification d’accessibilité du flux
- [x] Performance: budgets p95/temps d’assignation définis + protocole de mesure quickstart
- [x] Quality gates: tests ciblés + suite Rails + Rubocop/Brakeman identifiés

## Project Structure

### Documentation (this feature)

```text
specs/011-randomize-guess-order/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── randomize-guess-order.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── guesses_controller.rb
│   └── proposals_controller.rb
├── models/
│   ├── game.rb
│   └── proposal.rb
└── views/
    └── guesses/new.html.erb

db/
└── migrate/

test/
├── models/
│   ├── game_test.rb
│   └── proposal_test.rb
├── controllers/
│   └── guesses_controller_test.rb
└── system/
    └── guess_order_randomization_test.rb

README.md
```

**Structure Decision**: Conserver le monolithe Rails existant. Implémenter la persistance d’ordre au niveau du domaine (`Game`/`Proposal`), consommer cet ordre dans le flux de devinettes existant, et couvrir via tests Minitest sans nouvelle couche d’architecture.

## Phase 0: Research Plan

1. Choisir le mécanisme de persistance d’ordre par manche (champ dédié vs table dédiée).
2. Définir le moment exact d’assignation de l’ordre figé et sa robustesse transactionnelle.
3. Définir la stratégie d’affichage ordonné côté `GuessesController` et sa stabilité multi-joueurs/reload.
4. Vérifier les implications edge cases (0/1 proposition, soumissions tardives, soumissions simultanées).
5. Définir la stratégie de tests et de mesure performance alignée constitution.
6. Définir la mise à jour documentaire (README + changelog 1.2.2).

Livrable: `research.md` (décisions, rationales, alternatives).

## Phase 1: Design & Contracts Plan

1. Formaliser entités, champs et invariants dans `data-model.md`.
2. Spécifier les contrats HTTP des flux impactés dans `contracts/randomize-guess-order.openapi.yaml`.
3. Définir scénarios de validation manuelle et commandes de test dans `quickstart.md`.
4. Mettre à jour le contexte agent via script Speckit.

Livrables: `data-model.md`, `contracts/randomize-guess-order.openapi.yaml`, `quickstart.md`, contexte agent mis à jour.

## Post-Design Constitution Check

- [x] Code quality: modèle de données simple (ordre persisté) et responsabilités conservées
- [x] Testing: plan couvre invariants domaine, intégration contrôleur et flux utilisateur
- [x] UX consistency: mêmes écrans/composants, seule la séquence des propositions change
- [x] Performance: budget explicite + protocole de mesure défini dans quickstart
- [x] Quality gates: commandes lint/tests listées pour validation locale et CI

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |

Aucune violation constitutionnelle nécessitant dérogation.
