# Data Model: Quitter son équipe

**Feature**: 009-self-leave-team  
**Date**: 2026-02-21

## Summary

La feature réutilise le schéma existant et ne nécessite pas de migration. Le comportement repose sur des règles métier supplémentaires appliquées au moment de la suppression d'une `Membership` appartenant à `current_user`.

---

## Entities Involved

### Team

| Attribute    | Type    | Notes                              |
| ------------ | ------- | ---------------------------------- |
| id           | integer | PK                                 |
| name         | string  | Nom de l'équipe                    |
| organizer_id | integer | FK → users (autorité organisateur) |

**Associations**:

- `belongs_to :organizer, class_name: "User"`
- `has_many :memberships`
- `has_many :members, through: :memberships`
- `has_many :games`

**Business Rules (self-leave)**:

- Si `organizer_id == current_user.id` alors la sortie est refusée.
- Si `has_active_game?` est vrai (partie `collecting` ou `guessing`) alors la sortie est refusée.

### Membership

| Attribute | Type    | Notes      |
|-----------|---------|------------|
| id        | integer | PK         |
| user_id   | integer | FK → users |
| team_id   | integer | FK → teams |

**Associations**:

- `belongs_to :user`
- `belongs_to :team`

**Validation existante**:

- Unicité `(user_id, team_id)`.

**State transitions (conceptuelles)**:

```text
active (record exists)
  └── [DELETE leave action authorized] → removed (record deleted)
```

### Game

| Attribute  | Type    | Notes                                         |
|------------|---------|-----------------------------------------------|
| id         | integer | PK                                            |
| team_id    | integer | FK → teams                                    |
| status     | integer | enum: collecting(0), guessing(1), finished(2) |

**Role in feature**:

- Définit le blocage de sortie quand une partie active existe.

### User

| Attribute | Type    | Notes            |
|-----------|---------|------------------|
| id        | integer | PK               |
| email     | string  | Authentification |
| name      | string  | Affichage        |

**Role in feature**:

- `current_user` est le seul sujet autorisé de l'action `leave`.

---

## Invariants

1. Une action de sortie auto-service ne supprime jamais l'appartenance d'un autre utilisateur.
2. L'organisateur d'équipe (via `team.organizer_id`) ne peut pas quitter sa propre équipe.
3. Une équipe avec partie active (`collecting`/`guessing`) ne permet aucune sortie auto-service.
4. Une seconde demande de sortie après suppression est sans effet et retourne un message clair.
5. Les autres appartenances de l'utilisateur (autres équipes) restent inchangées.

---

## No Schema Changes Required

- Aucune table/colonne/index supplémentaire.
- Implémentation portée par logique contrôleur + vue + routes + tests + documentation.
