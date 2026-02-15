# Data Model: Tableau de statut des joueurs en phase de devinettes

**Feature**: 006-player-guess-status  
**Date**: 2026-02-14

## Overview

Cette fonctionnalité ne nécessite **aucune modification du schéma de base de données**. Elle utilise les entités existantes pour calculer et afficher le statut des devinettes des joueurs.

## Entities Used (Read-Only)

### Game

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| id | integer | Identifiant unique |
| status | enum | Phase actuelle (collecting, guessing, finished) |
| team_id | integer | Référence à l'équipe |

### Proposal

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| id | integer | Identifiant unique |
| game_id | integer | Référence à la partie |
| player_id | integer | Référence au joueur ayant soumis |
| url | string | Lien musical |

**Relation**: `belongs_to :game`, `belongs_to :player`

### Guess

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| id | integer | Identifiant unique |
| proposal_id | integer | Référence à la proposition devinée |
| player_id | integer | Référence au joueur qui devine |
| guessed_author_id | integer | Référence au joueur supposé auteur |

**Relation**: `belongs_to :proposal`, `belongs_to :player`

**Index utilisé**: `index_guesses_on_player_id` pour la requête GROUP BY

## Derived Data (Computed at Runtime)

### players_in_pool

Liste des joueurs participant à la phase de devinettes (ceux ayant soumis une proposition).

```ruby
# Dérivé de proposals
players_in_pool = proposals.map(&:player)
```

### players_with_guesses

Liste des joueurs ayant soumis toutes leurs devinettes pour la partie.

```ruby
# Calculé via une seule requête GROUP BY
guess_counts = Guess.joins(:proposal)
                    .where(proposals: { game_id: game.id })
                    .group(:player_id)
                    .count

expected_count = proposals.count - 1

players_with_guesses = players_in_pool.select do |player|
  (guess_counts[player.id] || 0) == expected_count
end
```

### Player Guess Status

| Condition | Status Display |
| --------- | ------------- |
| `players_with_guesses.include?(player)` | "Devinette soumise" (✅) |
| `!players_with_guesses.include?(player)` | "En attente" (⏳) |

## Relationships Diagram

```text
┌─────────┐       ┌──────────┐       ┌─────────┐
│  Game   │──1:N──│ Proposal │──N:1──│  User   │
│         │       │          │       │(player) │
└─────────┘       └──────────┘       └─────────┘
     │                  │                  │
     │                  │                  │
     └──────────────────┼──────────────────┘
                        │
                   ┌────┴────┐
                   │  Guess  │
                   │         │
                   └─────────┘
```

## Schema Changes

**None required.** Cette fonctionnalité est purement une modification de la couche présentation.
