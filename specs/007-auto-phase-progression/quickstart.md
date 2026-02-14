# Quickstart: Progression Automatique des Phases de Jeu

**Feature Branch**: `007-auto-phase-progression`
**Date**: 2026-02-14

## Vue d'ensemble

Cette feature ajoute la progression automatique des phases de jeu sans intervention de l'organisateur lorsque tous les joueurs ont participé.

## Fichiers à modifier

| Fichier | Action | Description |
| ------- | ------ | ----------- |
| `app/models/game.rb` | Modifier | Ajouter méthodes de détection et transition automatique |
| `app/models/proposal.rb` | Modifier | Ajouter callback `after_create_commit` |
| `app/models/guess.rb` | Modifier | Ajouter callback `after_create_commit` |
| `test/models/game_test.rb` | Modifier | Ajouter tests pour nouvelles méthodes |
| `test/system/auto_phase_progression_test.rb` | Créer | Tests E2E du comportement automatique |

## Étapes d'implémentation

### 1. Ajouter les méthodes de détection dans Game

```ruby
# app/models/game.rb

def all_members_submitted?
  proposals.count >= team.members.count && proposals.count >= 2
end

def expected_guesses_count
  n = proposals.count
  n * (n - 1)
end

def all_guesses_submitted?
  guesses.count >= expected_guesses_count
end

def try_auto_progress_to_guessing!
  with_lock do
    return unless collecting?
    return unless all_members_submitted?
    start_guessing!
  end
end

def try_auto_finish!
  with_lock do
    return unless guessing?
    return unless all_guesses_submitted?
    finish!
  end
end
```

### 2. Ajouter le callback dans Proposal

```ruby
# app/models/proposal.rb

after_create_commit :try_auto_progress_game

private

def try_auto_progress_game
  game.try_auto_progress_to_guessing!
end
```

### 3. Ajouter le callback dans Guess

```ruby
# app/models/guess.rb

after_create_commit :try_auto_finish_game

private

def try_auto_finish_game
  proposal.game.try_auto_finish!
end
```

### 4. Ajouter les tests unitaires

```ruby
# test/models/game_test.rb

test "all_members_submitted? returns true when all team members have proposals" do
  # Setup: team with 3 members, game with 3 proposals
  # Assert: all_members_submitted? == true
end

test "try_auto_progress_to_guessing! transitions when all members submitted" do
  # Setup: game in collecting, all members have proposals
  # Act: try_auto_progress_to_guessing!
  # Assert: game.guessing? == true
end

test "try_auto_finish! transitions when all guesses submitted" do
  # Setup: game in guessing, all expected guesses present
  # Act: try_auto_finish!
  # Assert: game.finished? == true
end
```

### 5. Ajouter les tests système

```ruby
# test/system/auto_phase_progression_test.rb

test "game automatically progresses to guessing when last proposal submitted" do
  # Login as last player
  # Submit proposal
  # Assert: redirected to guessing phase
end

test "game automatically finishes when last guess submitted" do
  # Setup: game in guessing
  # Submit last guess
  # Assert: results are displayed
end
```

## Vérification

```bash
# Exécuter les tests
bin/rails test test/models/game_test.rb
bin/rails test test/system/auto_phase_progression_test.rb

# Vérifier le linting
bin/rubocop app/models/game.rb app/models/proposal.rb app/models/guess.rb
```

## Points d'attention

1. **Concurrence**: Le `with_lock` est essentiel pour éviter les race conditions
2. **Callbacks**: Utiliser `after_create_commit` et non `after_create` pour s'assurer que la donnée est persistée
3. **Transitions existantes**: Les méthodes `start_guessing!` et `finish!` restent disponibles pour l'organisateur
