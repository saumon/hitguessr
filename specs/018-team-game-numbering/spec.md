# Feature Specification: Team-Scoped Game Numbering

**Feature Branch**: `018-team-game-numbering`  
**Created**: 2026-03-14  
**Status**: Shipped  
**Input**: User description: "Actuellement, les numéros de parties affichées proviennent de Games.id, ce qui a pour conséquence qu'on voit des trous pour les parties d'une même équipe. Je veux que le numéro de partie soit un simple compteur pour l'équipe, séquentiel. Une équipe doit donc avoir des parties numérotées séquentiellement 1,2,3,... Pour cela, il faut persister en base un nouveau champ permettant d'enregistrer le numéro de partie."

## Clarifications

### Session 2026-03-14

- Q: Quel ordre utiliser pour numéroter les parties historiques lors de la migration ? → A: Ordre de création (plus ancienne = 1).
- Q: En cas de collision concurrente sur le numéro d'équipe, quel comportement appliquer ? → A: Retry borné (maximum 3 tentatives, backoff 10/25/50 ms) puis attribution du prochain numéro disponible.
- Q: Si une partie change d'équipe, quelle règle appliquer ? → A: Interdire le changement d'équipe après création.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Voir une numérotation continue des parties d'équipe (Priority: P1)

En tant que membre d'une équipe, je veux voir les parties de mon équipe numérotées 1, 2, 3, ... sans trous afin de comprendre clairement l'historique des parties.

**Why this priority**: C'est le besoin principal exprimé, et l'absence de trous est la valeur utilisateur immédiate attendue.

**Independent Test**: Créer plusieurs parties pour une même équipe, avec des suppressions ou des créations dans d'autres équipes, puis vérifier que l'affichage de cette équipe reste strictement séquentiel.

**Acceptance Scenarios**:

1. **Given** une équipe sans partie, **When** la première partie est créée, **Then** son numéro d'équipe affiché est 1.
2. **Given** une équipe avec des parties numérotées 1 et 2, **When** une nouvelle partie est créée pour cette même équipe, **Then** son numéro d'équipe affiché est 3.
3. **Given** deux équipes différentes, **When** chacune crée des parties, **Then** chaque équipe conserve sa propre séquence indépendante démarrant à 1.

---

### User Story 2 - Conserver des numéros stables dans le temps (Priority: P2)

En tant que membre d'équipe, je veux que le numéro d'une partie déjà créée reste stable afin de pouvoir la référencer sans ambiguïté.

**Why this priority**: La stabilité de référence évite les confusions dans les échanges entre joueurs et dans les vues d'historique.

**Independent Test**: Relever le numéro d'équipe de plusieurs parties, exécuter des actions courantes (nouvelles parties d'autres équipes, mise à jour d'une partie existante), puis vérifier que les numéros existants ne changent pas.

**Acceptance Scenarios**:

1. **Given** une partie existante avec un numéro d'équipe attribué, **When** d'autres parties sont créées ailleurs, **Then** le numéro de cette partie existante reste inchangé.
2. **Given** une partie existante, **When** ses autres attributs sont modifiés, **Then** son numéro d'équipe reste inchangé.

---

### User Story 3 - Afficher un numéro cohérent sur les vues de parties (Priority: P3)

En tant qu'utilisateur, je veux que les écrans qui présentent les parties d'équipe affichent le numéro séquentiel d'équipe plutôt qu'un identifiant global afin d'avoir une lecture cohérente.

**Why this priority**: La cohérence de présentation réduit les erreurs de compréhension et améliore l'expérience sur les pages de liste et de détail.

**Independent Test**: Comparer les écrans concernés pour une même partie et vérifier que le même numéro d'équipe y est affiché partout.

**Acceptance Scenarios**:

1. **Given** une partie appartenant à une équipe, **When** l'utilisateur consulte les vues qui affichent son numéro, **Then** la valeur affichée correspond au numéro séquentiel de cette équipe.

### Edge Cases

- Que se passe-t-il si une partie est supprimée dans une équipe: les parties restantes conservent leur numéro historique et la prochaine partie prend le numéro suivant le plus élevé déjà attribué + 1.
- Que se passe-t-il en cas de créations quasi simultanées de parties pour la même équipe: chaque nouvelle partie reçoit un numéro unique sans doublon dans l'équipe.
- Que se passe-t-il pour les parties historiques sans numéro d'équipe: chaque partie historique se voit attribuer un numéro cohérent et unique dans sa séquence d'équipe avant affichage utilisateur.
- Que se passe-t-il pour les parties sans équipe associée: elles restent hors périmètre de cette fonctionnalité et ne sont pas réaffectées à une autre équipe après création.
- Pour la migration historique, l'attribution suit l'ordre de création dans chaque équipe (plus ancienne partie = 1), afin de garantir une séquence déterministe et lisible.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT stocker un numéro de partie séquentiel propre à l'équipe pour chaque partie associée à une équipe.
- **FR-002**: Lors de la création d'une nouvelle partie pour une équipe, le système DOIT attribuer automatiquement le prochain numéro disponible dans la séquence de cette équipe, en démarrant à 1.
- **FR-003**: Le système DOIT garantir l'unicité du numéro de partie au sein d'une même équipe.
- **FR-004**: Le système DOIT garantir l'indépendance des séquences entre équipes (la numérotation d'une équipe n'affecte jamais celle d'une autre équipe).
- **FR-005**: Le système DOIT conserver de manière stable le numéro d'équipe d'une partie après sa création.
- **FR-005a**: Le système DOIT interdire le changement d'équipe d'une partie après sa création pour préserver la stabilité du numéro de partie d'équipe.
- **FR-006**: Le système DOIT afficher le numéro séquentiel d'équipe sur les écrans où un numéro de partie est présenté à l'utilisateur.
- **FR-007**: Le système DOIT fournir une règle explicite pour les suppressions: aucun renumérotage rétroactif des parties existantes, et la prochaine création poursuit la séquence.
- **FR-008**: Le système DOIT attribuer un numéro d'équipe à toutes les parties existantes liées à une équipe selon l'ordre de création au sein de chaque équipe (plus ancienne = 1) afin que l'historique soit cohérent avec la nouvelle logique.
- **FR-009**: Le système DOIT empêcher la création de deux parties avec le même numéro dans une même équipe, y compris en cas de créations concurrentes, via un mécanisme de retry borné (maximum 3 tentatives, backoff court progressif 10/25/50 ms) qui réattribue le prochain numéro disponible sans erreur utilisateur dans les cas récupérables.
- **FR-010**: Le système DOIT appliquer la nouvelle numérotation sur les écrans suivants: liste des parties d'équipe, page équipe (parties récentes/lien partie active), détail de partie et écran de résultats.

### Non-Functional Requirements

- **NFR-001 (Performance)**: L'attribution de `team_game_number` à la création doit respecter un budget p95 < 150 ms côté application dans l'environnement de référence.
- **NFR-002 (Lecture UI)**: Le rendu des listes de parties d'équipe ne doit pas introduire de requête SQL supplémentaire par rapport au comportement avant changement (à données équivalentes).
- **NFR-003 (UX Consistency)**: Pour une même partie, la valeur affichée doit être identique sur les quatre écrans cibles (liste équipe, page équipe, détail partie, résultats).

### Key Entities *(include if feature involves data)*

- **Partie (Game)**: Représente une session de jeu; porte un numéro d'équipe persistant et stable lorsqu'elle est liée à une équipe, et son rattachement d'équipe est immuable après création.
- **Équipe (Team)**: Groupe de joueurs; définit le périmètre de la séquence de numérotation des parties.
- **Numéro de partie d'équipe**: Valeur entière positive, unique dans le contexte d'une équipe, servant de référence lisible par les utilisateurs.

## Assumptions & Dependencies

- Chaque partie liée à une équipe appartient à une seule équipe à la fois.
- Les écrans explicitement concernés sont: `games/index`, `teams/show`, `games/show`, `results/show`.
- Les données historiques doivent rester lisibles après transition, sans perte de traçabilité des parties.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dans 100% des équipes ayant au moins une partie, la première partie affichée est numérotée 1.
- **SC-002**: Pour 100% des nouvelles parties créées, le numéro attribué est strictement le suivant de la séquence de l'équipe concernée.
- **SC-003**: Dans 100% des équipes, aucun doublon de numéro de partie n'est observé.
- **SC-004**: Après migration, 100% des parties historiques liées à une équipe affichent un numéro d'équipe non vide et cohérent dans la séquence de leur équipe.
- **SC-005**: Lors de tests de création simultanée sur une même équipe, 100% des parties créées reçoivent des numéros uniques et sans collision.
- **SC-006**: Lors de collisions concurrentes récupérables, au moins 99,9% des créations aboutissent sans erreur affichée à l'utilisateur grâce au retry borné (maximum 3 tentatives, backoff 10/25/50 ms).
- **SC-007**: Sur l'environnement de référence, la création d'une partie avec attribution du numéro d'équipe respecte un p95 < 150 ms.
- **SC-008**: Le rendu des pages `games/index` et `teams/show` n'ajoute aucune requête SQL supplémentaire liée à l'affichage du numéro de partie.
