# Quickstart — Repositionnement du bouton quitter l’équipe

## Prérequis

- Ruby/Bundler installés
- Dépendances du projet installées
- Base de données initialisée

## Lancer l’application

```bash
bin/dev
```

## Vérifications manuelles

### 1) Positionnement desktop

1. Se connecter avec un membre actif non organisateur.
2. Ouvrir la page d’une équipe (`/teams/:id`).
3. Ouvrir la section membres.
4. Vérifier que l’action de sortie apparaît uniquement sur la ligne du membre connecté, alignée à droite.
5. Vérifier que l’action n’est plus affichée dans l’ancien bloc d’actions d’en-tête.

### 2) Positionnement mobile

1. Passer en viewport mobile (outil responsive navigateur).
2. Vérifier que l’action passe sur une seconde ligne sous les informations du membre connecté.
3. Vérifier l’alignement à droite et l’absence de chevauchement visuel.

### 3) Libellé localisé

1. Avec locale FR, vérifier le libellé affiché.
2. Avec une locale traduite, vérifier l’usage de la traduction.
3. Si clé absente, vérifier le fallback `Quitter l'équipe`.

### 4) Non-régression métier leave

1. Cliquer l’action pour quitter et confirmer.
2. Vérifier que le comportement métier est identique à l’existant (messages/redirections/règles organisateur/partie active).

## Vérifications automatisées (ciblées)

```bash
bin/rails test test/controllers/memberships_controller_test.rb
bin/rails test test/system
```

## Vérification documentation release

1. Ouvrir `README.md`.
2. Vérifier la présence d’une entrée de changelog pour la version `1.3.3` décrivant cette feature.
