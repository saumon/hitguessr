# Data Model: Progression Automatique des Phases de Jeu

**Feature Branch**: `007-auto-phase-progression`
**Date**: 2026-02-14

## Entités existantes (pas de modification de schéma)

Cette feature n'ajoute pas de nouvelles tables ni de nouvelles colonnes. Elle exploite les entités existantes avec une logique métier supplémentaire.

### Game

État actuel du schéma :

```ruby
create_table "games" do |t|
  t.integer "status", default: 0, null: false  # 0=collecting, 1=guessing, 2=finished
  t.integer "team_id", null: false
  t.datetime "started_at"
  t.datetime "finished_at"
  t.timestamps
end
```

**Nouvelles méthodes** (pas de changement de schéma) :

- `all_members_submitted?` : Vérifie si tous les membres ont soumis leur proposition
- `expected_guesses_count` : Calcule le nombre total de devinettes attendues
- `all_guesses_submitted?` : Vérifie si toutes les devinettes ont été soumises
- `try_auto_progress_to_guessing!` : Tente la transition automatique vers guessing
- `try_auto_finish!` : Tente la terminaison automatique

### Proposal

État actuel du schéma :

```ruby
create_table "proposals" do |t|
  t.integer "game_id", null: false
  t.integer "player_id", null: false
  t.string "url", null: false
  t.timestamps
end
```

**Nouveau callback** :

- `after_create_commit :try_auto_progress_game`

### Guess

État actuel du schéma :

```ruby
create_table "guesses" do |t|
  t.integer "player_id", null: false
  t.integer "proposal_id", null: false
  t.integer "guessed_author_id", null: false
  t.timestamps
end
```

**Nouveau callback** :

- `after_create_commit :try_auto_finish_game`

### Membership

Utilisé uniquement en lecture pour compter les membres de l'équipe :

```ruby
create_table "memberships" do |t|
  t.integer "user_id", null: false
  t.integer "team_id", null: false
  t.timestamps
end
```

## Relations clés pour cette feature

```text
Team
├── has_many :members (through :memberships)
└── has_many :games

Game
├── belongs_to :team
├── has_many :proposals
└── has_many :guesses (through :proposals)

Proposal
├── belongs_to :game
├── belongs_to :player
└── has_many :guesses

Guess
├── belongs_to :proposal
├── belongs_to :player
└── belongs_to :guessed_author
```

## Règles de validation pour les transitions automatiques

### Transition collecting → guessing

Conditions :

1. `game.collecting?` == true
2. `game.proposals.count >= game.team.members.count` (100% participation)
3. `game.proposals.count >= 2` (minimum existant)

### Transition guessing → finished

Conditions :

1. `game.guessing?` == true
2. `game.guesses.count >= expected_guesses_count`

Où `expected_guesses_count = N × (N-1)` avec N = nombre de propositions
