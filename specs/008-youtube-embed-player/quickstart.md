# Quickstart: Lecteur YouTube Embarqué

**Feature**: 008-youtube-embed-player  
**Date**: 2026-02-14

## Prérequis

- Ruby 3.4.x
- Rails 8.1.2
- Bundler installé

## Installation rapide

### 1. Ajouter la gem

```ruby
# Gemfile
gem "media_embed", "~> 1.0"
```

```bash
bundle install
```

### 2. Créer le helper

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  include MediaEmbed::Handler

  def youtube_url?(url)
    return false if url.blank?
    youtube?(url)
  end

  def youtube_embed(url)
    return nil unless youtube_url?(url)
    
    html = embed(url, autoplay: 0, rel: 0, modestbranding: 1)
    
    # Ajouter lazy loading et accessibilité
    html = html.gsub(
      '<iframe',
      '<iframe loading="lazy" title="Lecteur vidéo YouTube" class="w-full h-full rounded-lg"'
    )
    
    html.html_safe
  end
end
```

### 3. Modifier la vue

```erb
<%# app/views/guesses/new.html.erb %>
<%# Dans la boucle @proposals.each %>

<div class="bg-dark-800/50 rounded-lg p-3 mb-4 border border-neon-cyan/20">
  <a href="<%= proposal.url %>" target="_blank" rel="noopener noreferrer" 
     class="neon-text-cyan hover:neon-text-pink transition-all duration-300 break-all flex items-center gap-2">
    <span>🔗</span>
    <span><%= proposal.url %></span>
  </a>
  
  <% if youtube_url?(proposal.url) %>
    <div class="aspect-video w-full mt-4">
      <%= youtube_embed(proposal.url) %>
    </div>
  <% end %>
</div>
```

## Vérification

### Test manuel

1. Démarrer le serveur : `bin/dev`
2. Créer une partie avec au moins 2 joueurs
3. Soumettre une proposition avec une URL YouTube
4. Passer en phase de devinette
5. Vérifier que l'iframe s'affiche sous le lien

### URLs de test

```text
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://www.youtube.com/shorts/abc123
```

### Test automatisé

```bash
bin/rails test test/helpers/application_helper_test.rb
bin/rails test:system test/system/guesses_test.rb
```

## Structure des fichiers modifiés

```text
Gemfile                              # + gem "media_embed"
app/helpers/application_helper.rb    # + youtube_url?, youtube_embed
app/views/guesses/new.html.erb       # + bloc iframe conditionnel
test/helpers/application_helper_test.rb  # nouveau
test/system/guesses_test.rb          # + tests iframe
```

## Troubleshooting

| Problème | Solution |
| -------- | ------- |
| `undefined method youtube?` | Vérifier que `bundle install` a été fait |
| Iframe ne s'affiche pas | Vérifier que l'URL est bien un format YouTube supporté |
| Vidéo démarre automatiquement | Vérifier que `autoplay: 0` est passé à `embed()` |
| Iframe pas responsive | Vérifier le container `aspect-video` Tailwind |
