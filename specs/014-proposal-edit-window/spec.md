# Feature Specification: Modification de proposition avant guessing

**Feature Branch**: `[014-proposal-edit-window]`  
**Created**: 2026-03-02  
**Status**: Shipped  
**Input**: User description: "En tant que joueur, je veux pouvoir modifier ma proposition tant que la partie est en phase de collecte des propositions. En phase guessing, il n'est plus possible de changer sa proposition."

## Clarifications

### Session 2026-03-02

- Q: En phase collecte, si le joueur n'a pas encore de proposition, le même flux "modifier" doit-il créer la proposition ? → A: Oui, le flux crée la proposition.
- Q: Les modifications de proposition doivent-elles être historisées ? → A: Non, seule la valeur courante est conservée.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Modifier sa proposition en collecte (Priority: P1)

En tant que joueur, je veux pouvoir modifier ma propre proposition tant que la partie est en phase de collecte des propositions, afin de corriger ou améliorer mon choix avant le verrouillage.

**Why this priority**: C'est la valeur principale demandée et le besoin fonctionnel central du ticket.

**Independent Test**: Peut être testé entièrement en phase de collecte en modifiant une proposition existante puis en vérifiant que la nouvelle valeur est bien prise en compte.

**Acceptance Scenarios**:

1. **Given** une partie en phase de collecte et une proposition déjà saisie par le joueur, **When** le joueur modifie cette proposition, **Then** la modification est acceptée et la proposition enregistrée reflète la nouvelle valeur.
2. **Given** une partie en phase de collecte, **When** le joueur modifie sa proposition plusieurs fois avant la fin de phase, **Then** chaque modification est autorisée et la dernière valeur saisie est celle retenue.

---

### User Story 2 - Verrouiller la proposition en guessing (Priority: P2)

En tant que joueur, je ne veux plus pouvoir modifier ma proposition quand la partie est en phase de guessing, afin de garantir l'équité une fois la collecte terminée.

**Why this priority**: Le verrouillage en phase guessing est une contrainte métier explicite de la demande.

**Independent Test**: Peut être testé en passant une partie en phase guessing puis en tentant de modifier une proposition existante.

**Acceptance Scenarios**:

1. **Given** une partie en phase guessing et une proposition déjà présente, **When** le joueur tente de modifier sa proposition, **Then** la modification est refusée et la valeur initiale reste inchangée.
2. **Given** une partie en phase guessing, **When** le joueur ouvre l'interface de proposition, **Then** il ne dispose d'aucune action lui permettant de soumettre une modification.

---

### User Story 3 - Respecter la transition de phase (Priority: P3)

En tant que joueur, je veux que le droit de modification suive immédiatement le changement de phase, afin d'éviter les incohérences autour du moment de bascule.

**Why this priority**: Ce cas évite les comportements ambigus au moment critique de passage collecte → guessing.

**Independent Test**: Peut être testé en tentant une modification juste avant et juste après la transition de phase.

**Acceptance Scenarios**:

1. **Given** une partie qui passe de la phase de collecte à guessing, **When** le joueur soumet une tentative de modification après la bascule effective, **Then** la modification est refusée.

---

### Edge Cases

- La phase passe à guessing pendant qu'un joueur est en train d'éditer: toute tentative validée après la bascule doit être refusée.
- Le joueur tente de soumettre exactement la même valeur que sa proposition actuelle en phase de collecte: la demande est acceptée sans altérer l'état métier.
- Le joueur non membre de la partie tente de modifier une proposition: les règles d'autorisation existantes continuent de s'appliquer sans élargissement de droits.
- Une proposition n'existe pas encore pour le joueur en phase guessing: la fonctionnalité ne doit pas permettre de créer ou modifier une proposition via ce flux.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT autoriser un joueur à modifier sa propre proposition uniquement quand la partie est en phase de collecte des propositions.
- **FR-002**: Le système DOIT enregistrer la dernière version de la proposition soumise par le joueur pendant la phase de collecte.
- **FR-003**: Le système DOIT refuser toute tentative de modification de proposition dès que la partie est en phase guessing.
- **FR-004**: En cas de refus lié à la phase guessing, le système DOIT conserver la proposition précédemment enregistrée sans changement.
- **FR-005**: L'interface joueur DOIT refléter l'état de verrouillage en phase guessing en empêchant l'action de modification.
- **FR-006**: Les règles d'autorisation existantes (qui peut modifier quelle proposition) DOIVENT rester inchangées.
- **FR-007**: Le système DOIT évaluer la phase active au moment effectif de la soumission (et non à l’ouverture du formulaire), afin de gérer correctement toute transition de phase survenue entre-temps.
- **FR-008**: En phase de collecte, si le joueur ne possède pas encore de proposition, la soumission via ce même flux DOIT créer la proposition.
- **FR-009**: Le système NE DOIT PAS conserver d'historique des valeurs intermédiaires de proposition via cette fonctionnalité; seule la valeur courante est persistée.

### Non-Functional Requirements

- **NFR-001 (Performance)**: En environnement de recette, 95% des soumissions valides de proposition (création ou modification) DOIVENT obtenir une réponse applicative en moins de 500 ms.
- **NFR-002 (UX)**: En phase guessing, l'état de verrouillage de la proposition DOIT être visible et compréhensible par un joueur en moins de 5 secondes.

### Key Entities *(include if feature involves data)*

- **Proposition joueur**: Proposition associée à un joueur pour une partie donnée; sa valeur peut être remplacée pendant la collecte.
- **Phase de partie**: État métier de la partie (collecte des propositions ou guessing) qui détermine l'autorisation de modification.
- **Tentative de modification**: Action d'un joueur visant à remplacer sa proposition existante, évaluée selon la phase active au moment de la soumission.

### Assumptions

- Les phases de partie existantes et leur définition métier restent identiques.
- Le verrouillage demandé concerne uniquement la phase guessing; aucun autre comportement de phase n'est modifié.
- Le message utilisateur exact en cas de refus n'est pas imposé par cette demande, tant que la modification est effectivement bloquée.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des modifications valides soumises pendant la phase de collecte sont acceptées.
- **SC-002**: 100% des modifications soumises pendant la phase guessing sont refusées.
- **SC-003**: Dans 95% des cas de test utilisateur, un joueur comprend en moins de 5 secondes si sa proposition est modifiable selon la phase affichée.
- **SC-004**: Le taux d'incohérence de proposition liée à des edits après passage en guessing est de 0% sur les scénarios de recette définis.
- **SC-005**: En recette, 95% des soumissions valides de proposition (création ou modification) sont traitées en moins de 500 ms.
