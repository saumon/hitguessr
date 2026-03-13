# Feature Specification: Identifiants Publics Courts Pour URLs

**Feature Branch**: `017-public-url-ids`  
**Created**: 2026-03-13  
**Status**: Shipped  
**Input**: User description: "Remplacer les identifiants numériques exposés dans les URLs publiques par des identifiants publics courts, non prévisibles et préfixés pour certaines ressources de l'application."

## Clarifications

### Session 2026-03-13

- Q: Quel comportement pour un identifiant numérique sur un endpoint public ? -> A: Rejeter tout ID numérique sur endpoints publics avec 404, sans redirection.
- Q: Quel format exact pour le segment aleatoire ? -> A: Segment aleatoire fixe 8 caracteres, alphanumerique mixte base62 (A-Z, a-z, 0-9).
- Q: Quelle regle d'unicite pour le segment ? -> A: Unicite globale du segment base62, tous prefixes confondus.
- Q: Quelle strategie de migration pour les donnees historiques ? -> A: Backfill complet en amont, puis activation de la resolution publique dans un second deploiement.
- Q: Quelle politique en cas de collision a la creation ? -> A: Reessayer jusqu'a 5 fois, puis echouer avec erreur interne controlee et journalisee.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Acceder a une partie via identifiant public (Priority: P1)

En tant que joueur, je dois ouvrir une partie avec une URL publique qui n'expose pas l'identifiant interne incrementiel, afin de limiter la devinabilite des ressources.

**Why this priority**: Les parties sont la ressource principale de l'application. Si elles restent en identifiant numerique, l'objectif de securisation des URLs publiques n'est pas atteint.

**Independent Test**: Creer une nouvelle partie puis verifier que l'URL publique de cette partie suit le format attendu avec prefixe `gm_`, sans numero incrementiel apparent.

**Acceptance Scenarios**:

1. **Given** une nouvelle partie creee, **When** un utilisateur ouvre sa page publique, **Then** l'URL utilise un identifiant public de type `gm_<id_court>`.
2. **Given** une partie existante sans identifiant public visible en URL, **When** un utilisateur ouvre sa page publique apres migration, **Then** l'URL affiche un identifiant public unique de type `gm_<id_court>`.

---

### User Story 2 - Acceder a une equipe via identifiant public (Priority: P2)

En tant que membre d'equipe, je dois acceder aux equipes via une URL publique basee sur un identifiant non previsible, afin d'eviter l'enumeration facile des equipes.

**Why this priority**: Les equipes sont egalement exposees publiquement. Leur protection contre l'enumeration est necessaire pour une experience coherente et plus sure.

**Independent Test**: Creer une nouvelle equipe puis verifier que l'URL publique de l'equipe suit le format attendu avec prefixe `tm_`.

**Acceptance Scenarios**:

1. **Given** une nouvelle equipe creee, **When** un utilisateur ouvre sa page publique, **Then** l'URL utilise un identifiant public de type `tm_<id_court>`.
2. **Given** une equipe existante avant changement, **When** elle est consultee apres migration, **Then** elle dispose d'un identifiant public unique et son URL publique l'utilise.

---

### User Story 3 - Compatibilite des flux existants avec identifiants publics (Priority: P3)

En tant qu'utilisateur, je dois continuer a utiliser les parcours existants (navigation, liens partages, appels applicatifs) sans rupture fonctionnelle, avec les nouveaux identifiants publics.

**Why this priority**: Une transition non regressive est necessaire pour ne pas interrompre les usages courants de l'application.

**Independent Test**: Executer les parcours publics existants concernant parties et equipes et verifier qu'ils resolvent correctement les ressources via identifiants publics.

**Acceptance Scenarios**:

1. **Given** un endpoint existant qui cible une partie ou une equipe, **When** il recoit un identifiant public valide, **Then** il retourne la ressource attendue.
2. **Given** une ressource publique accessible avant changement, **When** l'utilisateur suit un lien genere apres changement, **Then** le parcours fonctionne sans exposer l'identifiant numerique interne.

### Edge Cases

- Que se passe-t-il si une URL publique contient un identifiant mal forme (mauvais prefixe, longueur invalide, caracteres non autorises) ? La ressource doit etre consideree introuvable.
- Que se passe-t-il en cas de collision d'identifiant public lors de la creation ? Le systeme doit garantir l'unicite finale de l'identifiant assigne.
- En cas de collisions consecutives lors de la creation d'un identifiant public, le systeme doit reessayer au maximum 5 fois; au-dela, la creation doit echouer de facon controlee avec journalisation technique.
- Que se passe-t-il pour les parties et equipes historiques sans identifiant public ? Elles doivent recevoir un identifiant public unique avant d'etre exposees en URL.
- Que se passe-t-il si un client appelle encore un endpoint public avec un identifiant numerique ? La ressource doit etre consideree introuvable (404) et aucune redirection ne doit etre emise.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le systeme MUST attribuer automatiquement un identifiant public unique a chaque nouvelle partie au moment de sa creation.
- **FR-002**: Le systeme MUST attribuer automatiquement un identifiant public unique a chaque nouvelle equipe au moment de sa creation.
- **FR-003**: L'identifiant public d'une partie MUST respecter le format `gm_<segment>` ou `<segment>` contient exactement 8 caracteres base62 (`[A-Za-z0-9]{8}`).
- **FR-004**: L'identifiant public d'une equipe MUST respecter le format `tm_<segment>` ou `<segment>` contient exactement 8 caracteres base62 (`[A-Za-z0-9]{8}`).
- **FR-005**: Le systeme MUST utiliser l'identifiant public dans toutes les URLs publiques de parties et d'equipes.
- **FR-006**: Les endpoints publics existants de parties et d'equipes MUST accepter un identifiant public valide et resoudre la bonne ressource.
- **FR-007**: Les identifiants numeriques internes MAY rester presents en stockage interne, mais MUST NOT apparaitre dans les URLs publiques.
- **FR-008**: Le systeme MUST garantir l'unicite globale du segment base62 de 8 caracteres (aucune reutilisation, y compris entre parties et equipes).
- **FR-009**: Le systeme MUST attribuer un identifiant public a toutes les parties et equipes deja existantes avant ou pendant le deploiement de la fonctionnalite.
- **FR-010**: En cas d'identifiant public invalide ou inexistant dans une requete publique, le systeme MUST repondre comme ressource introuvable sans divulguer d'information interne supplementaire.
- **FR-011**: En cas d'identifiant numerique interne fourni a un endpoint public, le systeme MUST repondre 404 (ressource introuvable) et MUST NOT rediriger vers une URL publique.
- **FR-012**: Le systeme MUST executer un backfill complet des identifiants publics pour toutes les parties et equipes historiques avant d'activer la resolution publique basee sur ces identifiants.
- **FR-013**: En cas de collision lors de la generation d'un identifiant public, le systeme MUST reessayer jusqu'a 5 tentatives maximum; au-dela, il MUST echouer avec une erreur interne controlee et journalisee.

### Key Entities *(include if feature involves data)*

- **Game (Partie)**: Ressource de jeu exposee publiquement, portant un identifiant interne et un identifiant public de type `gm_...`.
- **Team (Equipe)**: Ressource d'equipe exposee publiquement, portant un identifiant interne et un identifiant public de type `tm_...`.
- **Public Identifier**: Chaine publique courte, aleatoire, non sequentielle, composee d'un prefixe metier et d'un segment base62 fixe de 8 caracteres, avec unicite globale du segment tous prefixes confondus.

### Assumptions

- Le segment aleatoire des identifiants publics est fixe a 8 caracteres base62 (`A-Z`, `a-z`, `0-9`), hors prefixe.
- Les prefixes `gm` et `tm` sont stables et reserves respectivement aux parties et equipes.
- Les usages internes qui ne sont pas des URLs publiques peuvent continuer a exploiter l'identifiant numerique interne.
- Les flux de partage et de navigation utilisateur doivent produire exclusivement des URLs publiques basees sur les identifiants publics.

### Dependencies

- Les donnees historiques de parties et equipes doivent etre enrichies avec un identifiant public unique.
- Les canaux qui construisent des URLs publiques (pages, redirections, reponses applicatives) doivent etre aligns sur le nouvel identifiant.
- Le deploiement doit etre separe en deux etapes: backfill complet valide, puis activation des routes et resolvers publics.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des nouvelles parties creees sur une periode d'observation de 7 jours disposent d'un identifiant public commencant par `gm_` et sont accessibles via cet identifiant.
- **SC-002**: 100% des nouvelles equipes creees sur une periode d'observation de 7 jours disposent d'un identifiant public commencant par `tm_` et sont accessibles via cet identifiant.
- **SC-003**: 100% des parties et equipes existantes au moment de l'activation disposent d'un identifiant public unique et exploitable en URL publique.
- **SC-004**: 0 URL publique observee dans les parcours principaux n'expose un identifiant numerique interne apres deploiement.
- **SC-005**: Au moins 95% des utilisateurs de test reussissent a ouvrir une partie ou une equipe via un lien public partage du premier coup, sans erreur de resolution d'identifiant.
