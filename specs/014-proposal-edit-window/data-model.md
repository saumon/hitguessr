# Data Model — Modification de proposition avant guessing

## Existing Domain Entities

### Proposal (proposition joueur)

- Source: `proposals` (ActiveRecord)
- Champs utiles:
  - `id: Integer`
  - `game_id: Integer`
  - `player_id: Integer`
  - `url: String`
  - `guess_order_position: Integer | nil`
- Invariants:
  - Unicité `(game_id, player_id)` (une proposition par joueur et par partie)
  - Unicité `(game_id, url)` (pas de doublon d’URL dans une partie)
  - `url` obligatoire et valide (`http/https`)

### Game (phase de partie)

- Source: `games`
- Champs utiles:
  - `id: Integer`
  - `status: enum { collecting, guessing, finished }`
- Rôle feature:
  - Autorise création/modification de proposition seulement en `collecting`
  - Verrouille en `guessing` et `finished`

### User (joueur)

- Source: `users`
- Champs utiles:
  - `id: Integer`
  - `name: String`
  - `email: String`
- Rôle feature:
  - Peut créer/modifier uniquement sa propre proposition

## Feature Action Entity

### ProposalSubmissionAttempt

- Description: tentative d’un joueur de soumettre une valeur de proposition via le flux unique.
- Champs logiques:
  - `game_id: Integer`
  - `player_id: Integer`
  - `submitted_url: String`
  - `submitted_at: DateTime`
  - `game_phase_at_submission: collecting | guessing | finished`
- Règles:
  - Si `game_phase_at_submission == collecting`: autorisé
    - proposition absente -> création
    - proposition existante -> mise à jour
  - Sinon: refusé, aucune mutation de `Proposal`

## Relationships

- `Game 1..* Proposal`
- `User 1..* Proposal`
- Contrainte métier: `Proposal` appartient à un seul `Game` et un seul `User`; un `User` ne peut avoir qu’une proposition par `Game`.

## State Transitions

1. **Collecting + No Proposal** → soumission valide → `Proposal` créée.
2. **Collecting + Existing Proposal** → soumission valide → `Proposal.url` remplacée (dernière valeur retenue).
3. **Guessing/Finished + Existing Proposal** → soumission refusée → valeur précédente conservée.
4. **Guessing/Finished + No Proposal** → soumission refusée → aucune création.
5. **Collecting -> Guessing pendant édition** → verdict à la soumission (si après bascule: refus).

## Validation & Error Semantics

- Validation applicative:
  - Phase non `collecting` => erreur métier explicite.
  - URL invalide ou dupliquée => erreurs `Proposal` standard.
- Persistance:
  - Aucune historisation des valeurs intermédiaires.
  - Seule la valeur courante est stockée.
