# Data Model — Alerte de doublon de proposition

## Existing Domain Entities (inchangées)

### Guess

- Source: `guesses` (ActiveRecord)
- Champs utiles: `player_id`, `proposal_id`, `guessed_author_id`
- Rôle feature: supporte la soumission finale; pas de nouveau champ.

### Proposal

- Source: `proposals`
- Champs utiles: `id`, `url`, `player_id`, `guess_order_position`
- Rôle feature: chaque ligne de devinette correspond à une proposition.

### User (joueur proposé)

- Source: `users`
- Champs utiles: `id`, `name`
- Rôle feature: valeur choisie par radio pour une proposition.

## UI/View-Model Entities (client-side)

### GuessSelection

- Description: sélection courante d’un joueur (auteur deviné) pour une proposition.
- Champs:
  - `proposal_id: Integer`
  - `guessed_author_id: Integer | nil`
  - `guessed_author_name: String`
- Validation:
  - `guessed_author_id` présent pour soumission complète (règle existante côté serveur).

### DuplicateGroup

- Description: groupe de propositions partageant le même auteur deviné.
- Champs:
  - `guessed_author_id: Integer`
  - `guessed_author_name: String`
  - `proposal_ids: Integer[]`
  - `count: Integer`
- Règle:
  - Un groupe est un doublon si `count >= 2`.

### DuplicateWarningState

- Description: état consolidé utilisé par l’UI.
- Champs:
  - `has_duplicates: Boolean`
  - `groups: DuplicateGroup[]`
  - `affected_proposal_ids: Set<Integer>`

## Relationships

- `GuessSelection` appartient à une `Proposal` (1:1 dans le formulaire).
- Plusieurs `GuessSelection` peuvent référencer le même `User`.
- `DuplicateGroup` agrège plusieurs `GuessSelection` par `guessed_author_id`.

## State Transitions

1. **Initial**: aucune sélection ou sélections uniques → `has_duplicates = false`.
2. **Select duplicate**: une sélection crée `count >= 2` pour un auteur → indicateurs inline actifs + `has_duplicates = true`.
3. **Resolve duplicate**: modification/vidage d’une ligne fait retomber `count < 2` → indicateurs mis à jour immédiatement.
4. **Submit with duplicates**: interception submit → ouverture modal détaillée.
5. **Confirm submit**: action `Confirmer` dans modal → POST standard.
6. **Cancel submit**: action `Annuler` → retour au formulaire sans POST.
