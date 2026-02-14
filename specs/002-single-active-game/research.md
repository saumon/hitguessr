# Research: Limite d'une partie active par organisateur

**Feature**: 002-single-active-game  
**Date**: 2026-01-31

## Research Questions

### 1. Rails custom validation best practices

**Task**: Trouver les meilleures pratiques pour les validations custom Rails qui dépendent d'autres enregistrements.

**Decision**: Utiliser une validation custom avec `validate :method_name` dans le modèle Game.

**Rationale**:

- La validation custom est le pattern Rails idiomatique pour les règles métier complexes
- Permet d'ajouter des erreurs au modèle avec `errors.add(:base, message)`
- La validation s'exécute automatiquement lors de `save`, `create`, `update`
- Le message d'erreur est accessible via `@game.errors.full_messages`

**Alternatives considered**:

- Callback `before_create` : Moins idiomatique, ne permet pas un retour propre d'erreurs
- Service object : Over-engineering pour une règle simple
- Database constraint : SQLite ne supporte pas les CHECK constraints complexes avec sous-requêtes

### 2. Race condition prevention for uniqueness

**Task**: Évaluer le risque de race condition lors de la création simultanée de parties.

**Decision**: Utiliser un verrou pessimiste avec `with_lock` ou une transaction avec `SERIALIZABLE` isolation level.

**Rationale**:

- La validation Rails seule n'est pas atomique (TOCTOU vulnerability)
- `with_lock` sur l'enregistrement Team empêche les créations concurrentes
- Alternative: `ActiveRecord::Base.transaction(isolation: :serializable)` pour SQLite

**Alternatives considered**:

- Validation seule : Risque de race condition (deux requêtes passent la validation avant le commit)
- Contrainte DB unique : Impossible car la contrainte dépend d'une condition dynamique (status != finished)
- Advisory lock : Non supporté par SQLite

**Implementation Note**: Pour SQLite en dev, le risque est minimal car les écritures sont sérialisées. En production avec PostgreSQL, utiliser `with_lock`.

### 3. Disabled button with tooltip in Tailwind/Turbo

**Task**: Pattern UI pour un bouton désactivé avec tooltip explicatif.

**Decision**: Utiliser les classes Tailwind `disabled:opacity-50 disabled:cursor-not-allowed` avec un wrapper `<div>` pour le tooltip (car `:hover` ne fonctionne pas sur les éléments disabled).

**Rationale**:

- Les boutons disabled ne déclenchent pas les événements hover
- Solution: wrapper le bouton dans un `<span>` ou `<div>` avec `group` et utiliser `group-hover` pour le tooltip
- Tailwind CSS supporte `group-hover` pour les tooltips contextuels

**Alternatives considered**:

- JavaScript hover listener : Plus complexe, contre le pattern Hotwire
- Bouton cliquable avec modale d'erreur : Moins bon UX (confirmation dans spec: option A)
- CSS `:has()` selector : Support navigateur limité

### 4. Team.has_active_game? vs Game scope

**Task**: Déterminer où placer la logique de détection de partie active.

**Decision**: Ajouter les deux :

- `Team#active_game` : Retourne la partie active (ou nil)
- `Team#has_active_game?` : Retourne boolean
- `Game.active` : Scope pour filtrer les parties actives

**Rationale**:

- `Team#active_game` est utile pour l'affichage dans la vue (indicateur de partie en cours)
- `Team#has_active_game?` est utilisé pour la logique conditionnelle (désactivation du bouton)
- `Game.active` scope est réutilisable et testable indépendamment

**Alternatives considered**:

- Seulement `Team#has_active_game?` : Insuffisant, on a besoin de la partie elle-même pour l'affichage
- Seulement scope sur Game : Moins lisible dans les vues (`@team.games.active.exists?`)

## Summary

| Question | Decision |
| -------- | -------- |
| Validation | Custom validation `validate :only_one_active_game_per_team` |
| Race condition | Transaction avec verrouillage sur Team pour PostgreSQL, acceptable pour SQLite |
| UI tooltip | Wrapper `<span>` avec `group-hover` Tailwind |
| Helper methods | `Team#active_game`, `Team#has_active_game?`, `Game.active` scope |

Toutes les questions techniques ont été résolues. Aucun NEEDS CLARIFICATION restant.

## Design Decisions Log

### Pourquoi pas de contrainte de base de données ?

**Contexte**: SC-005 mentionne "zéro état incohérent" et une "contrainte de données".

**Décision**: Utiliser uniquement la validation Rails, sans contrainte DB.

**Justification**:

- SQLite ne supporte pas les CHECK constraints avec sous-requêtes
- PostgreSQL supporterait un trigger, mais c'est over-engineering pour l'échelle prévue (~10-50 membres/équipe)
- La validation Rails avec `on: :create` est suffisante car:
  - SQLite sérialise les écritures (pas de race condition en dev)
  - En production, `with_lock` sur Team peut être ajouté si nécessaire
- L'intégrité est vérifiée par les tests automatisés (T004-T007)

**Trade-off accepté**: Risque théorique de race condition en production PostgreSQL sans lock, mais acceptable vu le contexte (action manuelle rare, équipes petites).
