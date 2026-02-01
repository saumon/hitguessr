# Documentation des Patterns Responsive - HitGuessr

## Vue d'ensemble

Cette documentation décrit les patterns responsive implémentés dans HitGuessr pour assurer une expérience utilisateur optimale sur tous les appareils (mobile, tablette, desktop).

## Breakpoints Utilisés

| Préfixe Tailwind | Largeur | Usage |
|------------------|---------|-------|
| (aucun) | 0-639px | Mobile (approche mobile-first) |
| `sm:` | 640px+ | Tablette petite |
| `md:` | 768px+ | Tablette |
| `lg:` | 1024px+ | Desktop |
| `xl:` | 1280px+ | Desktop large |

## Patterns Implémentés

### 1. Touch Targets (Zones tactiles)

**Règle**: Tous les éléments interactifs ont une taille minimale de 44x44px.

```erb
<!-- Exemple: Bouton avec min-h-11 (44px) -->
<%= f.submit "Action", class: "btn-neon btn-primary min-h-11" %>

<!-- Exemple: Lien de navigation -->
<%= link_to "Mes équipes", teams_path, class: "min-h-11 inline-flex items-center" %>
```

### 2. Layouts Flexibles

**Pattern flex-col → sm:flex-row**: Empiler verticalement sur mobile, horizontal sur tablette+

```erb
<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
  <div class="mb-2 sm:mb-0">Contenu gauche</div>
  <div>Contenu droite</div>
</div>
```

### 3. Espacements Responsifs

**Pattern p-3 sm:p-4 ou p-4 sm:p-6**: Réduire le padding sur mobile

```erb
<div class="neon-border p-4 sm:p-8">
  <!-- Contenu avec moins de padding sur mobile -->
</div>
```

### 4. Tailles de Texte Responsives

**Pattern text-xl sm:text-2xl**: Texte plus petit sur mobile

```erb
<h1 class="text-xl sm:text-2xl font-bold">Titre</h1>
<p class="text-sm sm:text-base">Paragraphe</p>
```

### 5. Visibilité Conditionnelle

**Pattern hidden sm:inline ou hidden sm:flex**: Masquer sur mobile, afficher sur tablette+

```erb
<!-- Élément masqué sur mobile -->
<span class="hidden sm:inline">Texte desktop seulement</span>

<!-- Equalizer masqué sur mobile -->
<div class="equalizer hidden sm:flex">
  <!-- bars -->
</div>
```

### 6. Grilles Responsives

**Pattern grid-cols-1 md:grid-cols-3**: Une colonne sur mobile, trois sur tablette+

```erb
<div class="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-6">
  <div>Carte 1</div>
  <div>Carte 2</div>
  <div>Carte 3</div>
</div>
```

### 7. Largeurs Maximales

**Pattern max-w-4xl mx-auto**: Centrer et limiter la largeur sur grands écrans

```erb
<div class="max-w-4xl mx-auto px-4">
  <!-- Contenu centré avec largeur limitée -->
</div>
```

### 8. Tableaux → Cartes

Pour les données tabulaires sur mobile, utiliser des cartes empilées au lieu de tableaux :

```erb
<div class="space-y-3">
  <% items.each do |item| %>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-4 bg-dark-800 rounded-lg">
      <div class="mb-2 sm:mb-0 font-medium"><%= item.name %></div>
      <div class="text-sm text-gray-400"><%= item.value %></div>
    </div>
  <% end %>
</div>
```

## Accessibilité Motion

**Respect de prefers-reduced-motion**:

```css
@media (prefers-reduced-motion: reduce) {
  .equalizer-bar,
  .pulse-glow,
  .vinyl-spin,
  .neon-border::before,
  .music-bg::before,
  .music-bg::after {
    animation: none !important;
  }
  
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Prévention du Scroll Horizontal

```css
body {
  overflow-x: hidden;
}

img {
  max-width: 100%;
  height: auto;
}
```

## Fichiers Modifiés

### CSS
- `app/assets/tailwind/application.css` - Ajout prefers-reduced-motion et overflow-x-hidden

### Layouts
- `app/views/layouts/application.html.erb` - Header, main et footer responsifs

### Views
- `app/views/home/index.html.erb` - Page d'accueil responsive
- `app/views/teams/index.html.erb` - Liste des équipes
- `app/views/teams/show.html.erb` - Page équipe avec leaderboard
- `app/views/games/show.html.erb` - Page de jeu
- `app/views/games/_collecting.html.erb` - Phase collecte
- `app/views/games/_guessing.html.erb` - Phase devinettes
- `app/views/games/_finished.html.erb` - Phase terminée
- `app/views/results/show.html.erb` - Page résultats
- `app/views/proposals/new.html.erb` - Formulaire proposition
- `app/views/proposals/show.html.erb` - Affichage proposition

### Devise
- `app/views/devise/sessions/new.html.erb` - Connexion
- `app/views/devise/registrations/new.html.erb` - Inscription
- `app/views/devise/registrations/edit.html.erb` - Profil
- `app/views/devise/passwords/new.html.erb` - Mot de passe oublié
- `app/views/devise/passwords/edit.html.erb` - Nouveau mot de passe
- `app/views/devise/confirmations/new.html.erb` - Confirmation
- `app/views/devise/unlocks/new.html.erb` - Déverrouillage
- `app/views/devise/shared/_links.html.erb` - Liens partagés
- `app/views/devise/shared/_error_messages.html.erb` - Messages d'erreur

### Tests
- `test/application_system_test_case.rb` - Helpers viewport
- `test/system/responsive_navigation_test.rb` - Tests US1
- `test/system/responsive_game_test.rb` - Tests US2
- `test/system/responsive_desktop_test.rb` - Tests US3
- `test/system/responsive_transitions_test.rb` - Tests US4

## Validation Manuelle

### Points de vérification

1. **Mobile (375x667)** - iPhone SE
   - [ ] Pas de scroll horizontal
   - [ ] Navigation accessible
   - [ ] Touch targets ≥ 44px
   - [ ] Texte lisible

2. **Tablette (768x1024)** - iPad
   - [ ] Layout adapté
   - [ ] Formulaires utilisables
   - [ ] Grilles multi-colonnes

3. **Desktop (1440x900)**
   - [ ] Contenu centré
   - [ ] Largeur max respectée
   - [ ] Hover effects fonctionnels

### Outils de test

- Chrome DevTools (Cmd+Option+I → Cmd+Shift+M)
- Safari Responsive Design Mode
- Firefox Responsive Design Mode

## Notes Techniques

1. **Mobile-first**: Les styles de base s'appliquent au mobile, les breakpoints ajoutent des styles pour les écrans plus grands.

2. **Tailwind CSS 4.x**: Utilisation de la syntaxe @theme pour les couleurs personnalisées.

3. **min-h-11**: Classe Tailwind pour 44px (11 × 4px = 44px), conforme aux guidelines WCAG pour les zones tactiles.

4. **Transitions fluides**: Les changements de viewport ne causent pas de layout shift grâce à l'utilisation de flexbox et CSS Grid.
