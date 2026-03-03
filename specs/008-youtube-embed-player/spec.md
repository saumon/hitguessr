# Feature Specification: Lecteur YouTube Embarqué en Phase de Devinette

**Feature Branch**: `008-youtube-embed-player`  
**Created**: 14 février 2026  
**Status**: Shipped  
**Input**: User description: "Implémenter une nouvelle feature où lors de la phase de devinette et dans le cas où le lien est un lien YouTube, le joueur est capable de visualiser la vidéo YouTube directement sur le site, via une iframe embedded. Dans le cas où le lien est bien un lien YouTube, l'iframe doit apparaître sous le lien, et l'utilisateur peut décider lui-même de lancer la vidéo. Par défaut, la vidéo n'est pas démarrée. Sous l'iFrame, l'utilisateur peut sélectionner celui qui a fait la proposition."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visualiser une vidéo YouTube pendant la devinette (Priority: P1)

En tant que joueur participant à une partie de HitGuessr, pendant la phase de devinette, je veux pouvoir visualiser la vidéo YouTube proposée directement sur le site sans ouvrir un nouvel onglet, afin de mieux identifier la chanson et son auteur.

**Why this priority**: C'est le cœur de la feature - sans cette capacité, la feature n'a aucune valeur. Les joueurs ont besoin de voir et entendre le contenu pour faire leur devinette.

**Independent Test**: Peut être testé en créant une partie avec un lien YouTube valide, naviguant vers la phase de devinette, et vérifiant que l'iframe s'affiche sous le lien.

**Acceptance Scenarios**:

1. **Given** je suis un joueur dans une partie en phase de devinette et la proposition contient un lien YouTube valide, **When** la page de devinette s'affiche, **Then** je vois le lien YouTube suivi d'une iframe YouTube intégrée affichant la miniature de la vidéo.

2. **Given** je suis un joueur dans une partie en phase de devinette et la proposition contient un lien YouTube valide, **When** la page se charge, **Then** la vidéo n'est pas démarrée automatiquement (affiche la miniature avec le bouton play).

3. **Given** je suis un joueur et l'iframe YouTube est affichée, **When** je clique sur le bouton play de l'iframe, **Then** la vidéo démarre et je peux la visionner directement sur la page.

---

### User Story 2 - Faire une devinette après avoir visionné la vidéo (Priority: P1)

En tant que joueur, après avoir visionné la vidéo YouTube, je veux pouvoir sélectionner le joueur qui a fait cette proposition parmi la liste des membres de l'équipe, afin de valider ma devinette.

**Why this priority**: Le sélecteur de joueur sous l'iframe est essentiel pour compléter le flux de jeu. Sans cela, le joueur ne peut pas soumettre sa devinette.

**Independent Test**: Peut être testé en vérifiant que le sélecteur de joueur s'affiche sous l'iframe et que la sélection fonctionne correctement.

**Acceptance Scenarios**:

1. **Given** je suis un joueur en phase de devinette avec une vidéo YouTube affichée, **When** je regarde sous l'iframe, **Then** je vois le sélecteur pour choisir qui a fait la proposition.

2. **Given** je suis un joueur en phase de devinette avec l'iframe YouTube affichée, **When** je sélectionne un joueur dans le sélecteur sous l'iframe, **Then** ma sélection est enregistrée et je peux valider ma devinette.

---

### User Story 3 - Liens non-YouTube affichés normalement (Priority: P2)

En tant que joueur participant à une partie de HitGuessr, lorsque la proposition contient un lien qui n'est pas un lien YouTube, je veux que le comportement actuel soit préservé, afin de ne pas avoir d'iframe vide ou d'erreur.

**Why this priority**: La rétrocompatibilité avec les liens non-YouTube est importante mais secondaire, car la feature principale cible les liens YouTube.

**Independent Test**: Peut être testé en créant une partie avec un lien non-YouTube (ex: Spotify, SoundCloud) et en vérifiant qu'aucune iframe n'apparaît.

**Acceptance Scenarios**:

1. **Given** je suis un joueur en phase de devinette et la proposition contient un lien Spotify, **When** la page s'affiche, **Then** je vois uniquement le lien cliquable sans iframe YouTube.

2. **Given** je suis un joueur en phase de devinette et la proposition contient un lien vers un fichier audio direct, **When** la page s'affiche, **Then** aucune iframe YouTube n'est affichée.

---

### Edge Cases

- Que se passe-t-il si le lien YouTube est mal formaté (ex: `youtube.com/watch?v=` sans ID) ? → Le lien est affiché sans iframe.
- Que se passe-t-il si la vidéo YouTube n'existe plus ou est privée ? → L'iframe affiche le message d'erreur standard de YouTube ("Vidéo non disponible").
- Que se passe-t-il avec les liens YouTube Shorts (`youtube.com/shorts/xxx`) ? → Traités comme des liens YouTube valides et affichés en iframe.
- Que se passe-t-il avec les liens youtu.be (format court) ? → Traités comme des liens YouTube valides et affichés en iframe.
- Que se passe-t-il avec les liens YouTube Music (`music.youtube.com`) ? → Traités comme des liens YouTube valides et affichés en iframe.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT détecter si un lien de proposition est un lien YouTube valide (youtube.com/watch, youtu.be, youtube.com/shorts, music.youtube.com).
- **FR-002**: Le système DOIT afficher une iframe YouTube embedded sous le lien lorsque celui-ci est un lien YouTube valide.
- **FR-003**: L'iframe YouTube DOIT être configurée pour ne PAS démarrer automatiquement la vidéo (pas d'autoplay).
- **FR-004**: Le sélecteur de joueur (pour deviner qui a fait la proposition) DOIT être positionné sous l'iframe YouTube.
- **FR-005**: L'iframe DOIT respecter les bonnes pratiques de sécurité YouTube (attributs sandbox appropriés, allow pour les fonctionnalités nécessaires).
- **FR-006**: Le système NE DOIT PAS afficher d'iframe si le lien n'est pas un lien YouTube.
- **FR-007**: L'iframe DOIT être responsive et s'adapter à la taille de l'écran.
- **FR-008**: L'utilisateur DOIT pouvoir cliquer sur le lien original pour ouvrir YouTube dans un nouvel onglet (le lien reste cliquable au-dessus de l'iframe).
- **FR-009**: L'iframe DOIT avoir un attribut title descriptif pour l'accessibilité ("Lecteur vidéo YouTube").
- **FR-010**: L'iframe DOIT utiliser le lazy loading (attribut loading="lazy") pour optimiser les performances.

### Key Entities

- **Proposal (existant)**: Représente une proposition musicale avec un lien. L'attribut `url` peut contenir une URL YouTube.
- **Guess (existant)**: Représente la devinette d'un joueur sur qui a fait la proposition.

## Clarifications

### Session 2026-02-14

- Q: Mode de confidentialité YouTube (youtube-nocookie.com vs youtube.com standard) ? → A: Utiliser youtube.com standard
- Q: Accessibilité de l'iframe (titre pour lecteurs d'écran) ? → A: Titre générique ("Lecteur vidéo YouTube")
- Q: Chargement de l'iframe (immédiat vs lazy loading) ? → A: Lazy loading (chargement différé)

## Assumptions

- Le lien de la proposition est stocké en texte brut et n'est pas déjà transformé côté serveur.
- La détection YouTube se fait côté serveur via un helper Ruby (pas côté client JS).
- Les vidéos YouTube avec restrictions de lecture (régionales, âge) afficheront le message d'erreur standard de YouTube dans l'iframe.
- Le ratio d'aspect de l'iframe respecte le format vidéo standard 16:9.
- L'iframe utilise le domaine youtube.com standard (pas youtube-nocookie.com).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Les joueurs peuvent visionner une vidéo YouTube directement sur la page de devinette sans quitter le site.
- **SC-002**: 100% des formats de liens YouTube courants (youtube.com/watch, youtu.be, youtube.com/shorts) sont correctement détectés et embedés.
- **SC-003**: Le temps de chargement de la page de devinette avec iframe reste inférieur à 2 secondes sur une connexion standard.
- **SC-004**: L'iframe YouTube ne démarre jamais automatiquement - l'utilisateur garde le contrôle du lancement.
- **SC-005**: Le sélecteur de joueur reste visible et fonctionnel sous l'iframe sur tous les appareils (desktop, tablette, mobile).
- **SC-006**: Les joueurs complètent leur devinette avec le même taux de réussite qu'avant la feature (pas de régression UX).
