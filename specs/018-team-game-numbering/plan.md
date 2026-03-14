# Implementation Plan: Team-Scoped Game Numbering

**Branch**: `018-team-game-numbering` | **Date**: 2026-03-14 | **Spec**: `/specs/018-team-game-numbering/spec.md`
**Input**: Feature specification from `/specs/018-team-game-numbering/spec.md`

## Summary

Remplacer l'affichage base sur `games.id` par un numero de partie sequentiel par equipe (`team_game_number`), persiste et immuable apres creation. Le plan technique ajoute une colonne dediee sur `games`, un index unique composite `(team_id, team_game_number)`, une attribution atomique a la creation avec retry borne (maximum 3 tentatives, backoff 10/25/50 ms) sur collision concurrente, un backfill historique ordonne par `created_at ASC`, puis la bascule des vues/listes vers ce numero d'equipe.

## Technical Context

**Language/Version**: Ruby 3.4.6 + Rails 8.1.2  
**Primary Dependencies**: ActiveRecord, ActionController, Devise, SQLite adapter, I18n  
**Storage**: SQLite via schema ActiveRecord (dev/test), RDBMS compatible en production  
**Testing**: Rails Minitest (model/controller/integration/system)  
**Target Platform**: Application web Rails monolithique (Puma, Docker/Kamal)  
**Project Type**: Web application monolithique Rails  
**Performance Goals**: creation de partie avec attribution du numero en section critique courte (p95 < 150 ms cote app sur env de reference), rendu des listes sans requete supplementaire  
**Constraints**: aucune renumerotation retroactive, immutabilite du `team_id` apres creation, unicite stricte `(team_id, team_game_number)`, retry borne (maximum 3 tentatives, backoff 10/25/50 ms) en cas de collision concurrente recuperable  
**Scale/Scope**: migration de toutes les parties historiques liees a une equipe + parcours `team games index`, creation de partie, ecran detail partie et textes UI associes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Code quality: changement borne a migration, modele `Game`, controlleur de creation et vues de presentation
- [x] Testing: strategie definie pour backfill historique, attribution a la creation, concurrence et stabilite des numeros
- [x] UX consistency: memes parcours utilisateur, seule la valeur affichee change (numero d'equipe lisible)
- [x] Performance: index composite + section critique bornee et budget p95 explicite
- [x] Quality gates: tests cibles + suite complete, puis checks CI usuels (lint/formatting/security deja en place)

## Project Structure

### Documentation (this feature)

```text
specs/018-team-game-numbering/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── team-game-numbering.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── games_controller.rb
├── models/
│   ├── game.rb
│   └── team.rb
├── views/
│   ├── games/
│   └── teams/
└── helpers/

db/
├── migrate/
└── schema.rb

test/
├── models/
├── controllers/
└── integration/
```

**Structure Decision**: conserver le monolithe Rails existant. Implementer la logique de numerotation dans `Game` et la creation verrouillee de `GamesController`, puis propager le champ persiste dans les vues existantes sans changer la structure de routage.

## Phase 0 Research Output

Voir `/specs/018-team-game-numbering/research.md` pour les decisions validees sur:

- strategie de backfill historique et determinisme
- allocation concurrente avec retry borne (maximum 3 tentatives, backoff 10/25/50 ms)
- contraintes DB/validation pour garantir l'unicite par equipe
- regle d'immutabilite de rattachement equipe

## Phase 1 Design Output

Voir:

- `/specs/018-team-game-numbering/data-model.md`
- `/specs/018-team-game-numbering/contracts/team-game-numbering.openapi.yaml`
- `/specs/018-team-game-numbering/quickstart.md`

## Post-Design Constitution Check

- [x] Code quality: design final simple (champ persiste + index composite + logique d'allocation encapsulee)
- [x] Testing: couverture prevue pour creation, concurrence, migration et affichage coherent
- [x] UX consistency: numerotation lisible et stable sur les ecrans existants, sans changement de flow
- [x] Performance: lecture via index `(team_id, team_game_number)` et ecriture atomique avec retries bornes
- [x] Quality gates: sequence de verification documentee dans quickstart, compatible CI projet (lint/formatting/security inclus)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| None | N/A | N/A |
