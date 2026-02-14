# Quickstart: Responsive Design

**Feature**: 005-responsive-design  
**Date**: 2026-02-01

## Objectif

Rendre l'interface HitGuessr utilisable sur tous les appareils (mobile, tablette, desktop).

## Prérequis

- Ruby 3.x avec Rails 8.1.2
- Node.js (pour Tailwind CSS build)
- Navigateur moderne pour les tests

## Démarrage rapide

```bash
# Installer les dépendances
bundle install

# Lancer le serveur de dev avec compilation Tailwind
bin/dev

# Accéder à l'application
open http://localhost:3000
```

## Test responsive manuel

### Chrome DevTools

1. Ouvrir DevTools (`Cmd+Option+I` sur Mac)
2. Activer le mode responsive (`Cmd+Shift+M`)
3. Sélectionner un appareil ou définir une taille custom :
   - Mobile : 375x667 (iPhone SE)
   - Tablette : 768x1024 (iPad)
   - Desktop : 1440x900

### Points de vérification

- [ ] Pas de défilement horizontal sur aucune page
- [ ] Navigation accessible sur mobile
- [ ] Formulaires utilisables au touch
- [ ] Texte lisible (≥16px)
- [ ] Zones tactiles suffisantes (≥44x44px)

## Tests automatisés

```bash
# Lancer les tests système responsive
rails test:system TEST=test/system/responsive_test.rb

# Lancer tous les tests système
rails test:system
```

## Structure des breakpoints

| Préfixe Tailwind | Largeur | Usage |
|------------------|---------|-------|
| (aucun) | 0+ | Mobile (base) |
| `sm:` | 640px+ | Tablette |
| `md:` | 768px+ | Tablette large |
| `lg:` | 1024px+ | Desktop |
| `xl:` | 1280px+ | Desktop large |

## Patterns utilisés

### Navigation simplifiée mobile

```erb
<!-- Élément visible seulement sur sm: et plus -->
<span class="hidden sm:inline">Texte desktop</span>

<!-- Espacement réduit sur mobile -->
<nav class="flex items-center space-x-2 sm:space-x-4">
```

### Cartes empilées (tableaux responsive)

```erb
<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-4">
  <div class="mb-2 sm:mb-0">Contenu gauche</div>
  <div>Contenu droite</div>
</div>
```

### Respect de prefers-reduced-motion

```css
@media (prefers-reduced-motion: reduce) {
  .animated-element {
    animation: none;
  }
}
```

## Vérification CLS (Cumulative Layout Shift)

1. Ouvrir Chrome DevTools
2. Aller dans l'onglet "Performance"
3. Cliquer sur "Start profiling and reload page"
4. Chercher "Layout Shift" dans les résultats
5. CLS doit être < 0.1

## Ressources

- [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [WCAG Touch Target Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/target-size.html)
- [Web Vitals - CLS](https://web.dev/cls/)
