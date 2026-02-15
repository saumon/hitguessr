# Quickstart: Tableau de statut des joueurs en phase de devinettes

**Feature**: 006-player-guess-status  
**Date**: 2026-02-14

## Prerequisites

- Ruby 3.x
- Rails 8.1.2
- Serveur de développement Rails fonctionnel

## Implementation Steps

### Step 1: Modifier le controller GamesController

**Fichier**: `app/controllers/games_controller.rb`

Dans la méthode `show`, ajouter le calcul de `@players_with_guesses`:

```ruby
def show
  @team = @game.team
  @proposals = @game.proposals.includes(:player)
  @my_proposal = @proposals.find_by(player: current_user)
  @players_with_proposals = @proposals.map(&:player)
  @members = @team.members
  
  # NEW: Calcul des joueurs ayant soumis toutes leurs devinettes
  if @game.guessing?
    expected_guesses = @proposals.count - 1
    guess_counts = Guess.joins(:proposal)
                        .where(proposals: { game_id: @game.id })
                        .group(:player_id)
                        .count
    @players_with_guesses = @players_with_proposals.select do |player|
      (guess_counts[player.id] || 0) == expected_guesses
    end
  end
end
```

### Step 2: Passer la variable au partial

**Fichier**: `app/views/games/show.html.erb`

Modifier le render du partial guessing:

```erb
<% when "guessing" %>
  <%= render "games/guessing", 
             game: @game, 
             team: @team, 
             proposals: @proposals, 
             my_proposal: @my_proposal,
             players_with_guesses: @players_with_guesses %>
```

### Step 3: Ajouter le tableau de statut au partial

**Fichier**: `app/views/games/_guessing.html.erb`

Ajouter le bloc suivant après la barre de progression (après le div `neon-border` contenant la progression):

```erb
<%# Player status %>
<div class="neon-border p-4 sm:p-6 mb-4 sm:mb-6">
  <h3 class="font-medium text-gray-300 mb-3 sm:mb-4 text-sm sm:text-base">Statut des joueurs:</h3>
  <div class="space-y-2">
    <% proposals.map(&:player).each do |player| %>
      <% has_guessed = players_with_guesses.include?(player) %>
      <div class="flex items-center gap-2 sm:gap-3 py-2 sm:py-3 border-b border-neon-purple/20 last:border-0">
        <span class="text-lg sm:text-xl <%= has_guessed ? 'neon-text-cyan' : 'text-gray-600' %> flex-shrink-0">
          <%= has_guessed ? '✅' : '⏳' %>
        </span>
        <span class="text-gray-200 text-sm sm:text-base truncate"><%= player.name %></span>
        <span class="text-xs sm:text-sm <%= has_guessed ? 'neon-text-cyan' : 'text-gray-500' %> hidden sm:inline">
          - <%= has_guessed ? 'Devinette soumise' : 'En attente' %>
        </span>
      </div>
    <% end %>
  </div>
</div>
```

## Testing

### Manual Testing

1. Créer une équipe avec au moins 3 membres
2. Lancer une partie
3. Faire soumettre une proposition par tous les joueurs
4. Passer en phase de devinettes (via l'organisateur)
5. Vérifier que le tableau de statut affiche tous les joueurs avec "En attente"
6. Soumettre les devinettes d'un joueur
7. Rafraîchir la page et vérifier que son statut passe à "Devinette soumise"

### System Tests

Ajouter dans `test/system/guesses_test.rb`:

```ruby
test "displays player guess status table during guessing phase" do
  # Setup game in guessing phase with proposals
  # ...
  
  visit game_path(game)
  
  assert_selector "h3", text: "Statut des joueurs:"
  within(".neon-border", text: "Statut des joueurs") do
    assert_selector "span", text: player1.name
    assert_selector "span", text: "En attente"
  end
end
```

## Verification Checklist

- [ ] Le tableau affiche tous les joueurs du pool (ceux ayant une proposition)
- [ ] Le statut "En attente" s'affiche avec ⏳ pour les joueurs n'ayant pas soumis
- [ ] Le statut "Devinette soumise" s'affiche avec ✅ pour les joueurs ayant soumis
- [ ] Le tableau est responsive (texte de statut masqué sur mobile)
- [ ] Le style est cohérent avec le tableau de la phase de collecte
