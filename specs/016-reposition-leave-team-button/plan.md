# Implementation Plan: Repositionnement du bouton quitter l’équipe

**Branch**: `016-reposition-leave-team-button` | **Date**: 2026-03-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/016-reposition-leave-team-button/spec.md`

## Summary

Déplacer l’action de sortie d’équipe depuis l’en-tête de page vers la ligne du membre connecté dans la section des membres, avec alignement à droite, adaptation mobile (seconde ligne sous les informations membre), et libellé localisé avec fallback `Quitter l'équipe`. Le comportement métier de `DELETE /teams/:team_id/leave` reste inchangé. La livraison inclut la mise à jour du changelog dans `README.md` pour la version **1.3.3**.

## Technical Context

**Language/Version**: Ruby 3.4.6, Rails 8.1.x  
**Primary Dependencies**: Rails (ActionView/ERB), Devise, Turbo (`button_to`), Tailwind CSS 4, I18n  
**Storage**: SQLite via ActiveRecord (aucun changement de schéma)  
**Testing**: Minitest (controller + integration/system)  
**Target Platform**: Application web Rails (desktop + mobile responsive)
**Project Type**: Monolithe web Rails  
**Performance Goals**: Aucun coût serveur additionnel; rendu de la vue équipe sans régression perceptible; action de sortie conserve latence existante (<2s p95 UX)  
**Constraints**: Aucun changement métier sur `memberships#leave`; respect strict des autorisations existantes; accessibilité de l’action (clavier + lisibilité); ajout au changelog README v1.3.3  
**Scale/Scope**: Changement ciblé UI + i18n + tests + documentation (≈6 à 9 fichiers)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: portée limitée à l’affichage/label, sans refactor hors scope
- [x] Testing: stratégie définie pour visibilité, positionnement, label localisé et non-régression leave flow
- [x] UX consistency: patterns visuels existants conservés + vérification responsive/mobile
- [x] Performance: budget défini (pas de requêtes supplémentaires, pas de chevauchement visuel)
- [x] Quality gates: exécution de tests ciblés + lint/format + vérification CI locale avant revue

## Project Structure

### Documentation (this feature)

```text
specs/016-reposition-leave-team-button/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── leave-team-ui.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── views/
│   └── teams/show.html.erb
├── helpers/
│   └── teams_helper.rb (à créer si absent)
└── controllers/
    └── memberships_controller.rb (inchangé métier, utilisé comme référence)

config/
└── locales/
    ├── fr.yml
    └── en.yml (si présent)

test/
├── controllers/
│   └── memberships_controller_test.rb
└── system/
    ├── team_leave_button_positioning_test.rb
    └── team_leave_button_localization_test.rb

app/assets/stylesheets/application.css

README.md
```

**Structure Decision**: Conserver la structure monolithique Rails existante; implémentation minimale sur vue + i18n + tests + documentation.

## Phase 0: Research Plan

1. Valider la stratégie de positionnement dans une ligne membre sans ambiguïté d’action.
2. Définir l’approche responsive mobile (seconde ligne alignée à droite) sans collision visuelle.
3. Définir le contrat de libellé localisé avec fallback `Quitter l'équipe`.
4. Vérifier l’absence de changement métier sur `memberships#leave`.
5. Définir la convention d’entrée changelog `README.md` pour la version 1.3.3.

**Output**: `research.md` avec décisions, justifications, alternatives.

## Phase 1: Design & Contracts Plan

1. Formaliser les entités impactées (Team, Membership, LeaveTeamActionViewState) sans migration.
2. Spécifier le contrat HTTP existant de leave team (non modifié) et les attentes UI associées.
3. Définir le quickstart de validation manuelle desktop/mobile + i18n.
4. Lister les validations de documentation incluant l’entrée changelog README v1.3.3.

**Output**: `data-model.md`, `contracts/leave-team-ui.openapi.yaml`, `quickstart.md`.

## Post-Design Constitution Check

- [x] Code quality: design simple, sans nouvelle couche ni complexité inutile
- [x] Testing: cas critiques couverts (rendu, responsive, autorisation, non-régression leave)
- [x] UX consistency: action contextualisée sur la ligne du membre connecté, libellé explicite/localisé
- [x] Performance: aucun appel serveur supplémentaire requis
- [x] Quality gates: plan de vérification exécutable en local/CI

## Complexity Tracking

Aucune violation constitutionnelle identifiée.
