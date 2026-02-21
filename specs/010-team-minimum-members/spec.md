# Feature Specification: Seuil minimum de membres pour démarrer une partie

**Feature Branch**: `010-team-minimum-members`  
**Created**: 2026-02-21  
**Status**: Draft  
**Input**: User description: "Un organisateur peut lancer une partie seulement si l'équipe a au moins trois membres."

## Clarifications

### Session 2026-02-21

- Q: Quels membres sont comptabilisés pour atteindre le seuil de trois ? → A: Uniquement les membres actifs/confirmés de l'équipe.
- Q: Que signifie "membres actifs/confirmés" dans le schéma actuel ? → A: Cela correspond aux memberships existants entre utilisateur et équipe.
- Q: Quand la vérification du seuil doit-elle être effectuée par rapport à la création de partie ? → A: Côté serveur, dans la transaction de création de partie.
- Q: Les critères de succès doivent-ils être conditionnés par les autres règles de lancement existantes ? → A: Oui, SC-001/SC-002 ne s'appliquent que si les autres prérequis de lancement sont satisfaits.
- Q: Le seuil minimum de membres doit-il être configurable dans cette feature ? → A: Non, le seuil reste fixe à 3 dans cette feature.

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

### User Story 1 - Démarrer une partie avec équipe éligible (Priority: P1)

En tant qu'organisateur, je peux lancer une partie lorsque mon équipe compte au moins trois membres.

**Why this priority**: C'est le besoin métier principal, directement lié au démarrage normal du jeu.

**Independent Test**: Peut être testé indépendamment en configurant une équipe avec exactement trois membres puis en vérifiant que l'action de lancement réussit.

**Acceptance Scenarios**:

1. **Given** une équipe avec exactement trois membres et un utilisateur organisateur, **When** l'organisateur lance une partie, **Then** la partie est créée et démarre normalement.
2. **Given** une équipe avec plus de trois membres et un utilisateur organisateur, **When** l'organisateur lance une partie, **Then** la partie est créée et démarre normalement.

---

### User Story 2 - Bloquer un démarrage avec équipe insuffisante (Priority: P1)

En tant qu'organisateur, je suis empêché de lancer une partie si mon équipe compte moins de trois membres.

**Why this priority**: Cette contrainte protège la règle de jeu et évite des parties non valides.

**Independent Test**: Peut être testé indépendamment en configurant une équipe avec un ou deux membres puis en vérifiant que l'action de lancement est refusée.

**Acceptance Scenarios**:

1. **Given** une équipe avec deux membres et un utilisateur organisateur, **When** l'organisateur tente de lancer une partie, **Then** la demande est refusée et aucune nouvelle partie n'est créée.
2. **Given** une équipe avec un membre et un utilisateur organisateur, **When** l'organisateur tente de lancer une partie, **Then** la demande est refusée et aucune nouvelle partie n'est créée.

---

### User Story 3 - Recevoir un retour explicite (Priority: P2)

En tant qu'organisateur, je reçois un message clair m'indiquant si la partie a été lancée ou pourquoi elle est refusée.

**Why this priority**: Un retour explicite réduit la confusion et les tentatives répétées inutiles.

**Independent Test**: Peut être testé indépendamment en comparant le message affiché sur un cas autorisé (≥ 3 membres) et un cas refusé (< 3 membres).

**Acceptance Scenarios**:

1. **Given** un lancement refusé pour équipe de moins de trois membres, **When** l'action se termine, **Then** un message indique clairement qu'au moins trois membres sont requis.
2. **Given** un lancement accepté pour équipe de trois membres ou plus, **When** l'action se termine, **Then** un message de confirmation de démarrage est affiché.

---

### Edge Cases

- Une équipe avec exactement trois membres est considérée comme éligible.
- Si un membre quitte l'équipe juste avant ou pendant la tentative de lancement et que l'équipe passe sous trois membres, la vérification transactionnelle finale refuse le lancement.
- Une tentative répétée de lancement sur une équipe toujours sous le seuil reste refusée sans créer de partie partielle.
- Une tentative de lancement sur une équipe inaccessible ou inexistante est refusée avec un message générique sans exposer d'information sensible.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT autoriser le lancement d'une partie uniquement si l'équipe ciblée compte au moins trois membres au moment de la demande.
- **FR-002**: Le système DOIT refuser le lancement d'une partie si l'équipe ciblée compte moins de trois membres au moment de la demande.
- **FR-003**: Le système DOIT vérifier le nombre de membres effectifs de l'équipe à chaque tentative de lancement.
- **FR-009**: Le système DOIT comptabiliser uniquement les membres actifs/confirmés de l'équipe (définis ici comme des memberships existants) pour évaluer le seuil minimum de trois membres.
- **FR-004**: Le système NE DOIT PAS créer de nouvelle partie lorsque la tentative est refusée pour effectif insuffisant.
- **FR-005**: Le système DOIT afficher un message explicite indiquant que trois membres minimum sont requis quand la tentative est refusée.
- **FR-006**: Le système DOIT afficher un message de confirmation lorsque la partie est lancée avec succès.
- **FR-007**: Le système DOIT appliquer cette règle à toutes les équipes, sans exception manuelle côté utilisateur.
- **FR-008**: Le système DOIT conserver les autres règles de lancement déjà en place et appliquer le seuil de trois membres comme condition supplémentaire obligatoire.
- **FR-010**: Le système DOIT effectuer la vérification du seuil côté serveur dans la même transaction que la création de partie.
- **FR-011**: Le seuil minimum de membres DOIT être fixe à 3 pour cette fonctionnalité et NE DOIT PAS être configurable.

### Key Entities *(include if feature involves data)*

- **Équipe**: Groupe de joueurs possédant une liste de membres, utilisé pour déterminer l'éligibilité au lancement.
- **Membre d'équipe**: Utilisateur rattaché à une équipe ; dans ce schéma, seuls les memberships existants (membres actifs/confirmés) sont comptabilisés dans l'effectif au moment de la tentative.
- **Partie**: Session de jeu créée uniquement si les conditions de lancement, dont le seuil de membres, sont satisfaites.

### Assumptions

- Le terme « organisateur » désigne un utilisateur déjà autorisé à lancer une partie selon les règles actuelles.
- Le seuil « au moins trois membres » inclut l'organisateur s'il fait partie de l'équipe.
- Le besoin ne modifie pas les autres autorisations existantes de lancement (elles restent en vigueur).

### Dependencies

- La fonctionnalité dépend de la disponibilité d'un décompte fiable des membres d'une équipe au moment de la tentative de lancement.
- La fonctionnalité dépend du mécanisme existant de création de partie pour produire un refus sans effet de bord quand le seuil n'est pas atteint.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Quand toutes les autres règles de lancement sont satisfaites, 100% des tentatives de lancement par un organisateur avec une équipe de trois membres ou plus aboutissent à la création d'une partie.
- **SC-002**: Quand toutes les autres règles de lancement sont satisfaites, 100% des tentatives de lancement par un organisateur avec une équipe de moins de trois membres sont refusées sans création de partie.
- **SC-003**: Dans au moins 95% des tentatives de lancement (acceptées ou refusées), l'utilisateur reçoit un message de résultat en moins de 2 secondes.
- **SC-004**: Lors d'une revue d'acceptation, 100% des messages de refus pour effectif insuffisant mentionnent explicitement la contrainte de trois membres minimum.
