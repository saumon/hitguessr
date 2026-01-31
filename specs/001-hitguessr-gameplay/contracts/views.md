# Views Contract: HitGuessr

**Date**: 2026-01-31  
**Branch**: `001-hitguessr-gameplay`

Ce document définit les vues principales et leur contenu pour chaque phase du jeu.

**Note**: Authentication views (sign_in, sign_up, password reset) use Devise default templates with TailwindCSS styling applied in Phase 6.

---

## Layout Principal

### `app/views/layouts/application.html.erb`

```text
┌─────────────────────────────────────────────────────────────┐
│ Header                                                       │
│ ┌─────────────┐                    ┌──────────────────────┐ │
│ │ HitGuessr   │                    │ User: [name] | Logout│ │
│ └─────────────┘                    └──────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Flash messages: success/alert]                            │
│                                                             │
│  <%= yield %>                                               │
│                                                             │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ Footer: © 2026 HitGuessr                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Teams Views

### `teams/index` - Liste des équipes

```text
┌─────────────────────────────────────────────────────────────┐
│ Mes Équipes                              [+ Créer équipe]   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎵 Les Mélomanes         Organisateur: Moi              │ │
│ │    5 membres | 3 parties jouées        [Voir] [Jouer]   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎵 Rock Fans             Organisateur: Alice            │ │
│ │    4 membres | 1 partie en cours       [Voir] [Jouer]   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### `teams/show` - Détail équipe

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Retour    Les Mélomanes                    [Éditer]       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Organisateur: Jean Dupont                                   │
│                                                             │
│ Membres (5):                                                │
│ ┌───────────────────────────────────────────────────────┐   │
│ │ 👤 Jean Dupont (organisateur)                         │   │
│ │ 👤 Marie Martin                              [Retirer]│   │
│ │ 👤 Pierre Bernard                            [Retirer]│   │
│ │ 👤 Sophie Petit                              [Retirer]│   │
│ │ 👤 Lucas Moreau                              [Retirer]│   │
│ └───────────────────────────────────────────────────────┘   │
│                                                             │
│ [+ Ajouter un membre]                                       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ Parties récentes:                     [🎮 Lancer une partie]│
│ ┌───────────────────────────────────────────────────────┐   │
│ │ Partie #3 - 28/01/2026 - Terminée      [Voir résultats]│   │
│ │ Partie #2 - 15/01/2026 - Terminée      [Voir résultats]│   │
│ │ Partie #1 - 01/01/2026 - Terminée      [Voir résultats]│   │
│ └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Games Views

### `games/show` - Phase Collecte (status: collecting)

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Équipe    Partie #4 - Les Mélomanes                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  📝 PHASE: Collecte des propositions                    │ │
│ │     Chaque joueur soumet sa musique secrète            │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Progression: 3/5 propositions reçues                        │
│ ████████████░░░░░░░░ 60%                                    │
│                                                             │
│ Statut des joueurs:                                         │
│ ┌───────────────────────────────────────────────────────┐   │
│ │ ✅ Jean Dupont      - Proposition soumise             │   │
│ │ ✅ Marie Martin     - Proposition soumise             │   │
│ │ ✅ Pierre Bernard   - Proposition soumise             │   │
│ │ ⏳ Sophie Petit     - En attente                      │   │
│ │ ⏳ Lucas Moreau     - En attente                      │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                             │
│ [Ma proposition: ✅ Soumise]  ou  [Soumettre ma musique]    │
│                                                             │
│ ─────────────────────────────────────────────────────────   │
│ (Organisateur uniquement)                                   │
│ [⚠️ Passer aux devinettes] (exclut joueurs sans proposition)│
└─────────────────────────────────────────────────────────────┘
```

### `games/show` - Phase Devinettes (status: guessing)

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Équipe    Partie #4 - Les Mélomanes                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  🎯 PHASE: Devinettes                                   │ │
│ │     Associez chaque musique à son auteur               │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Progression: 2/5 joueurs ont répondu                        │
│ ████████░░░░░░░░░░░░ 40%                                    │
│                                                             │
│ [Mes devinettes: ✅ Soumises]  ou  [Faire mes devinettes]   │
│                                                             │
│ ─────────────────────────────────────────────────────────   │
│ (Organisateur uniquement)                                   │
│ [⚠️ Terminer la partie] (joueurs sans réponse = score 0)   │
└─────────────────────────────────────────────────────────────┘
```

### `games/show` - Phase Terminée (status: finished)

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Équipe    Partie #4 - Les Mélomanes                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  🏆 PARTIE TERMINÉE                                     │ │
│ │     Consultez les résultats et le classement           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│                   [Voir les résultats]                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Proposals Views

### `proposals/new` - Soumettre proposition

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Retour    Proposer ma musique                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Partie #4 - Les Mélomanes                                   │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎵 Lien de la musique                                   │ │
│ │ ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ https://www.youtube.com/watch?v=...                 │ │ │
│ │ └─────────────────────────────────────────────────────┘ │ │
│ │ Formats acceptés: YouTube, Spotify, SoundCloud, etc.   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ⚠️ Attention: vous ne pouvez soumettre qu'une seule        │
│    proposition par partie!                                  │
│                                                             │
│                    [Soumettre ma proposition]               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Guesses Views

### `guesses/new` - Faire les devinettes

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Retour    Mes devinettes                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Partie #4 - Les Mélomanes                                   │
│ Associez chaque musique à son auteur.                       │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎵 Proposition #1                                       │ │
│ │ https://youtube.com/watch?v=abc123                      │ │
│ │ [▶️ Écouter]                                            │ │
│ │                                                         │ │
│ │ Qui a proposé cette musique?                            │ │
│ │ ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ ▼ Sélectionner un membre                            │ │ │
│ │ │   ○ Jean Dupont                                     │ │ │
│ │ │   ○ Marie Martin                                    │ │ │
│ │ │   ○ Pierre Bernard                                  │ │ │
│ │ └─────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎵 Proposition #2                                       │ │
│ │ https://spotify.com/track/xyz789                        │ │
│ │ [▶️ Écouter]                                            │ │
│ │                                                         │ │
│ │ Qui a proposé cette musique?                            │ │
│ │ ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ ▼ Sélectionner un membre                            │ │ │
│ │ └─────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ... (autres propositions)                                   │
│                                                             │
│ ⚠️ Vous devez répondre à toutes les propositions            │
│                                                             │
│              [Soumettre mes devinettes]                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Results Views

### `results/show` - Résultats et classement

```text
┌─────────────────────────────────────────────────────────────┐
│ ← Retour    Résultats - Partie #4                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🏆 CLASSEMENT                                           │ │
│ ├─────────────────────────────────────────────────────────┤ │
│ │ #1  🥇 Marie Martin         4/4 bonnes réponses        │ │
│ │ #2  🥈 Jean Dupont          3/4 bonnes réponses        │ │
│ │ #2  🥈 Pierre Bernard       3/4 bonnes réponses (ex æ) │ │
│ │ #4     Sophie Petit         1/4 bonnes réponses        │ │
│ │ #5     Lucas Moreau         0/4 (pas de réponse)       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📋 DÉTAIL DES PROPOSITIONS                              │ │
│ ├─────────────────────────────────────────────────────────┤ │
│ │                                                         │ │
│ │ 🎵 Proposition #1                                       │ │
│ │ https://youtube.com/watch?v=abc123                      │ │
│ │ ✓ Auteur: Jean Dupont                                   │ │
│ │ Votre réponse: Jean Dupont ✅                           │ │
│ │                                                         │ │
│ │ 🎵 Proposition #2                                       │ │
│ │ https://spotify.com/track/xyz789                        │ │
│ │ ✓ Auteur: Marie Martin                                  │ │
│ │ Votre réponse: Pierre Bernard ❌                        │ │
│ │                                                         │ │
│ │ ... (autres propositions)                               │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│              [← Retour à l'équipe]                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## UX Guidelines (per Constitution)

### Accessibility

- Contraste minimum 4.5:1 pour texte normal
- Navigation clavier complète (tab, enter, escape)
- Labels explicites sur tous les formulaires
- Messages d'erreur associés aux champs

### Visual Consistency

- TailwindCSS v4.1 pour tous les styles
- Palette de couleurs cohérente (primary, success, warning, error)
- Icônes emoji pour feedback visuel rapide
- Boutons d'action principaux mis en évidence

### Feedback

- Flash messages pour toutes les actions (success/error)
- Indicateurs de progression visuels
- États de chargement sur les boutons
- Confirmation avant actions destructives
