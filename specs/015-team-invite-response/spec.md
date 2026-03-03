# Feature Specification: Gestion des invitations d’équipe

**Feature Branch**: `015-team-invite-response`  
**Created**: 2026-03-03  
**Status**: Shipped  
**Input**: User description: "En tant que membre inscrit sur le site, je veux pouvoir valider ou refuser une demande d'ajout dans une équipe envoyée par un organisateur. La validation ou le refus de l'invitation se fait sur l'écran /teams. En tant qu'organisateur, lorsque j'ajoute un membre à mon équipe, une demande d'invitation est envoyée à ce nouveau membre. Tant que ce membre n'a pas accepté l'invitation, il n'est pas considéré comme faisant partie de l'équipe. La liste des membres en attente d'acceptation doit être visible dans le bloc Membres de l'équipe."

## Clarifications

### Session 2026-03-03

- Q: Quand un membre accepte une invitation d’équipe, quelle règle d’appartenance doit s’appliquer globalement ? → A: Un membre peut appartenir à plusieurs équipes; accepter une invitation n’affecte pas les autres invitations.
- Q: Qui est autorisé à répondre (accepter/refuser) une invitation ? → A: Uniquement le membre invité (propriétaire de l’invitation).
- Q: En cas d’actions concurrentes sur la même invitation, quelle règle appliquer ? → A: La première action valide est conservée; les suivantes sont rejetées.
- Q: Les invitations en attente doivent-elles expirer automatiquement ? → A: Non, elles restent valides jusqu’à réponse explicite.
- Q: Sur `/teams`, quelle visibilité appliquer aux invitations en attente ? → A: Chaque utilisateur voit uniquement ses propres invitations reçues; la liste des membres en attente d’une équipe est visible seulement aux membres actifs de cette équipe et aux organisateurs.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Répondre à une invitation d’équipe (Priority: P1)

En tant que membre invité, je peux accepter ou refuser une invitation depuis l’écran `/teams` pour contrôler mon appartenance à une équipe.

**Why this priority**: C’est la valeur principale attendue côté membre inscrit et le point bloquant pour la composition réelle des équipes.

**Independent Test**: Peut être testé en créant une invitation pour un membre puis en vérifiant que le membre peut l’accepter ou la refuser sur `/teams`, avec un effet immédiat sur son statut d’appartenance.

**Acceptance Scenarios**:

1. **Given** un membre reçoit une invitation en attente, **When** il choisit "Accepter" sur `/teams`, **Then** il devient membre actif de l’équipe et l’invitation n’apparaît plus comme en attente.
2. **Given** un membre reçoit une invitation en attente, **When** il choisit "Refuser" sur `/teams`, **Then** il n’est pas ajouté à l’équipe et l’invitation est marquée comme refusée.
3. **Given** un membre n’a pas d’invitation en attente, **When** il ouvre `/teams`, **Then** aucune action d’acceptation/refus n’est affichée pour lui.

---

### User Story 2 - Envoyer une invitation lors de l’ajout d’un membre (Priority: P2)

En tant qu’organisateur, lorsque j’ajoute un membre à mon équipe, le système envoie une demande d’invitation au lieu d’ajouter immédiatement ce membre comme actif.

**Why this priority**: Garantit le consentement du membre et évite les ajouts forcés dans une équipe.

**Independent Test**: Peut être testé en ajoutant un membre depuis l’espace organisateur puis en vérifiant que le membre ciblé est en attente tant qu’il n’a pas répondu.

**Acceptance Scenarios**:

1. **Given** un organisateur ajoute un membre à son équipe, **When** l’action est validée, **Then** une invitation en attente est créée pour ce membre.
2. **Given** une invitation est en attente, **When** l’organisateur consulte la liste des membres de l’équipe, **Then** le membre invité apparaît comme "en attente" et non comme membre actif.

---

### User Story 3 - Visualiser les membres en attente dans le bloc Membres (Priority: P3)

En tant qu’organisateur ou membre de l’équipe, je vois dans le bloc "Membres" quels utilisateurs sont en attente d’acceptation afin de comprendre l’état réel de l’effectif.

**Why this priority**: Améliore la lisibilité de l’état de l’équipe et limite les ambiguïtés sur qui fait réellement partie de l’équipe.

**Independent Test**: Peut être testé en ayant au moins un membre actif et un membre invité en attente, puis en vérifiant l’affichage distinct dans le bloc "Membres".

**Acceptance Scenarios**:

1. **Given** une équipe a des invitations en attente, **When** la page `/teams` est affichée, **Then** le bloc "Membres" montre une section ou un indicateur clair des membres en attente.
2. **Given** un membre invité accepte son invitation, **When** la page `/teams` est rafraîchie, **Then** il disparaît de la zone "en attente" et apparaît parmi les membres actifs.

### Edge Cases

- Un membre reçoit plusieurs invitations d’équipes différentes: il peut répondre à chaque invitation indépendamment.
- Un organisateur tente d’inviter un membre déjà actif dans l’équipe: aucune nouvelle invitation en attente ne doit être créée.
- Une invitation déjà traitée (acceptée ou refusée) ne peut pas être traitée une seconde fois.
- Un membre refuse une invitation puis est réinvité plus tard: une nouvelle invitation en attente peut être créée.
- Si un organisateur n’a plus de droits de gestion au moment de la réponse du membre, la réponse du membre reste valide pour l’invitation déjà reçue.
- Un utilisateur autre que le membre invité tente de répondre à l’invitation: la réponse est refusée.
- Des réponses concurrentes sur la même invitation sont soumises: seule la première réponse valide est appliquée, les suivantes sont rejetées.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système MUST créer une invitation en statut "en attente" lorsqu’un organisateur ajoute un membre à une équipe.
- **FR-002**: Le système MUST empêcher qu’un membre invité soit considéré comme membre actif tant que l’invitation n’est pas acceptée.
- **FR-003**: Le membre invité MUST pouvoir accepter l’invitation depuis l’écran `/teams`.
- **FR-004**: Le membre invité MUST pouvoir refuser l’invitation depuis l’écran `/teams`.
- **FR-005**: Le système MUST enregistrer le résultat de la réponse d’invitation (acceptée ou refusée) et l’associer au membre concerné.
- **FR-006**: Après acceptation, le système MUST convertir immédiatement l’invité en membre actif de l’équipe.
- **FR-007**: Après refus, le système MUST conserver le membre hors de l’équipe active.
- **FR-008**: Le bloc "Membres" sur `/teams` MUST afficher distinctement les membres actifs et les membres en attente d’acceptation.
- **FR-009**: Le système MUST empêcher la création de doublons d’invitation en attente pour un même membre dans une même équipe.
- **FR-010**: Le système MUST empêcher le retraitement d’une invitation déjà acceptée ou refusée.
- **FR-011**: L’acceptation d’une invitation MUST ne pas modifier ni annuler les autres invitations du membre dans d’autres équipes.
- **FR-012**: Le système MUST autoriser la réponse (acceptation/refus) uniquement au membre invité lié à l’invitation.
- **FR-013**: Le système MUST appliquer un traitement atomique de la réponse d’invitation: la première réponse valide est persistée, toute réponse ultérieure est rejetée.
- **FR-014**: Le système MUST conserver une invitation en statut "en attente" sans expiration automatique tant qu’aucune réponse explicite n’est enregistrée.
- **FR-015**: Le système MUST afficher à chaque utilisateur uniquement ses invitations reçues.
- **FR-016**: Le système MUST limiter la visibilité de la liste des membres en attente d’une équipe aux membres actifs de cette équipe et aux organisateurs.

### Key Entities *(include if feature involves data)*

- **Invitation d’équipe**: Représente une demande d’ajout envoyée à un membre; attributs clés: équipe cible, membre cible, organisateur émetteur, statut (en attente/acceptée/refusée), date de création, date de réponse; une invitation en attente n’expire pas automatiquement.
- **Membre d’équipe actif**: Représente un utilisateur faisant officiellement partie de l’équipe après acceptation; lié à une équipe et à un utilisateur.
- **Équipe**: Regroupe des membres actifs et des invitations en attente; utilisée pour afficher l’état consolidé dans le bloc "Membres".

### Assumptions

- Une invitation vise un seul membre et une seule équipe.
- Un membre peut recevoir des invitations de plusieurs équipes en parallèle.
- Un membre peut être membre actif de plusieurs équipes; accepter une invitation n’impacte pas ses autres invitations en cours.
- L’écran `/teams` est le point d’entrée unique pour visualiser et traiter les invitations utilisateur.
- Les rôles d’organisation existants déterminent déjà qui peut initier un ajout de membre.
- Les utilisateurs non membres d’une équipe ne peuvent pas consulter la liste de ses invitations en attente.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des membres invités peuvent accepter ou refuser une invitation depuis `/teams` sans action hors de cette page.
- **SC-002**: 100% des invitations non répondues sont affichées comme "en attente" dans le bloc "Membres" de l’équipe concernée.
- **SC-003**: 100% des membres ayant accepté une invitation apparaissent comme membres actifs dans les 5 secondes suivant leur action.
- **SC-004**: 0 membre invité en attente n’est comptabilisé à tort comme membre actif.
- **SC-005**: Au moins 95% des réponses d’invitation (acceptation/refus) aboutissent sans erreur côté utilisateur au premier essai.
