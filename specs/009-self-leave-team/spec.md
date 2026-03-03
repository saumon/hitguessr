# Feature Specification: Quitter son équipe

**Feature Branch**: `009-self-leave-team`  
**Created**: 2026-02-21  
**Status**: Shipped  
**Input**: User description: "un membre d'une équipe doit pouvoir décider lui-même de la quitter. Seul un organisateur d'équipe ne peut pas quitter sa propre équipe."

## Clarifications

### Session 2026-02-21

- Q: Quelle source d'autorité définit l'"organisateur" qui ne peut pas quitter l'équipe ? → A: Interdiction basée uniquement sur `team.organizer_id` (organisateur officiel de l'équipe).
- Q: Que faire si l'équipe a une partie active (`collecting` ou `guessing`) au moment de la demande de sortie ? → A: Refuser la sortie si l'équipe a une partie active (`collecting` ou `guessing`).
- Q: Où rediriger l'utilisateur après une sortie réussie de l'équipe ? → A: Rediriger vers la liste des équipes (`teams#index`).
- Q: Quelle appartenance est ciblée par l'action de sortie auto-service ? → A: L'action vise toujours l'appartenance de `current_user` dans l'équipe ciblée.
- Q: Quel libellé et quelle ergonomie pour l'action de sortie ? → A: Le bouton s'appelle `Quitter`, reprend le même style et la même position visuelle que `Supprimer`, et demande confirmation avec le texte exact `Êtes-vous sûr de vouloir quitter cette équipe ?`.
- Q: Quels supports de documentation doivent refléter la feature ? → A: Le README global et le changelog doivent être mis à jour.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quitter volontairement une équipe (Priority: P1)

En tant que membre d'une équipe (non organisateur), je peux quitter l'équipe moi-même sans intervention d'un administrateur.

**Why this priority**: C'est le besoin principal exprimé et il réduit la friction pour gérer son appartenance à une équipe.

**Independent Test**: Peut être testé indépendamment en vérifiant qu'un membre non organisateur peut lancer l'action de départ et n'apparaît plus dans l'équipe ensuite.

**Acceptance Scenarios**:

1. **Given** un utilisateur membre d'une équipe avec un rôle non organisateur, **When** il confirme qu'il veut quitter l'équipe, **Then** son appartenance à l'équipe est supprimée.
2. **Given** un utilisateur qui vient de quitter son équipe, **When** il consulte la liste des membres de cette équipe, **Then** son nom n'y apparaît plus.

---

### User Story 2 - Empêcher un organisateur de quitter sa propre équipe (Priority: P1)

En tant qu'organisateur d'une équipe, je ne peux pas utiliser l'action de sortie de cette équipe pour éviter une équipe sans responsable.

**Why this priority**: C'est une contrainte métier explicite qui protège la gouvernance de l'équipe.

**Independent Test**: Peut être testé indépendamment en vérifiant qu'un organisateur reçoit un refus explicite et reste membre de son équipe.

**Acceptance Scenarios**:

1. **Given** un utilisateur organisateur d'une équipe, **When** il tente de quitter cette équipe, **Then** la demande est refusée avec un message indiquant qu'un organisateur ne peut pas quitter sa propre équipe.
2. **Given** une tentative refusée de sortie par un organisateur, **When** l'équipe est rechargée, **Then** l'utilisateur est toujours présent avec son rôle d'organisateur.

---

### User Story 3 - Retour clair après action (Priority: P2)

En tant qu'utilisateur, je reçois un message clair indiquant si mon départ a réussi ou pourquoi il est refusé.

**Why this priority**: Le feedback évite la confusion et les actions répétées inutiles.

**Independent Test**: Peut être testé indépendamment via deux cas (succès membre non organisateur, refus organisateur) et vérification du message affiché.

**Acceptance Scenarios**:

1. **Given** un membre non organisateur qui quitte l'équipe, **When** l'action se termine, **Then** un message de confirmation de départ est affiché.
2. **Given** un organisateur qui tente de quitter l'équipe, **When** l'action est refusée, **Then** un message d'erreur compréhensible est affiché.
3. **Given** un membre non organisateur sur la page d'équipe, **When** il déclenche `Quitter`, **Then** une confirmation s'affiche avec le texte exact `Êtes-vous sûr de vouloir quitter cette équipe ?`.

### Edge Cases

- Un utilisateur qui n'est plus membre de l'équipe au moment de la demande reçoit un retour indiquant qu'aucune sortie n'est nécessaire.
- Deux demandes de sortie consécutives pour le même membre ne provoquent pas d'état incohérent (la seconde est sans effet).
- Un utilisateur membre de plusieurs équipes ne quitte que l'équipe ciblée par son action.
- Une tentative de quitter une équipe inexistante ou inaccessible est refusée avec un message générique sans exposer d'information sensible.
- Une tentative de sortie pendant qu'une partie de l'équipe est active (`collecting` ou `guessing`) est refusée avec un message explicite.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT permettre à un membre non organisateur de quitter explicitement une équipe dont il fait partie.
- **FR-002**: Le système DOIT interdire à l'utilisateur dont l'identité correspond à `team.organizer_id` de quitter sa propre équipe via cette action.
- **FR-003**: Le système DOIT vérifier l'appartenance active de l'utilisateur à l'équipe au moment de la demande de sortie.
- **FR-004**: Le système DOIT supprimer l'appartenance du membre quand la sortie est autorisée.
- **FR-005**: Le système DOIT conserver inchangée l'appartenance de l'organisateur quand la sortie est refusée.
- **FR-006**: Le système DOIT afficher un message de confirmation en cas de sortie réussie.
- **FR-007**: Le système DOIT afficher un message explicite en cas de refus pour organisateur.
- **FR-008**: Le système DOIT traiter une seconde demande de sortie d'un même utilisateur déjà sorti comme une opération sans effet et avec retour clair.
- **FR-009**: Le système DOIT appliquer cette règle uniquement à l'équipe ciblée, sans modifier les autres appartenances de l'utilisateur.
- **FR-010**: Le système DOIT refuser toute demande de sortie d'équipe tant qu'une partie de cette équipe est active (`collecting` ou `guessing`).
- **FR-011**: Le système DOIT afficher un message explicite indiquant que la sortie est indisponible pendant une partie active.
- **FR-012**: Après une sortie réussie, le système DOIT rediriger l'utilisateur vers la liste de ses équipes (`teams#index`).
- **FR-013**: L'action de sortie auto-service DOIT cibler exclusivement l'appartenance de l'utilisateur courant (`current_user`) dans l'équipe ciblée.
- **FR-014**: Le système NE DOIT PAS permettre de choisir ou supprimer l'appartenance d'un autre membre via un identifiant d'appartenance fourni par le client.
- **FR-015**: Sur la page équipe, l'action de sortie auto-service DOIT être affichée avec le libellé exact `Quitter`.
- **FR-016**: Le bouton `Quitter` DOIT être rendu dans le même conteneur d'actions d'en-tête que `Supprimer` et utiliser la même liste de classes CSS que `Supprimer` (à l'exception du libellé), afin de garantir un style et un positionnement identiques.
- **FR-017**: Le bouton `Quitter` DOIT afficher une boîte de dialogue de confirmation avec le texte exact `Êtes-vous sûr de vouloir quitter cette équipe ?` avant d'envoyer la demande.
- **FR-018**: La livraison DOIT inclure une mise à jour du README global et du changelog pour décrire la nouvelle fonctionnalité.

### Key Entities *(include if feature involves data)*

- **Utilisateur**: Personne authentifiée pouvant appartenir à une ou plusieurs équipes, avec un rôle spécifique par équipe.
- **Équipe**: Groupe de joueurs avec une liste de membres et au moins un organisateur.
- **Appartenance d'équipe**: Lien entre un utilisateur et une équipe, incluant le rôle (organisateur ou membre standard) et l'état actif de participation.

### Assumptions

- L'action de sortie est déclenchée par un utilisateur authentifié agissant pour son propre compte.
- Le rôle organisateur est déterminé uniquement par `team.organizer_id` pour l'équipe ciblée.
- Le besoin couvre la sortie d'une équipe existante dans l'application actuelle, sans redéfinir les autres règles de gestion des équipes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des demandes de sortie initiées par des membres non organisateurs aboutissent à la suppression effective de leur appartenance à l'équipe ciblée.
- **SC-002**: 100% des tentatives de sortie initiées par des organisateurs de leur propre équipe sont refusées et la composition de l'équipe reste inchangée.
- **SC-003**: Dans au moins 95% des cas testés, l'utilisateur reçoit un message de résultat (succès ou refus) en moins de 2 secondes après l'action.
- **SC-004**: 100% des actions de sortie n'affectent que l'équipe ciblée, sans modification involontaire des autres équipes de l'utilisateur.
- **SC-005**: La mesure de SC-003 DOIT être réalisée sur 20 exécutions de test système (local ou CI), en mesurant le temps entre la soumission de l'action et l'affichage du message flash; au moins 19 exécutions sur 20 DOIVENT être ≤ 2 secondes.
