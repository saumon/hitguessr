// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// YouTube IFrame API - Détection des vidéos non disponibles
window.onYouTubeIframeAPIReady = function() {
  document.querySelectorAll('.youtube-embed-container iframe').forEach(function(iframe) {
    const videoId = iframe.src.match(/embed\/([a-zA-Z0-9_-]{11})/)?.[1];
    if (!videoId) return;
    
    const containerId = iframe.parentElement.id;
    
    new YT.Player(iframe, {
      events: {
        'onError': function(event) {
          // Code 150 ou 101 = embed désactivé par le propriétaire
          // Code 2 = vidéo non trouvée
          if (event.data === 150 || event.data === 101 || event.data === 2) {
            const container = document.getElementById(containerId);
            if (container) {
              // Masquer le conteneur youtube-embed-container
              container.style.display = 'none';
              // Masquer aussi le conteneur parent (aspect-video)
              const aspectVideoParent = container.closest('.aspect-video');
              if (aspectVideoParent) {
                aspectVideoParent.style.display = 'none';
              }
            }
          }
        }
      }
    });
  });
};

// Charger l'API YouTube IFrame
document.addEventListener('turbo:load', function() {
  if (document.querySelector('.youtube-embed-container') && !window.YT) {
    const tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    const firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  } else if (window.YT && window.YT.Player) {
    window.onYouTubeIframeAPIReady();
  }
});
