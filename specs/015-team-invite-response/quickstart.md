# Quickstart — Feature 015 Team Invite Response

## 1) Setup

```bash
bundle install
bin/rails db:migrate
```

## 2) Implémentation (ordre recommandé)

1. **Persistency**
   - Créer migration `team_invitations` avec FKs (`team`, `invited_user`, `invited_by`), `status`, `responded_at`.
   - Ajouter index de recherche et unicité invitation en attente.

2. **Domain model**
   - Ajouter modèle `TeamInvitation` (`enum status`, validations, scopes).
   - Ajouter associations dans `Team` et `User`.

3. **Controllers + routes**
   - Ajouter `InvitationsController` (`create`, `accept`, `refuse`).
   - Ajouter routes nested sous `teams`:
     - `POST /teams/:team_id/invitations`
     - `PATCH /teams/:team_id/invitations/:id/accept`
     - `PATCH /teams/:team_id/invitations/:id/refuse`
   - Mettre à jour flux d’ajout membre organisateur pour créer invitation au lieu de membership direct.

4. **UI `/teams`**
   - Dans le bloc `Membres`, séparer visuellement membres actifs et invitations en attente.
   - Afficher actions `Accepter` / `Refuser` uniquement pour les invitations reçues par `current_user`.
   - Afficher les invitations en attente d’une équipe seulement pour ses membres actifs + organisateur.

5. **Tests**
   - `test/controllers/invitations_controller_test.rb` (création, droits, idempotence, concurrence).
   - Mise à jour de `test/controllers/memberships_controller_test.rb` si flux create déplacé.
   - Mise à jour/ajout de `test/system/teams_test.rb` pour UX `/teams` (accept/refuse, sections pending/active).

6. **Documentation produit (obligatoire pour cette feature)**
   - Mettre à jour `README.md` section Features avec la gestion des invitations.
   - Ajouter entrée **`v1.3.0`** dans la section Changelog de `README.md`, avec lien vers `specs/015-team-invite-response/spec.md`.

## 3) Validation rapide

```bash
bin/rails test test/controllers/invitations_controller_test.rb
bin/rails test test/controllers/memberships_controller_test.rb
bin/rails test test/system/teams_test.rb
bin/rails test
```

## 4) Checklist d’acceptation

- Organisateur ajoute un email -> invitation `pending` créée.
- Invité voit son invitation sur `/teams` et peut accepter/refuser.
- Acceptation -> membre actif immédiat; refus -> pas d’adhésion.
- Invitation déjà traitée non retraitable; première réponse gagnante.
- Pas de doublon d’invitation en attente pour un même couple équipe/utilisateur.
- README Feature + Changelog `v1.3.0` mis à jour.

## 5) Revue visuelle / interaction (T035)

Effectuer une revue manuelle desktop + mobile sur les états suivants :

1. **Bloc Membres (fermé / ouvert)** : compter attendu (actifs + « en attente »)
2. **Invitation en attente côté invité** : boutons `Accepter` / `Refuser` visibles et accessibles au touch (min-height 44px)
3. **Après acceptation** : rechargement de `/teams` — membre actif visible dans le bloc, section « en attente » retirée
4. **Après refus** : rechargement de `/teams` — pas d'ajout dans le bloc membres
5. **Message flash** : apparaît correctement en haut de page, bonne couleur (notice/alert)
6. **Mobile** : formulaire d'invitation responsive, boutons action invitation sur une seule ligne

## 6) Quality gates (T036)

```bash
# Linting Ruby
bundle exec rubocop --format progress

# Tests complets
bin/rails test

# Test système ciblé
bin/rails test test/system/teams_test.rb

# Audit sécurité
bin/bundler-audit check --update
```

Critères de passage :

- `bin/rails test` : 0 failures, 0 errors
- Rubocop : 0 offenses (ou corrections justifiées)
- bundler-audit : aucune vulnérabilité critique

## 7) Mesure de performance (T037)

### SC-003 — Membre visible actif sous 5 secondes après acceptation

```bash
# Démarrer le serveur en mode production-like
RAILS_ENV=development bin/rails server

# Mesurer manuellement avec Chrome DevTools → Network
# 1. Ouvrir /teams (team avec invitation pending)
# 2. Cliquer "Accepter", noter le temps de 1re réponse HTTP (redirect) + reload /teams
# Seuil : < 5 secondes totales (redirect + page team rechargée avec membre actif affiché)
```

### SC-005 — ≥95% de réponses réussies au premier essai

Vérification par revue code :

- `accept!` et `refuse!` utilisent `update_all` conditionnel avec transaction → première réponse gagne atomiquement
- La réponse HTTP 302 est systématique (pas de 500 sur double soumission)
- Le flash `already_processed` est l'unique réponse pour les soumissions ultérieures
