# Data Model: Limite d'une partie active par organisateur

**Feature**: 002-single-active-game  
**Date**: 2026-01-31

## Overview

Cette fonctionnalité ne nécessite **aucune modification du schéma de base de données**. Elle s'appuie sur les entités existantes `Game` et `Team` et ajoute uniquement des règles de validation et des méthodes helper.

## Existing Entities (unchanged)

### Game

| Field | Type | Description |
| ----- | ---- | ----------- |
| id | integer | Primary key |
| team_id | integer | FK vers Team |
| status | integer | Enum: 0=collecting, 1=guessing, 2=finished |
| started_at | datetime | Date de passage en phase guessing |
| finished_at | datetime | Date de fin de partie |
| created_at | datetime | Date de création |
| updated_at | datetime | Date de mise à jour |

**Status Values**:

- `collecting` (0): Partie active - phase de collecte des propositions
- `guessing` (1): Partie active - phase de devinettes
- `finished` (2): Partie terminée

**Active Definition**: Une partie est considérée "active" si `status IN (0, 1)`, soit `collecting` ou `guessing`.

### Team

| Field | Type | Description |
| ----- | ---- | ----------- |
| id | integer | Primary key |
| name | string | Nom de l'équipe |
| organizer_id | integer | FK vers User (organisateur) |
| created_at | datetime | Date de création |
| updated_at | datetime | Date de mise à jour |

**Relationship**: `Team has_many :games`

## New Methods (no schema change)

### Game Model

```ruby
# Scope pour filtrer les parties actives
scope :active, -> { where(status: [:collecting, :guessing]) }

# Validation custom
validate :only_one_active_game_per_team, on: :create
```

### Team Model

```ruby
# Retourne la partie active de l'équipe (ou nil)
def active_game
  games.active.first
end

# Retourne true si une partie est en cours
def has_active_game?
  games.active.exists?
end
```

## Business Rules

| Rule ID | Description | Enforcement |
| ------- | ----------- | ----------- |
| BR-001 | Une équipe ne peut avoir qu'une seule partie active à la fois | Validation custom sur Game |
| BR-002 | Une partie est active si son statut est collecting ou guessing | Scope Game.active |
| BR-003 | La contrainte s'applique par équipe, pas globalement | Validation filtre par team_id |

## State Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                        TEAM                                  │
│                                                             │
│  ┌─────────────┐    create     ┌─────────────┐             │
│  │  No active  │ ───────────► │  COLLECTING │             │
│  │    game     │               │   (active)  │             │
│  └─────────────┘               └──────┬──────┘             │
│        ▲                              │                     │
│        │                        start_guessing!             │
│        │                              │                     │
│        │                              ▼                     │
│        │                       ┌─────────────┐             │
│        │                       │  GUESSING   │             │
│        │                       │   (active)  │             │
│        │                       └──────┬──────┘             │
│        │                              │                     │
│        │                          finish!                   │
│        │                              │                     │
│        │                              ▼                     │
│        │                       ┌─────────────┐             │
│        └────── create OK ───── │  FINISHED   │             │
│                                │  (inactive) │             │
│                                └─────────────┘             │
│                                                             │
│  ❌ CREATE BLOCKED while any game is in COLLECTING/GUESSING │
└─────────────────────────────────────────────────────────────┘
```

## Validation Error Message

```text
"Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle."
```

## Database Queries

### Check for active game (validation)

```sql
SELECT 1 FROM games 
WHERE team_id = ? 
AND status IN (0, 1) 
LIMIT 1;
```

Performance: Index sur `team_id` existe déjà (FK), requête O(1) avec index.
