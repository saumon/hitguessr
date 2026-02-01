# Data Model: Annulation d'une partie active

**Feature**: 003-cancel-active-game  
**Date**: 2026-02-01

## Summary

Cette feature ne modifie pas le schéma de base de données. Elle utilise les entités existantes et leurs relations de suppression en cascade.

---

## Entities Involved

### Game

| Attribute      | Type     | Notes                                            |
|----------------|----------|--------------------------------------------------|
| id             | integer  | PK                                               |
| team_id        | integer  | FK → teams                                       |
| status         | integer  | enum: collecting (0), guessing (1), finished (2) |
| started_at     | datetime | nullable                                         |
| finished_at    | datetime | nullable                                         |
| created_at     | datetime |                                                  |
| updated_at     | datetime |                                                  |

**Associations**:

- `belongs_to :team`
- `has_many :proposals, dependent: :destroy`
- `has_many :guesses, through: :proposals`

### Proposal

| Attribute  | Type    | Notes              |
|------------|---------|--------------------|
| id         | integer | PK                 |
| game_id    | integer | FK → games         |
| player_id  | integer | FK → users         |
| url        | string  | submitted song URL |

**Associations**:

- `belongs_to :game`
- `has_many :guesses, dependent: :destroy`

### Guess

| Attribute         | Type    | Notes          |
|-------------------|---------|----------------|
| id                | integer | PK             |
| proposal_id       | integer | FK → proposals |
| player_id         | integer | FK → users     |
| guessed_author_id | integer | FK → users     |

**Associations**:

- `belongs_to :proposal`

---

## Cascade Deletion Order

```text
Game.destroy
  └── Proposal.destroy (for each proposal)
        └── Guess.destroy (for each guess)
```

Rails handles this via `dependent: :destroy` on associations.

---

## No Schema Changes Required

- Existing `dependent: :destroy` on `Game → Proposals` and `Proposal → Guesses` already ensures cascade deletion.
- No new columns, indices, or tables needed for this feature.
