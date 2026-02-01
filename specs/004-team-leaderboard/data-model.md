# Data Model: Classement général de l'équipe

**Feature**: 004-team-leaderboard  
**Date**: 2026-02-01

## Summary

Cette feature ne modifie pas le schéma de base de données. Elle utilise les entités existantes et calcule le classement à la volée.

---

## Entities Involved

### Team

| Attribute   | Type    | Notes                        |
|-------------|---------|------------------------------|
| id          | integer | PK                           |
| name        | string  | Nom de l'équipe              |
| organizer_id| integer | FK → users                   |

**Associations existantes**:

- `has_many :games`
- `has_many :members, through: :memberships`

**Nouvelle méthode** (non persistée):

- `leaderboard` → Array of `{ player:, score:, rank: }`

### Game

| Attribute   | Type     | Notes                                            |
|-------------|----------|--------------------------------------------------|
| id          | integer  | PK                                               |
| team_id     | integer  | FK → teams                                       |
| status      | integer  | enum: collecting (0), guessing (1), finished (2) |

**Méthodes existantes utilisées**:

- `calculate_scores` → Array of `{ player:, score: }`
- `ranking` → Array of `{ player:, score:, rank: }`

### User (Player)

| Attribute | Type    | Notes       |
|-----------|---------|-------------|
| id        | integer | PK          |
| name      | string  | Nom affiché |

---

## Leaderboard Data Structure (non persistée)

Le classement général est calculé à la volée et retourne :

```ruby
[
  { player: User, score: Integer, rank: Integer },
  { player: User, score: Integer, rank: Integer },
  ...
]
```

**Règles de calcul**:

1. Filtrer `team.games.finished`
2. Pour chaque partie, récupérer `calculate_scores`
3. Agréger les scores par joueur (somme)
4. Trier par score décroissant
5. Assigner les rangs (ex aequo = même rang)

---

## No Schema Changes Required

- Aucune nouvelle table
- Aucune nouvelle colonne
- Aucun index supplémentaire
- Calcul entièrement à la volée (FR-006)
