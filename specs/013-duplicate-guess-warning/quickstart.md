# Quickstart — Implémentation feature 013

## 1) Préparer

1. Vérifier que la branche active est `013-duplicate-guess-warning`.
2. Installer les dépendances si nécessaire: `bundle install`.
3. Démarrer l’app: `bin/dev`.

## 2) Implémenter la détection temps réel (client)

1. Ajouter un contrôleur Stimulus `app/javascript/controllers/guess_duplicates_controller.js`.
2. À chaque changement radio:
   - recalculer les sélections par `guessed_author_id`
   - marquer les lignes en doublon (inline indicator visible)
   - maintenir une structure détaillée (`nom + propositions concernées`) pour la modal.
3. Enregistrer le contrôleur dans `app/javascript/controllers/index.js`.

## 3) Intégrer dans la vue de devinettes

1. Modifier `app/views/guesses/new.html.erb`:
   - brancher les `data-*` nécessaires au contrôleur
   - ajouter l’indicateur visuel par proposition
   - ajouter la modal de confirmation bloquante avec `Annuler` / `Confirmer`
   - afficher dans la modal chaque doublon (`nom + propositions concernées`).
2. Intercepter submit:
   - sans doublon: submit direct
   - avec doublon: ouvrir modal puis soumettre uniquement sur `Confirmer`.

## 4) Tests

1. Ajouter un test système `test/system/guesses_duplicate_warning_test.rb` couvrant:
   - apparition/disparition temps réel des indicateurs
   - modal affichée uniquement quand doublons présents
   - soumission possible après confirmation
   - absence de modal sans doublon.
2. Exécuter au minimum:
   - `bin/rails test test/system/guesses_duplicate_warning_test.rb`
   - `bin/rails test` (si temps CI local disponible)

## 5) Documentation obligatoire

1. Mettre à jour `README.md` section Features/Gameplay pour décrire la feature.
2. Ajouter la feature dans le changelog `README.md` sous `v1.2.3`.

## 6) Quality gates

- Lint/style: `bin/rubocop` (si activé dans votre flux local)
- Vérifier UX mobile/desktop pour cohérence visuelle et lisibilité de la modal

## 7) Mesurer les critères de succès

### SC-001 — Réactivité de l’indicateur (< 1s dans 95% des interactions)

1. Ouvrir la page de devinettes avec au moins 5 propositions.
2. Réaliser 20 changements de sélection radio (cas sans doublon et avec doublon).
3. Mesurer le délai entre l’événement `change` et la mise à jour visuelle de l’indicateur (via Performance panel ou timestamps de logs).
4. Vérifier qu’au moins 19/20 interactions sont < 1s.

### SC-004 — Test utilisateur guidé (>= 90%)

1. Préparer un script guidé “identifier si doublon présent avant soumission”.
2. Faire exécuter le script à au moins 10 joueurs/tests.
3. Calculer le taux de détection correcte des doublons.
4. Vérifier que le taux est >= 90%.

## 8) Validation Results

- SC-001: Non mesuré instrumentalement — l'algorithme de détection est O(n) sur les sélections radio, recalcul synchrone en JS sans réseau ni API serveur. Le seuil < 1s est atteignable par construction pour tout tableau de ≤ 20 propositions sur un navigateur moderne.
- SC-004: Protocole de test guidé non encore exécuté — à planifier avec au moins 10 participants une fois la feature déployée en staging.
- Date et environnement: 2026-03-02, implementation IA (GitHub Copilot), macOS, Ruby 3.4.6 / Rails 8.1.2 / Stimulus via importmap.
