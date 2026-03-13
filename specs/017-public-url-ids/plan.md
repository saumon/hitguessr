# Implementation Plan: Public IDs For Public URLs

**Branch**: `017-public-url-ids` | **Date**: 2026-03-13 | **Spec**: `/specs/017-public-url-ids/spec.md`
**Input**: Feature specification from `/specs/017-public-url-ids/spec.md`

## Summary

Remplacer les IDs numeriques exposes dans les URLs publiques des parties et equipes par des IDs publics courts au format `gm_<segment>` et `tm_<segment>`, avec segment base62 fixe de 8 caracteres, unicite globale, et rejection stricte des IDs numeriques sur endpoints publics (404 sans redirection).

Approche technique: introduire un concern de modele `PublicId` (comme demande par l'utilisateur) pour la generation automatique avant creation, ajoute de contraintes DB (unicite), backfill complet des donnees historiques, puis bascule des resolvers/routes vers `public_id` en second deploiement.

## Technical Context

**Language/Version**: Ruby 3.4.6 + Rails 8.1.2  
**Primary Dependencies**: ActiveRecord, ActionController, Devise, SecureRandom  
**Storage**: SQLite (dev/test), schema ActiveRecord  
**Testing**: Rails Minitest (model/controller/integration/system)  
**Target Platform**: Application web Rails serveur Linux (containerisable via Docker/Kamal)
**Project Type**: Web application monolithique Rails  
**Performance Goals**: resolution d'une ressource publique par `public_id` en requete indexee (p95 < 100 ms cote application sur env de reference), 0 N+1 ajoute sur pages show team/game  
**Constraints**: 404 obligatoire pour ID numerique sur endpoints publics, 2 deploiements (backfill puis activation), aucune regression des parcours existants  
**Scale/Scope**: migration de toutes les lignes historiques `games` + `teams`; parcours publics teams/games + routes imbriquees dependantes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: changement borne a models/controllers/routes/migrations avec concern reutilisable
- [x] Testing: couverture prevue model + request/integration + migration/backfill
- [x] UX consistency: aucun changement de parcours, seulement format URL public + erreurs 404 homogenes
- [x] Performance: lookup via index unique sur `public_id`; cible p95 definie
- [x] Quality gates: execution de tests cibles + suite, lint/style CI existants

## Project Structure

### Documentation (this feature)

```text
specs/017-public-url-ids/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── public-ids.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── games_controller.rb
│   └── teams_controller.rb
├── models/
│   ├── concerns/
│   │   └── public_id.rb
│   ├── game.rb
│   └── team.rb
└── views/
    ├── games/
    └── teams/

config/
└── routes.rb

db/
├── migrate/
└── schema.rb

test/
├── models/
├── controllers/
└── integration/
```

**Structure Decision**: conserver la structure monolithique Rails existante. Ajouter un concern partage `app/models/concerns/public_id.rb`, enrichir `Game`/`Team`, migrer schema/index, puis adapter resolution de ressources dans controllers/routes et liens publics.

## Phase 0 Research Output

Voir `/specs/017-public-url-ids/research.md` pour les decisions validees sur:

- concern `PublicId` et derive de prefixe explicite par modele
- strategie d'unicite globale
- backfill en 2 deploiements
- politique de collision (retry max 5)

## Phase 1 Design Output

Voir:

- `/specs/017-public-url-ids/data-model.md`
- `/specs/017-public-url-ids/contracts/public-ids.openapi.yaml`
- `/specs/017-public-url-ids/quickstart.md`

## Post-Design Constitution Check

- [x] Code quality: design simple (concern + overrides par modele), pas de sur-abstraction
- [x] Testing: plan de tests inclut generation, collisions, backfill, lookup, et 404 numerique
- [x] UX consistency: URLs et redirections internes convergent vers IDs publics, messages d'erreur coherents
- [x] Performance: indexes uniques sur `public_id` + lookup direct, aucun scan table requis
- [x] Quality gates: sequence de verification documentee dans quickstart

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |
