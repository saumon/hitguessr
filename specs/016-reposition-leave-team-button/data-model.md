# Data Model — Repositionnement du bouton quitter l’équipe

## Summary

Cette feature ne nécessite aucune migration. Elle modifie l’état de rendu de l’interface pour l’action de sortie d’équipe et réutilise les entités existantes.

## Entities

### Team

| Field | Type | Notes |
| - | - | - |
| id | integer | Identifiant équipe |
| organizer_id | integer | Référence organisateur |

Relation utile: `has_many :memberships`, `has_many :members`.

### Membership

| Field | Type | Notes |
| - | - | - |
| id | integer | Identifiant appartenance |
| team_id | integer | Référence équipe |
| user_id | integer | Référence utilisateur |

Rôle: détermine si l’utilisateur courant est membre actif et autorisé à quitter.

### LeaveTeamActionViewState (vue)

| Field | Type | Validation / Règle |
| - | - | - |
| visible | boolean | `true` uniquement pour membre actif autorisé |
| row_target | string | Valeur attendue: `current_member_row` |
| alignment_desktop | string | Valeur attendue: `right` |
| alignment_mobile | string | Valeur attendue: `right` |
| mobile_layout | string | Valeur attendue: `second_line_below_member_info` |
| label | string | Localisé selon locale active, fallback `Quitter l'équipe` |

## Relationships

- Un `Team` possède plusieurs `Membership`.
- Le bouton de sortie est rattaché visuellement à la ligne membre correspondant à `current_user`.

## Validation Rules

1. L’action n’est affichée que sur la ligne du membre connecté.
2. L’action n’apparaît plus à l’ancien emplacement (en-tête général d’actions équipe).
3. En mobile, l’action passe sous les informations membre sur une seconde ligne alignée à droite.
4. Le libellé suit I18n locale active avec fallback `Quitter l'équipe`.
5. Le déclenchement de l’action conserve le flux métier existant de `memberships#leave`.

## State Transitions

Transition fonctionnelle inchangée côté métier:

```text
membership active
  -> user triggers leave action (same endpoint)
  -> membership removed OR action refused by existing business rules
```
