# Quickstart: Quitter son équipe

**Feature**: 009-self-leave-team  
**Date**: 2026-02-21

## Prerequisites

- Ruby (version du projet)
- SQLite3
- Node.js
- Bundler

## Setup

```bash
cd hitguessr
bundle install
bin/rails db:setup
bin/dev
```

Application disponible sur `http://localhost:3000`.

---

## Manual Validation Scenarios

### Scénario A — Membre non organisateur quitte avec succès

1. Se connecter avec un utilisateur membre d'une équipe sans en être l'organisateur.
2. Ouvrir la page de l'équipe (`/teams/:id`).
3. Vérifier la présence d'un bouton **`Quitter`**.
4. Vérifier que ce bouton est dans la même zone d'actions d'en-tête et avec le même style visuel que **`Supprimer`**.
5. Cliquer sur **`Quitter`**.
6. Vérifier l'affichage d'une confirmation avec le texte exact: **`Êtes-vous sûr de vouloir quitter cette équipe ?`**.
7. Confirmer.
8. Vérifier la redirection vers `/teams` avec message de succès.
9. Revenir sur l'équipe et vérifier que l'utilisateur n'est plus listé dans les membres.

### Scénario B — Organisateur ne peut pas quitter

1. Se connecter avec l'organisateur de l'équipe.
2. Déclencher l'action de sortie (si le bouton est affiché selon design, ou via requête HTTP dédiée).
3. Vérifier le refus explicite.
4. Vérifier que l'organisateur reste membre de l'équipe.

### Scénario C — Refus pendant partie active

1. Sur l'équipe cible, lancer une partie (`collecting`) ou passer en `guessing`.
2. Se connecter en membre non organisateur.
3. Tenter de quitter l'équipe.
4. Vérifier le refus explicite indiquant l'indisponibilité pendant partie active.
5. Vérifier que l'appartenance est inchangée.

### Scénario D — Idempotence (déjà sorti)

1. Après une sortie réussie, relancer la même action (HTTP ou UI si encore accessible).
2. Vérifier une opération sans effet avec message clair.
3. Vérifier l'absence d'impact sur les autres équipes de l'utilisateur.

### Scénario E — Sécurité auto-service

1. Tenter d'appeler l'endpoint avec des paramètres forgés visant une appartenance tierce (ex: `membership_id`).
2. Vérifier qu'aucune suppression d'un autre membre n'est possible.

### Scénario F — Mesure de performance SC-003 (protocole SC-005)

1. Exécuter 20 fois le scénario de sortie (succès et/ou refus) en environnement local ou CI stable.
2. Mesurer à chaque exécution le temps entre la soumission de l'action et l'affichage du message flash.
3. Calculer le nombre d'exécutions ≤ 2 secondes.
4. Valider le critère: au moins 19 exécutions sur 20 doivent être ≤ 2 secondes.
5. Noter le résultat de mesure dans la section de suivi qualité du ticket/PR.

---

## Automated Tests To Run

```bash
# tests ciblés feature (noms à ajuster lors implémentation)
bin/rails test test/controllers/memberships_controller_test.rb
bin/rails test test/system/self_leave_team_test.rb

# non-régression large
bin/rails test
```

---

## Documentation Validation

1. Vérifier que le README global décrit la feature (section fonctionnalités et/ou routes).
2. Vérifier que le changelog du projet inclut une entrée dédiée à cette feature (référence spec `009-self-leave-team`).
