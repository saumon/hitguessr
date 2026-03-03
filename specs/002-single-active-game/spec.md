# Feature Specification: Limite d'une partie active par organisateur

**Feature Branch**: `002-single-active-game`  
**Created**: 2026-01-31  
**Status**: Shipped  
**Input**: User description: "L'organisateur ne peut lancer qu'une partie à la fois"

## Clarifications

### Session 2026-01-31

- Q: Comportement du bouton "Lancer une nouvelle partie" quand une partie est active ? → A: Bouton désactivé (grisé) avec tooltip explicatif au survol.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Empêcher le lancement d'une nouvelle partie si une partie est déjà active (Priority: P1)

En tant qu'organisateur d'une équipe, je ne peux pas lancer une nouvelle partie tant qu'une partie est déjà en cours (en phase de collecte ou de devinettes), afin de concentrer l'attention des joueurs sur une seule partie à la fois.

**Why this priority**: C'est la fonctionnalité principale demandée — sans cette règle métier, la contrainte d'unicité n'existe pas.

**Independent Test**: Testable en lançant une première partie, puis en tentant d'en lancer une seconde et en vérifiant que l'action est bloquée avec un message explicatif.

**Acceptance Scenarios**:

1. **Given** une équipe avec une partie en phase de collecte, **When** l'organisateur tente de lancer une nouvelle partie, **Then** le système refuse et affiche un message indiquant qu'une partie est déjà en cours.
2. **Given** une équipe avec une partie en phase de devinettes, **When** l'organisateur tente de lancer une nouvelle partie, **Then** le système refuse et affiche un message indiquant qu'une partie est déjà en cours.
3. **Given** une équipe sans partie active (aucune partie ou uniquement des parties terminées), **When** l'organisateur lance une nouvelle partie, **Then** la partie est créée avec succès.

---

### User Story 2 - Visibilité de l'état de la partie en cours (Priority: P2)

En tant qu'organisateur, je vois clairement si une partie est en cours pour mon équipe avant de tenter d'en lancer une nouvelle.

**Why this priority**: Améliore l'expérience utilisateur en évitant la frustration d'une tentative bloquée par le système.

**Independent Test**: Testable en affichant la page de l'équipe avec une partie active et en vérifiant qu'un indicateur visuel de partie en cours est présent.

**Acceptance Scenarios**:

1. **Given** une équipe avec une partie en cours, **When** l'organisateur consulte la page de l'équipe, **Then** il voit un indicateur clair de la partie active avec son statut (collecte ou devinettes).
2. **Given** une équipe avec une partie en cours, **When** l'organisateur consulte la page de l'équipe, **Then** le bouton "Lancer une nouvelle partie" est désactivé (grisé) avec un tooltip explicatif au survol indiquant qu'une partie est déjà en cours.

---

### User Story 3 - Lancer une nouvelle partie après fin de la partie précédente (Priority: P3)

En tant qu'organisateur, je peux lancer une nouvelle partie dès que la partie précédente est terminée.

**Why this priority**: Assure la continuité du jeu et la possibilité de rejouer après une partie.

**Independent Test**: Testable en terminant une partie puis en lançant immédiatement une nouvelle partie avec succès.

**Acceptance Scenarios**:

1. **Given** une équipe dont la dernière partie vient de se terminer, **When** l'organisateur tente de lancer une nouvelle partie, **Then** la nouvelle partie est créée avec succès.
2. **Given** une équipe dont la dernière partie vient de se terminer, **When** l'organisateur consulte la page de l'équipe, **Then** le bouton "Lancer une nouvelle partie" est actif et utilisable.

---

### Edge Cases

- Si l'organisateur a plusieurs équipes, la contrainte s'applique indépendamment à chaque équipe (une partie active par équipe, pas une partie active globale par organisateur).
- Si une partie reste bloquée en phase de collecte ou de devinettes sans activité, l'organisateur doit pouvoir la terminer manuellement pour débloquer le lancement d'une nouvelle partie.
- Si la partie active est supprimée (par exemple, via une action d'administration), une nouvelle partie peut être lancée immédiatement.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT empêcher la création d'une nouvelle partie pour une équipe si une partie est déjà en phase de collecte ou de devinettes.
- **FR-002**: Le système DOIT autoriser la création d'une nouvelle partie uniquement si aucune partie n'est active (toutes les parties de l'équipe sont terminées ou aucune partie n'existe).
- **FR-003**: Le système DOIT afficher un message d'erreur explicatif lorsqu'un organisateur tente de lancer une partie alors qu'une partie est déjà active.
- **FR-004**: L'interface DOIT indiquer visuellement la présence d'une partie en cours sur la page de l'équipe.
- **FR-005**: L'interface DOIT désactiver visuellement (griser) le bouton de lancement d'une nouvelle partie lorsqu'une partie est active, avec un tooltip explicatif au survol.
- **FR-006**: La contrainte d'unicité DOIT s'appliquer par équipe (et non globalement par organisateur).

### Key Entities

- **Partie (Game)**: Utilise l'attribut `status` existant (`collecting`, `guessing`, `finished`) pour déterminer si une partie est active.
- **Équipe (Team)**: Entité parente qui peut avoir au maximum une partie active à tout moment.

### Assumptions

- Une partie est considérée comme "active" si son statut est `collecting` ou `guessing`.
- Une partie est considérée comme "terminée" si son statut est `finished`.
- L'organisateur peut toujours terminer manuellement une partie active (fonctionnalité existante FR-003 de spec 001).
- La contrainte s'applique au niveau de l'équipe : un organisateur avec plusieurs équipes peut avoir une partie active dans chaque équipe.

### Dependencies

- Modèle `Game` existant avec l'enum `status` (collecting, guessing, finished).
- Modèle `Team` existant avec l'association `has_many :games`.
- Fonctionnalité existante de lancement et terminaison de partie par l'organisateur.

### Scope

**In Scope**:

- Validation métier empêchant la création d'une partie si une partie active existe.
- Feedback utilisateur (message d'erreur, indicateur visuel, bouton désactivé).
- Règle par équipe.

**Out of Scope**:

- Annulation automatique de parties inactives après un certain délai.
- Limitation du nombre total de parties par équipe (historique illimité).
- Limitation globale par organisateur (multi-équipes).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des tentatives de création de partie avec une partie active sont bloquées avec un message d'erreur clair.
- **SC-002**: Le message d'erreur est compréhensible et indique la raison du blocage (vérifiable via test utilisateur).
- **SC-003**: L'indicateur de partie en cours est visible en moins de 1 seconde après le chargement de la page équipe.
- **SC-004**: Le bouton de lancement de partie reflète correctement l'état (actif/inactif) après rechargement de la page suite à la fin d'une partie.
- **SC-005**: Zéro état incohérent où une équipe a plus d'une partie active simultanément (vérifiable via contrainte de données).
