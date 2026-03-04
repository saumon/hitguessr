# Phase 0 Research — Repositionnement du bouton quitter l’équipe

## Décision 1 — Position exacte de l’action

- **Decision**: Afficher l’action de sortie uniquement sur la ligne du membre connecté dans la section des membres.
- **Rationale**: Réduit les clics accidentels et supprime l’ambiguïté sur la cible de l’action.
- **Alternatives considered**:
  - Bouton dans l’en-tête de section membres.
  - Bouton en bas de section membres.
  - Bouton visible sur toutes les lignes mais actif sur une seule.

## Décision 2 — Comportement responsive mobile

- **Decision**: En petit écran, rendre le bouton sur une seconde ligne sous les informations du membre connecté, aligné à droite.
- **Rationale**: Évite le chevauchement texte/bouton et maintient une zone d’interaction claire.
- **Alternatives considered**:
  - Rester sur une seule ligne à tout prix.
  - Aligner à gauche sur mobile.

## Décision 3 — Libellé localisé avec fallback

- **Decision**: Utiliser I18n pour le libellé; fallback explicite `Quitter l'équipe` si traduction absente.
- **Rationale**: Compatible avec interface multilingue et conforme aux clarifications de spec.
- **Alternatives considered**:
  - Libellé FR figé en toutes locales.
  - Localisation partielle (FR/EN seulement).

## Décision 4 — Contrat backend inchangé

- **Decision**: Conserver `DELETE /teams/:team_id/leave` et la logique métier existante dans `MembershipsController#leave`.
- **Rationale**: Le besoin est purement UI/copy; non-régression métier exigée par FR-005.
- **Alternatives considered**:
  - Introduire un nouvel endpoint dédié UI.
  - Déplacer une partie de la logique leave dans un service dédié (hors scope).

## Décision 5 — Vérification tests

- **Decision**: Ajouter/adapter des tests de vue/système pour présence et position relative de l’action, et conserver les tests contrôleur leave existants.
- **Rationale**: Respect de la constitution (testing non négociable) avec coût maîtrisé.
- **Alternatives considered**:
  - Validation uniquement manuelle.
  - Couverture exclusivement controller.

## Décision 6 — Documentation de release

- **Decision**: Ajouter la feature au changelog du `README.md` sous la version `1.3.3`.
- **Rationale**: Exigence explicite utilisateur et pratique documentaire du dépôt.
- **Alternatives considered**:
  - Reporter au ticket de release.
  - Ajouter uniquement une note dans la spec.
