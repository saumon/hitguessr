# Research — Alerte de doublon de proposition

## Decision 1: Détection des doublons côté client uniquement

- Decision: Calculer l’état de doublon dans le navigateur à chaque changement de sélection radio.
- Rationale: La spec clarifiée impose explicitement un comportement client-only et un feedback temps réel.
- Alternatives considered: Revalidation serveur à la soumission (rejetée: hors clarification), serveur-only (rejetée: non temps réel).

## Decision 2: Comparaison stricte sans normalisation

- Decision: Détecter les doublons uniquement sur égalité stricte de valeur sélectionnée (ID joueur identique).
- Rationale: Clarification validée: sensible à casse/espaces/accents; dans l’UI actuelle, la sélection par radio mappe déjà vers un identifiant stable.
- Alternatives considered: Normalisation casse/espaces/accents (rejetée: contredit clarification).

## Decision 3: Modal de confirmation bloquante avec détail des conflits

- Decision: Intercepter le submit, ouvrir une modal avec `Annuler` / `Confirmer`, et lister `nom + propositions concernées`.
- Rationale: Réduit les soumissions involontaires et rend le comportement testable de manière déterministe.
- Alternatives considered: Toast non bloquant (rejetée: trop facile à ignorer), message générique sans détails (rejetée: moins actionnable).

## Decision 4: Aucun changement de modèle de données ni d’API serveur

- Decision: Conserver les endpoints existants `GET /games/:game_id/guesses/new` et `POST /games/:game_id/guesses` sans nouveau champ.
- Rationale: Le warning est purement UI avant soumission; la création des guesses reste inchangée.
- Alternatives considered: Ajouter un flag `contains_duplicates` dans le payload (rejetée: redondant et inutile avec décision client-only).

## Decision 5: Stratégie de tests priorisant système/UI

- Decision: Ajouter des tests système couvrant P1/P2/P3 + cas limites (plus de deux doublons, résolution en temps réel, soumission sans doublon).
- Rationale: Le comportement principal est visuel et interactionnel (DOM + modal + submit flow).
- Alternatives considered: Tests unitaires JS isolés (rejetée: faible valeur seule sans vérifier intégration Rails/ERB).

## Decision 6: Documentation produit dans README et changelog

- Decision: Mettre à jour `README.md` dans la section Features/Gameplay et ajouter l’entrée dans `v1.2.3`.
- Rationale: Exigence explicite utilisateur + traçabilité release.
- Alternatives considered: Documentation uniquement dans spec (rejetée: ne répond pas à la demande README).
