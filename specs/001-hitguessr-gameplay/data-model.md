# Data Model: HitGuessr

**Date**: 2026-01-31  
**Branch**: `001-hitguessr-gameplay`

---

## Entity Relationship Diagram (ERD)

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │       │    Team     │       │    Game     │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id          │       │ id          │       │ id          │
│ email       │◄──────│ organizer_id│       │ team_id     │───────►│
│ password    │       │ name        │◄──────│ status      │
│ name        │       │ created_at  │       │ created_at  │
│ created_at  │       │ updated_at  │       │ started_at  │
│ updated_at  │       └─────────────┘       │ finished_at │
└─────────────┘              │              └─────────────┘
      │                      │                    │
      │              ┌───────┴───────┐            │
      │              │               │            │
      ▼              ▼               │            ▼
┌─────────────┐                      │    ┌─────────────┐
│ Membership  │                      │    │  Proposal   │
├─────────────┤                      │    ├─────────────┤
│ id          │                      │    │ id          │
│ user_id     │──────────────────────┼────│ player_id   │
│ team_id     │                      │    │ game_id     │
│ created_at  │                      │    │ url         │
│ updated_at  │                      │    │ created_at  │
└─────────────┘                      │    │ updated_at  │
                                     │    └─────────────┘
                                     │          │
                                     │          │
                                     │          ▼
                                     │    ┌─────────────┐
                                     │    │   Guess     │
                                     │    ├─────────────┤
                                     │    │ id          │
                                     │    │ player_id   │───┐
                                     └────│ proposal_id │   │
                                          │ guessed_    │   │
                                          │   author_id │───┤
                                          │ created_at  │   │
                                          │ updated_at  │   │
                                          └─────────────┘   │
                                                            │
                                               ◄────────────┘
                                               (references User)
```

---

## Entities

### User

Personne authentifiée pouvant créer/rejoindre des équipes et participer aux parties.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| email | string | NOT NULL, UNIQUE | Email pour connexion (Devise) |
| encrypted_password | string | NOT NULL | Mot de passe chiffré (Devise) |
| name | string | NOT NULL | Nom affiché du joueur |
| reset_password_token | string | UNIQUE | Token reset password (Devise) |
| reset_password_sent_at | datetime | | (Devise) |
| remember_created_at | datetime | | (Devise) |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes**: `email` (unique), `reset_password_token` (unique)

---

### Team

Groupe de joueurs créé par un organisateur.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| organizer_id | bigint | FK (users), NOT NULL | Créateur de l'équipe |
| name | string | NOT NULL | Nom de l'équipe |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes**: `organizer_id`

**Validations**:
- `name`: présent, longueur 2-100

---

### Membership

Association entre un utilisateur et une équipe.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| user_id | bigint | FK (users), NOT NULL | Membre |
| team_id | bigint | FK (teams), NOT NULL | Équipe |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes**: `[user_id, team_id]` (unique)

**Validations**:
- Un utilisateur ne peut appartenir qu'une fois à une équipe

---

### Game

Session de jeu avec ses phases.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| team_id | bigint | FK (teams), NOT NULL | Équipe jouant |
| status | integer | NOT NULL, DEFAULT 0 | Phase: 0=collecting, 1=guessing, 2=finished |
| created_at | datetime | NOT NULL | |
| started_at | datetime | | Début phase devinettes |
| finished_at | datetime | | Fin de partie |
| updated_at | datetime | NOT NULL | |

**Indexes**: `team_id`, `status`

**Enum values**:
- `0` = collecting (collecte des propositions)
- `1` = guessing (phase de devinettes)
- `2` = finished (terminée)

**State transitions**:
- `collecting` → `guessing` : via `start_guessing!` (organisateur only)
- `guessing` → `finished` : via `finish!` (organisateur only)

---

### Proposal

Proposition musicale soumise par un joueur pour une partie.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| game_id | bigint | FK (games), NOT NULL | Partie concernée |
| player_id | bigint | FK (users), NOT NULL | Joueur proposant |
| url | string | NOT NULL | Lien musical (YouTube, etc.) |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes**: `game_id`, `player_id`, `[game_id, url]` (unique), `[game_id, player_id]` (unique)

**Validations**:
- `url`: présent, format URL valide (http/https)
- `url`: unique dans le scope du `game_id`
- `player_id`: unique dans le scope du `game_id` (un joueur = une proposition)
- URL normalisée avant validation (lowercase, sans trailing slash, sans fragment)

---

### Guess

Association d'un joueur entre une proposition et un auteur supposé.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | bigint | PK, auto | Identifiant unique |
| player_id | bigint | FK (users), NOT NULL | Joueur devinant |
| proposal_id | bigint | FK (proposals), NOT NULL | Proposition devinée |
| guessed_author_id | bigint | FK (users), NOT NULL | Auteur supposé |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes**: `player_id`, `proposal_id`, `guessed_author_id`, `[player_id, proposal_id]` (unique)

**Validations**:
- Un joueur ne peut deviner qu'une fois par proposition
- `guessed_author_id` doit être un membre de l'équipe ayant soumis une proposition

---

## Computed Data (non-persisted)

### Score

Calculé à la fin de partie. Non stocké en base.

```ruby
# Game#calculate_scores
def calculate_scores
  players.map do |player|
    correct_count = player.guesses.where(game: self).count do |guess|
      guess.proposal.player_id == guess.guessed_author_id
    end
    { player: player, score: correct_count }
  end.sort_by { |r| -r[:score] }
end
```

### Ranking

Classement avec gestion ex aequo (même rang si même score).

```ruby
# Game#ranking
def ranking
  scores = calculate_scores
  rank = 0
  previous_score = nil
  
  scores.each_with_index do |entry, index|
    if entry[:score] != previous_score
      rank = index + 1
      previous_score = entry[:score]
    end
    entry[:rank] = rank
  end
  
  scores
end
```

---

## Migrations Summary

| Order | Migration | Description |
|-------|-----------|-------------|
| 1 | `create_users` | Table users (via Devise) |
| 2 | `add_name_to_users` | Ajoute `name` à users |
| 3 | `create_teams` | Table teams avec `organizer_id` |
| 4 | `create_memberships` | Table memberships (join) |
| 5 | `create_games` | Table games avec `status` enum |
| 6 | `create_proposals` | Table proposals avec `url` |
| 7 | `create_guesses` | Table guesses avec refs |

---

## Business Rules Enforced

| Rule | Enforcement |
|------|-------------|
| FR-001: Organisateur crée équipe | `Team.organizer_id` required |
| FR-002: Organisateur = joueur | Membership auto-créée pour organizer |
| FR-004: Une proposition/joueur/partie | Unique index `[game_id, player_id]` |
| FR-005: Propositions invisibles | Controller logic (pas d'exposition API) |
| FR-007: Deviner chaque proposition | Validation complétude dans controller |
| FR-008: Soumission complète | Transaction avec validation count |
| FR-009: Devinettes verrouillées | Pas de route update/delete |
| Liens dupliqués interdits | Unique index `[game_id, url]` + normalisation |
