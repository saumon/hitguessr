# Feature Specification: Activation de compte par email

**Feature Branch**: `001-account-email-verification`  
**Created**: 2026-04-05  
**Status**: Shipped  
**Input**: User description: "Lorsqu'un utilisateur crée son compte, un email de confirmation doit-être envoyé. L'email doit contenir le lien d'activation du compte. L'utilisateur ne peut pas se connecter sans avoir cliqué sur le lien d'activation."

## Clarifications

### Session 2026-04-05

- Q: Lors d'un renvoi d'email de confirmation, quels liens d'activation restent valides ? → A: Seul le lien le plus recemment emis est valide; les anciens liens sont invalides.
- Q: Quel message afficher lors d'une demande de renvoi pour un email inconnu ? → A: Toujours retourner un message generique identique, sans indiquer si le compte existe.
- Q: Quel rate limit appliquer au renvoi d'email de confirmation ? → A: 1 renvoi maximum toutes les 5 minutes par compte/email cible.
- Q: Quelle duree de validite appliquer au lien d'activation ? → A: 24 heures a partir de l'emission du lien.
- Q: Quelle regle d'unicite appliquer a l'email de compte ? → A: Email unique globalement avec comparaison insensible a la casse.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Confirmer son compte après inscription (Priority: P1)

En tant que nouvel utilisateur, je veux recevoir un email de confirmation juste après mon inscription afin d'activer mon compte et accéder à l'application.

**Why this priority**: C'est la valeur principale du besoin, car sans confirmation l'utilisateur ne peut pas se connecter.

**Independent Test**: Créer un compte avec une adresse email valide, vérifier la réception d'un email contenant un lien d'activation, cliquer sur ce lien et constater que le compte passe à l'état activé.

**Acceptance Scenarios**:

1. **Given** un utilisateur finalise l'inscription avec une adresse email valide, **When** le compte est créé, **Then** un email de confirmation est envoyé à cette adresse.
2. **Given** un utilisateur a reçu l'email de confirmation, **When** il clique sur le lien d'activation valide, **Then** son compte est activé et un message explicite confirme l'activation réussie.

---

### User Story 2 - Bloquer la connexion avant activation (Priority: P1)

En tant qu'utilisateur non activé, je veux être informé clairement que je dois activer mon compte avant de pouvoir me connecter.

**Why this priority**: Le blocage de connexion avant activation est explicitement exigé et protège le flux d'authentification attendu.

**Independent Test**: Créer un compte non activé puis tenter une connexion avec les bons identifiants et vérifier que la connexion est refusée avec une indication sur l'activation requise.

**Acceptance Scenarios**:

1. **Given** un compte existe mais n'est pas activé, **When** l'utilisateur tente de se connecter avec des identifiants corrects, **Then** la connexion est refusée et un message indique qu'une activation par email est requise.
2. **Given** un compte est activé, **When** l'utilisateur se connecte avec des identifiants corrects, **Then** la connexion est autorisée selon les règles d'authentification existantes.

---

### User Story 3 - Re-demander un email de confirmation (Priority: P2)

En tant qu'utilisateur non activé qui n'a pas reçu ou a perdu l'email initial, je veux pouvoir demander un nouvel email de confirmation afin de terminer l'activation sans recréer de compte.

**Why this priority**: Cette capacité réduit les abandons d'inscription et les demandes de support liées aux emails manquants.

**Independent Test**: Sur un compte non activé, demander le renvoi de l'email de confirmation et vérifier qu'un nouvel email d'activation est reçu et permet l'activation.

**Acceptance Scenarios**:

1. **Given** un compte non activé, **When** l'utilisateur demande le renvoi de l'email de confirmation, **Then** un nouvel email avec un lien d'activation valide est envoyé.

### Edge Cases

- Si l'utilisateur clique sur un lien d'activation expiré ou invalide, le système refuse l'activation, affiche un message clair et propose le renvoi d'un nouvel email de confirmation.
- Si un nouvel email de confirmation est renvoye, tous les liens d'activation precedemment emis deviennent invalides immediatement.
- Si l'utilisateur clique plusieurs fois sur un lien d'activation déjà utilisé, le système ne réactive pas le compte et renvoie vers un état cohérent indiquant que le compte est deja active.
- Si l'email de confirmation ne peut pas etre delivre (erreur temporaire), l'utilisateur reste non active et doit pouvoir declencher un renvoi.
- Si une demande de renvoi cible un email non enregistre, le systeme retourne la meme reponse generique que pour un email existant.
- Si une demande de renvoi intervient avant 5 minutes depuis le dernier envoi pour le meme compte/email, le systeme n'envoie pas de nouvel email et retourne un retour coherent avec la politique anti-enumeration.
- Si un utilisateur tente de se connecter avant activation puis active son compte, la tentative de connexion suivante doit reussir sans intervention support.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le systeme DOIT envoyer automatiquement un email de confirmation a chaque creation de compte utilisateur reussie.
- **FR-002**: L'email de confirmation DOIT contenir un lien unique permettant d'activer le compte cible.
- **FR-003**: Le systeme DOIT marquer explicitement l'etat d'activation du compte (active ou non active).
- **FR-004**: Le systeme DOIT refuser toute tentative de connexion pour un compte non active, meme si les identifiants sont corrects.
- **FR-005**: Le systeme DOIT autoriser la connexion d'un compte active selon les regles d'authentification existantes.
- **FR-006**: Le systeme DOIT activer le compte lorsque l'utilisateur suit un lien d'activation valide.
- **FR-007**: Le systeme DOIT afficher un retour explicite pour les cas de lien d'activation invalide, expire ou deja utilise.
- **FR-008**: Le systeme DOIT permettre le renvoi d'un email de confirmation pour un compte non active.
- **FR-011**: Lors d'un renvoi d'email de confirmation, le systeme DOIT invalider tous les liens d'activation precedemment emis pour ce compte et n'accepter que le lien le plus recent non expire.
- **FR-012**: Lors d'une demande de renvoi, le systeme DOIT retourner un message de reponse generique identique, qu'un compte corresponde ou non a l'email fourni.
- **FR-013**: Le systeme DOIT limiter le renvoi d'email de confirmation a un maximum d'un envoi toutes les 5 minutes pour un meme compte/email cible.
- **FR-014**: Le systeme DOIT appliquer une validite de 24 heures a chaque lien d'activation, calculee a partir de sa date d'emission; au-dela, l'activation DOIT etre refusee.
- **FR-015**: Le systeme DOIT imposer l'unicite globale de l'adresse email de compte avec comparaison insensible a la casse.
- **FR-009**: Le systeme DOIT journaliser les evenements d'envoi et d'activation afin de faciliter le support utilisateur.
- **FR-010**: Le systeme NE DOIT PAS envoyer de nouvel email de confirmation automatique lors d'une simple tentative de connexion echouee d'un compte non active.

### Key Entities *(include if feature involves data)*

- **Compte utilisateur**: Represente l'identite applicative; inclut au minimum l'adresse email (unique globalement et comparee sans tenir compte de la casse), l'etat d'activation et la date d'activation.
- **Lien d'activation**: Reference a usage restreint associee a un compte utilisateur, avec une validite temporelle definie et un etat d'utilisation.
- **Notification de confirmation**: Message envoye a l'adresse email du compte pour permettre l'activation et tracer l'etat de distribution.

## Assumptions & Dependencies

- Le flux de creation de compte existe deja et persiste l'adresse email de l'utilisateur.
- Le systeme dispose d'un canal d'envoi email operationnel pour les notifications transactionnelles.
- Une duree de validite standard de 24 heures est appliquee par defaut aux liens d'activation.
- Le parcours de connexion existant peut afficher un message d'erreur metier sans exposer d'information sensible supplementaire.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des comptes nouvellement crees declenchent l'envoi d'un email de confirmation dans la minute suivant l'inscription.
- **SC-002**: Au moins 95% des utilisateurs qui ouvrent l'email de confirmation finalisent l'activation en moins de 5 minutes.
- **SC-003**: 100% des tentatives de connexion sur compte non active sont refusees avec un message indiquant l'activation requise.
- **SC-004**: 100% des comptes actives via un lien valide peuvent se connecter des la tentative suivante avec des identifiants corrects.
- **SC-005**: Le taux de demandes de support liees a "compte cree mais connexion impossible" diminue d'au moins 40% dans les 30 jours suivant la mise en production.
