# Research: Tableau de statut des joueurs en phase de devinettes

**Feature**: 006-player-guess-status  
**Date**: 2026-02-14

## Research Tasks

### 1. Analyse du composant existant (phase de collecte)

**Context**: Comprendre le fonctionnement du tableau de statut dans `_collecting.html.erb`

**Findings**:

Le tableau existant utilise les variables suivantes passées depuis le controller:

- `members`: tous les membres de l'équipe (`@team.members`)
- `players_with_proposals`: liste des utilisateurs ayant soumis une proposition

Structure visuelle:

- Container `neon-border` avec padding responsive
- Header "Statut des joueurs:"
- Liste avec icônes (✅/⏳), nom du joueur, texte de statut
- Classes TailwindCSS pour responsive (sm: breakpoints)
- Texte de statut masqué sur mobile (`hidden sm:inline`)

**Decision**: Réutiliser exactement la même structure HTML/CSS pour garantir la cohérence visuelle.

---

### 2. Détermination du statut de soumission des devinettes

**Context**: Définir comment savoir si un joueur a soumis toutes ses devinettes

**Findings**:

D'après le code existant dans `_guessing.html.erb`:

```ruby
my_guesses = current_user.guesses.joins(:proposal).where(proposals: { game_id: game.id })
has_submitted_guesses = my_guesses.count == (proposals.count - 1) && my_proposal.present?
```

Un joueur est considéré comme ayant soumis ses devinettes si:

1. Il a une proposition (`my_proposal.present?`)
2. Il a soumis `proposals.count - 1` devinettes (toutes les propositions sauf la sienne)

Pour le tableau de statut, il faut calculer cela pour chaque joueur du pool:

```ruby
# Joueurs dans le pool = joueurs ayant une proposition
players_in_pool = proposals.map(&:player)

# Pour chaque joueur, nombre de devinettes attendues = proposals.count - 1
expected_guesses_count = proposals.count - 1

# Joueurs ayant soumis toutes leurs devinettes
players_with_guesses = players_in_pool.select do |player|
  player.guesses.joins(:proposal).where(proposals: { game_id: game.id }).count == expected_guesses_count
end
```

**Decision**: Calculer `players_with_guesses` dans le controller et le passer au partial.

---

### 3. Variables à passer au partial _guessing

**Context**: Définir les variables nécessaires pour le tableau de statut

**Current state** (dans show.html.erb):

```erb
render "games/guessing", game: @game, team: @team, proposals: @proposals, my_proposal: @my_proposal
```

**Variables manquantes**:

- `players_in_pool`: liste des joueurs ayant une proposition (dérivable de `proposals`)
- `players_with_guesses`: liste des joueurs ayant soumis toutes leurs devinettes

**Decision**: Ajouter `players_with_guesses` au controller et au render. `players_in_pool` peut être calculé directement dans le partial via `proposals.map(&:player)`.

---

### 4. Optimisation des requêtes

**Context**: Éviter les requêtes N+1

**Findings**:

Pour calculer efficacement `players_with_guesses`:

```ruby
# Compter les devinettes par joueur pour cette partie
guess_counts = Guess.joins(:proposal)
                    .where(proposals: { game_id: @game.id })
                    .group(:player_id)
                    .count

expected_count = @proposals.count - 1

players_with_guesses = @proposals.map(&:player).select do |player|
  (guess_counts[player.id] || 0) == expected_count
end
```

Cette approche fait une seule requête GROUP BY au lieu d'une requête par joueur.

**Decision**: Utiliser cette approche optimisée dans le controller.

---

## Summary

| Decision | Rationale | Alternatives Rejected |
| -------- | --------- | -------------------- |
| Réutiliser structure HTML/CSS de _collecting | Cohérence visuelle garantie | Créer nouveau design (non cohérent) |
| Calculer players_with_guesses dans controller | Séparation des responsabilités, optimisation requêtes | Calcul dans la vue (N+1 queries) |
| Utiliser GROUP BY pour counts | Performance O(1) vs O(n) | Requêtes individuelles par joueur |
| Dériver players_in_pool de proposals | Évite variable supplémentaire | Variable explicite (redondant) |

## Open Items

*Aucun item en attente. Toutes les clarifications ont été résolues.*
