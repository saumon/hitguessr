# Research: Progression Automatique des Phases de Jeu

**Feature Branch**: `007-auto-phase-progression`
**Date**: 2026-02-14

## Questions de recherche

### 1. Gestion de la concurrence avec verrouillage de ligne

**Décision**: Utiliser `with_lock` d'ActiveRecord pour verrouiller la ligne Game pendant la vérification et la transition.

**Rationale**:

- `with_lock` est la méthode standard Rails pour le pessimistic locking
- Exécute `SELECT ... FOR UPDATE` puis recharge l'objet
- Garantit qu'une seule transaction peut modifier l'état à la fois
- Simple à implémenter et bien documenté dans Rails

**Alternatives considérées**:

- Verrouillage optimiste avec `lock_version` : Rejeté car nécessite de gérer les retries côté application et peut causer des erreurs utilisateur visibles
- Mutex en mémoire : Rejeté car ne fonctionne pas en configuration multi-processus (production typique)
- Job asynchrone avec déduplication : Rejeté car ajoute de la latence et de la complexité inutile pour un cas simple

**Implémentation**:

```ruby
def try_auto_progress_to_guessing!
  with_lock do
    return unless collecting?
    return unless all_members_submitted?
    start_guessing!
  end
end
```

### 2. Pattern de callback after_create pour déclencher les transitions

**Décision**: Utiliser `after_create_commit` au lieu de `after_create` pour déclencher la vérification.

**Rationale**:

- `after_create_commit` s'exécute après que la transaction soit committée
- Évite les problèmes de visibilité des données si la transaction échoue
- Garantit que la nouvelle proposition/devinette est bien persistée avant de vérifier
- Le verrouillage dans `try_auto_progress!` fonctionne dans une nouvelle transaction

**Alternatives considérées**:

- `after_create` : Rejeté car s'exécute dans la même transaction, ce qui complique le locking
- `after_save` : Rejeté car se déclenche aussi sur update, pas nécessaire ici
- Observer pattern : Rejeté car complexité supplémentaire sans bénéfice

**Implémentation**:

```ruby
# Dans Proposal
after_create_commit :try_auto_progress_game

private

def try_auto_progress_game
  game.try_auto_progress_to_guessing!
end
```

### 3. Calcul du seuil de 100% des membres

**Décision**: Comparer `proposals.count` avec `team.members.count` pour la phase de collecte.

**Rationale**:

- Utilise les relations existantes (team.members via memberships)
- Prend en compte la composition actuelle de l'équipe au moment de l'évaluation
- Simple et direct, pas de dénormalisation nécessaire

**Implémentation**:

```ruby
def all_members_submitted?
  proposals.count >= team.members.count && proposals.count >= 2
end
```

### 4. Calcul du nombre total de devinettes attendues

**Décision**: Formule `N × (N-1)` où N = nombre de propositions (= nombre de joueurs participants).

**Rationale**:

- Chaque joueur doit deviner toutes les propositions sauf la sienne
- N joueurs × (N-1) propositions à deviner = total de devinettes
- Exemple : 3 joueurs → 3 × 2 = 6 devinettes au total

**Implémentation**:

```ruby
def expected_guesses_count
  n = proposals.count
  n * (n - 1)
end

def all_guesses_submitted?
  guesses.count >= expected_guesses_count
end
```

### 5. Interaction avec les transitions manuelles existantes

**Décision**: Les méthodes existantes `start_guessing!` et `finish!` restent inchangées. Les nouvelles méthodes `try_auto_*` les appellent avec vérification préalable.

**Rationale**:

- Préserve le comportement existant (organisateur peut forcer les transitions)
- Évite la duplication de logique
- Les méthodes `try_auto_*` échouent silencieusement si conditions non remplies

**Implémentation**:

```ruby
# Méthode existante (inchangée)
def start_guessing!
  raise InvalidTransitionError unless collecting?
  raise InvalidTransitionError if proposals.count < 2
  update!(status: :guessing, started_at: Time.current)
end

# Nouvelle méthode (appelle l'existante)
def try_auto_progress_to_guessing!
  with_lock do
    return unless can_auto_progress_to_guessing?
    start_guessing!
  end
end
```

## Décisions techniques consolidées

| Aspect | Décision |
| ------ | -------- |
| Locking | `with_lock` (pessimistic, row-level) |
| Callback trigger | `after_create_commit` |
| Seuil collecte | `proposals.count >= team.members.count && >= 2` |
| Seuil devinettes | `guesses.count >= N × (N-1)` |
| Transitions existantes | Préservées, appelées par les nouvelles méthodes |
