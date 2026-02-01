# Research: Responsive Design

**Feature**: 005-responsive-design  
**Date**: 2026-02-01

## Résumé

Ce document consolide les recherches effectuées pour résoudre les points techniques identifiés dans la spécification responsive.

---

## 1. Breakpoints Tailwind CSS

**Décision** : Utiliser les breakpoints natifs Tailwind CSS v4 avec la convention mobile-first.

**Rationale** : Tailwind CSS utilise une approche **mobile-first** où :

- Les classes sans préfixe s'appliquent à toutes les tailles d'écran
- Les préfixes (`sm:`, `md:`, `lg:`, `xl:`) s'appliquent à partir du breakpoint spécifié et au-dessus

### Breakpoints par défaut (Tailwind v4)

| Préfixe | Largeur min | Cas d'usage |
| ------- | ----------- | ----------- |
| (aucun) | 0px | Mobile (base) |
| `sm:` | 640px (40rem) | Tablette portrait |
| `md:` | 768px (48rem) | Tablette paysage |
| `lg:` | 1024px (64rem) | Desktop |
| `xl:` | 1280px (80rem) | Desktop large |
| `2xl:` | 1536px (96rem) | Desktop très large |

### Mapping vers la spec

| Spec | Tailwind |
| ------ | -------- |
| Mobile (< 640px) | Classes sans préfixe |
| Tablette (640px - 1024px) | `sm:` et `md:` |
| Desktop (> 1024px) | `lg:` et au-delà |

**Alternatives considérées** :

- **Breakpoints custom** : Rejetés car les valeurs par défaut correspondent exactement aux besoins de la spec
- **Container queries** : Rejetés car le support navigateur n'est pas encore universel dans les 2 dernières versions

---

## 2. Pattern de navigation responsive

**Décision** : Garder la navigation visible en version simplifiée sur mobile (pas de menu hamburger).

**Rationale** : La navigation actuelle contient peu d'éléments :

- Logo/Accueil
- "Mes équipes"
- Nom utilisateur
- Bouton déconnexion

Ces éléments peuvent tenir sur une ligne mobile avec quelques ajustements :

- Masquer le nom utilisateur sur mobile (`hidden sm:inline`)
- Réduire les espacements (`space-x-2` au lieu de `space-x-4`)
- Réduire la taille du texte si nécessaire (`text-sm`)

**Alternatives considérées** :

- **Menu hamburger** : Rejeté car ajoute de la friction (2 taps au lieu de 1) et la navigation est déjà simple
- **Navigation en bas** : Rejeté car style app native peu adapté à une web app, et nécessite plus de travail

---

## 3. Support de prefers-reduced-motion

**Décision** : Utiliser la media query CSS native `prefers-reduced-motion: reduce`.

**Rationale** : Tailwind CSS supporte nativement cette préférence via le variant `motion-reduce:` et `motion-safe:` :

```html
<!-- Animation uniquement si l'utilisateur accepte les mouvements -->
<div class="motion-safe:animate-spin">

<!-- Style alternatif quand reduced motion est activé -->
<div class="motion-reduce:hidden">
```

Pour les animations CSS custom (équaliseur, effets néon), ajouter :

```css
@media (prefers-reduced-motion: reduce) {
  .equalizer-bar {
    animation: none;
    height: 12px; /* hauteur fixe au lieu d'animée */
  }
  
  .pulse-glow {
    animation: none;
  }
  
  .neon-border::before {
    animation: none;
  }
}
```

**Alternatives considérées** :

- **Toggle manuel** : Rejeté car ajoute de la complexité UI et ne respecte pas le choix système de l'utilisateur
- **Détection JavaScript** : Rejeté car CSS suffit et fonctionne même si JS est désactivé

---

## 4. Pattern tableaux vers cartes sur mobile

**Décision** : Transformer les tableaux de classement en cartes empilées sur mobile.

**Rationale** : Les tableaux HTML sont difficiles à rendre responsive. L'approche recommandée est de :

1. Utiliser des `<div>` avec classes Flexbox/Grid plutôt que `<table>`
2. Afficher en ligne sur desktop, en carte empilée sur mobile

```html
<!-- Pattern: Liste responsive -->
<div class="space-y-3">
  <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-4 rounded-lg bg-dark-700">
    <div class="flex items-center gap-3 mb-2 sm:mb-0">
      <span class="text-2xl">🥇</span>
      <span class="font-medium">Nom du joueur</span>
    </div>
    <div class="text-right sm:text-left">
      <span class="text-2xl font-bold">42</span>
      <span class="text-sm text-gray-500">pts</span>
    </div>
  </div>
</div>
```

**Alternatives considérées** :

- **Défilement horizontal** : Rejeté car mauvaise UX sur tactile et viole FR-003
- **Colonnes prioritaires** : Considéré mais les cartes sont plus lisibles et plus cohérentes avec le design

---

## 5. Zones tactiles minimales (44x44px)

**Décision** : Appliquer `min-h-11 min-w-11` (44px) aux éléments interactifs sur mobile.

**Rationale** : La recommandation WCAG et Apple HIG est de 44x44px minimum pour les cibles tactiles. En Tailwind :

- `h-11` = 44px (2.75rem)
- `w-11` = 44px (2.75rem)
- `p-3` = 12px padding → élément de 24px de contenu + 24px padding = ~48px

Pour les boutons existants, vérifier que le padding total atteint au moins 44px de zone cliquable.

### Implémentation des zones tactiles

```html
<!-- Bouton avec zone tactile suffisante -->
<button class="px-4 py-3 min-h-11">Action</button>

<!-- Lien avec zone tactile étendue -->
<a class="inline-flex items-center justify-center min-h-11 min-w-11 p-2">
  Lien
</a>
```

---

## 6. Prévention du défilement horizontal

**Décision** : Utiliser `overflow-x-hidden` sur le body et `max-w-full` sur les conteneurs.

**Rationale** : Le défilement horizontal involontaire est causé par :

1. Éléments avec largeur fixe dépassant l'écran
2. Images/médias non contraints
3. Conteneurs avec padding mal calculé

### Implémentation CSS overflow

```css
/* Dans application.css */
body {
  overflow-x: hidden;
}

/* Pour les images */
img {
  max-width: 100%;
  height: auto;
}
```

### Implémentation HTML overflow

```html
<!-- Conteneurs -->
<div class="max-w-full overflow-hidden">
  <!-- contenu -->
</div>

<!-- URLs longues -->
<a class="break-all">https://very-long-url...</a>
```

---

## 7. Stratégie de test responsive

**Décision** : System tests Rails avec Capybara et configuration de viewport.

**Rationale** : Les system tests permettent de tester l'UI dans un vrai navigateur (Chrome headless) avec différentes tailles d'écran.

### Helpers de viewport

```ruby
# test/application_system_test_case.rb
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  def resize_to_mobile
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE
  end

  def resize_to_tablet
    page.driver.browser.manage.window.resize_to(768, 1024) # iPad
  end

  def resize_to_desktop
    page.driver.browser.manage.window.resize_to(1440, 900) # Desktop
  end
end
```

### Exemple de test responsive

```ruby
# test/system/responsive_test.rb
class ResponsiveTest < ApplicationSystemTestCase
  test "navigation is accessible on mobile" do
    resize_to_mobile
    visit root_path
    
    assert_no_horizontal_scroll
    assert_selector "a", text: "HitGuessr"
  end
  
  private
  
  def assert_no_horizontal_scroll
    scroll_width = page.evaluate_script("document.documentElement.scrollWidth")
    client_width = page.evaluate_script("document.documentElement.clientWidth")
    assert scroll_width <= client_width, "Horizontal scroll detected"
  end
end
```

---

## Checklist des fichiers à modifier

| Fichier | Modifications nécessaires |
| ------- | ------------------------ |
| `app/assets/tailwind/application.css` | Ajouter media queries prefers-reduced-motion |
| `app/views/layouts/application.html.erb` | Optimiser navigation mobile, overflow-x |
| `app/views/home/index.html.erb` | Vérifier responsive |
| `app/views/games/show.html.erb` | Vérifier responsive |
| `app/views/games/_collecting.html.erb` | Adapter cartes propositions |
| `app/views/games/_guessing.html.erb` | Adapter cartes devinettes |
| `app/views/results/show.html.erb` | Transformer tableaux en cartes |
| `app/views/teams/*.html.erb` | Vérifier responsive |
| `test/system/responsive_test.rb` | Créer tests multi-viewport |
