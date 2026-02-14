# Research: Lecteur YouTube Embarqué

**Feature**: 008-youtube-embed-player  
**Date**: 2026-02-14

## Résumé des recherches

Ce document consolide les décisions techniques pour l'intégration du lecteur YouTube dans HitGuessr.

---

## 1. Gem media_embed

### Decision

Utiliser la gem `media_embed` (v1.0.0) pour la détection et l'embedding YouTube.

### Rationale

- Gem mature (2017) avec API simple et bien documentée
- Détection automatique des URLs YouTube via `youtube?(url)`
- Génération d'iframe via `embed(url, options)`
- Supporte les options YouTube natives (autoplay, controls, etc.)
- Compatible Rails (Railtie fournie)

### Alternatives considérées

| Alternative | Raison du rejet |
| ----------- | --------------- |
| Implémentation manuelle regex | Plus de code à maintenir, risque de bugs sur edge cases |
| Gem `video_info` | Plus orientée récupération de métadonnées que embedding |
| Gem `oembed` | Trop générique, requiert appels API externes |

### API clé

```ruby
# Dans un helper ou vue
MediaEmbed::Handler.new.youtube?(url)     # → Boolean
MediaEmbed::Handler.new.embed(url, opts)  # → String (HTML iframe)

# Options YouTube supportées
options = {
  autoplay: 0,        # Pas d'autoplay (requis par spec FR-003)
  controls: 1,        # Contrôles activés
  modestbranding: 1,  # Branding minimal
  rel: 0              # Pas de vidéos suggérées à la fin
}
```

---

## 2. Intégration iframe YouTube

### Decision for Intégration iframe YouTube

Wrapper l'iframe générée dans un conteneur responsive 16:9 avec attributs d'accessibilité.

### Rationale for Intégration iframe YouTube

- L'iframe media_embed ne gère pas nativement le responsive
- Besoin d'ajouter `loading="lazy"` et `title` pour accessibilité
- Pattern Tailwind CSS standard pour aspect-ratio

### Implementation pattern

```erb
<% if youtube_url?(proposal.url) %>
  <div class="aspect-video w-full mt-4">
    <%= youtube_embed(proposal.url) %>
  </div>
<% end %>
```

```ruby
# Helper
def youtube_url?(url)
  MediaEmbed::Handler.new.youtube?(url)
end

def youtube_embed(url)
  handler = MediaEmbed::Handler.new
  html = handler.embed(url, autoplay: 0, rel: 0, modestbranding: 1)
  
  # Ajouter attributs manquants
  html = html.gsub('<iframe', '<iframe loading="lazy" title="Lecteur vidéo YouTube"')
  html.html_safe
end
```

---

## 3. Formats YouTube supportés par media_embed

### Decision for Formats YouTube supportés par media_embed

La gem gère nativement youtube.com/watch et youtu.be. Vérification nécessaire pour YouTube Shorts et Music.

### Test requis for Formats YouTube supportés par media_embed

Valider les formats suivants durant l'implémentation :

- `https://www.youtube.com/watch?v=VIDEO_ID` ✓
- `https://youtu.be/VIDEO_ID` ✓
- `https://www.youtube.com/shorts/VIDEO_ID` → à tester
- `https://music.youtube.com/watch?v=VIDEO_ID` → à tester

### Fallback

Si un format n'est pas supporté, afficher uniquement le lien (comportement actuel).

---

## 4. Performance et lazy loading

### Decision for Performance et lazy loading

Utiliser `loading="lazy"` natif du navigateur.

### Rationale for Performance et lazy loading

- Supporté par tous les navigateurs modernes (Chrome, Firefox, Safari, Edge)
- Pas de JavaScript custom nécessaire
- L'iframe ne charge que si visible dans le viewport

### Alternatives considérées for Performance et lazy loading

| Alternative | Raison du rejet |
| ----------- | --------------- |
| Intersection Observer JS | Over-engineering pour un cas simple |
| Placeholder image avant chargement | Complexité ajoutée sans bénéfice mesurable |

---

## 5. Placement du sélecteur joueur

### Decision for Placement du sélecteur joueur

Le sélecteur de joueur reste positionné après le bloc vidéo (lien + iframe si présente).

### Rationale for Placement du sélecteur joueur

- Ordre logique : voir la vidéo → deviner qui l'a proposée
- Pas de modification structurelle majeure de la vue existante
- L'iframe est insérée entre le lien et le sélecteur

### Layout résultant

```text
┌─────────────────────────────────┐
│ Proposition #1                  │
│ 🔗 https://youtube.com/...      │  ← Lien cliquable
│ ┌─────────────────────────────┐ │
│ │ [    iframe YouTube    ]    │ │  ← Nouvelle iframe
│ └─────────────────────────────┘ │
│ Qui a proposé cette musique ?   │  ← Sélecteur existant
│ ○ Alice  ○ Bob  ○ Charlie       │
└─────────────────────────────────┘
```

---

## Résumé des décisions

| Question | Décision |
| -------- | -------- |
| Gem d'embedding | `media_embed` v1.0.0 |
| Détection YouTube | `MediaEmbed::Handler#youtube?` |
| Génération iframe | `MediaEmbed::Handler#embed` + post-processing |
| Lazy loading | `loading="lazy"` natif |
| Accessibilité | `title="Lecteur vidéo YouTube"` |
| Responsive | Container `aspect-video` Tailwind |
| Autoplay | Désactivé (`autoplay: 0`) |
