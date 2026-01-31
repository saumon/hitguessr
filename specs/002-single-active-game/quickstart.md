# Quickstart: Limite d'une partie active par organisateur

**Feature**: 002-single-active-game  
**Date**: 2026-01-31

## Prérequis

- Ruby 3.4.x
- Rails 8.1.2
- SQLite (développement)
- Environnement de développement HitGuessr configuré

## Étapes d'implémentation

### 1. Ajouter le scope et la validation au modèle Game

**Fichier**: `app/models/game.rb`

```ruby
class Game < ApplicationRecord
  # ... existing code ...
  
  # Scope for active games
  scope :active, -> { where(status: [:collecting, :guessing]) }
  
  # Validations
  validates :status, presence: true
  validate :only_one_active_game_per_team, on: :create
  
  private
  
  def only_one_active_game_per_team
    if team&.has_active_game?
      errors.add(:base, "Une partie est déjà en cours pour cette équipe. Terminez-la avant d'en lancer une nouvelle.")
    end
  end
end
```

### 2. Ajouter les helper methods au modèle Team

**Fichier**: `app/models/team.rb`

```ruby
class Team < ApplicationRecord
  # ... existing code ...
  
  def active_game
    games.active.first
  end
  
  def has_active_game?
    games.active.exists?
  end
end
```

### 3. Mettre à jour la vue Teams#show

**Fichier**: `app/views/teams/show.html.erb`

Remplacer le lien "Lancer une partie" par une version conditionnelle :

```erb
<% if @team.organizer == current_user %>
  <% if @team.has_active_game? %>
    <span class="group relative inline-block">
      <span class="btn-neon btn-primary px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 opacity-50 cursor-not-allowed">
        🎮 Lancer une partie
      </span>
      <span class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-3 py-1 bg-gray-900 text-gray-200 text-xs rounded whitespace-nowrap invisible group-hover:visible border border-neon-purple/30">
        Une partie est déjà en cours
      </span>
    </span>
  <% else %>
    <%= link_to new_team_game_path(@team), class: "btn-neon btn-primary px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2" do %>
      🎮 Lancer une partie
    <% end %>
  <% end %>
<% end %>
```

### 4. (Optionnel) Ajouter un indicateur de partie en cours

Dans la même vue, avant la liste des parties :

```erb
<% if @team.has_active_game? %>
  <div class="mb-4 p-3 bg-neon-cyan/10 border border-neon-cyan/30 rounded-lg">
    <span class="neon-text-cyan">▶</span>
    <span class="text-gray-200">Partie en cours:</span>
    <%= link_to "Partie ##{@team.active_game.id}", game_path(@team.active_game), class: "neon-text-pink hover:underline ml-1" %>
    <span class="text-xs text-gray-400 ml-2">(<%= @team.active_game.status.humanize %>)</span>
  </div>
<% end %>
```

## Tests

### Lancer les tests unitaires

```bash
bin/rails test test/models/game_test.rb
bin/rails test test/models/team_test.rb
```

### Lancer les tests système

```bash
bin/rails test test/system/single_active_game_test.rb
```

### Vérification manuelle

1. Créer une équipe et lancer une partie
2. Vérifier que le bouton "Lancer une partie" est désactivé sur la page équipe
3. Terminer la partie
4. Vérifier que le bouton est à nouveau actif
5. Lancer une nouvelle partie avec succès

## Rollback

Si nécessaire, retirer les modifications dans l'ordre inverse :

1. Vue `teams/show.html.erb`
2. Méthodes `Team#active_game` et `Team#has_active_game?`
3. Scope `Game.active` et validation `only_one_active_game_per_team`

Aucune migration de base de données à annuler.
