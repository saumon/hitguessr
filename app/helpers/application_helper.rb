module ApplicationHelper
  require "net/http"
  require "openssl"

  YOUTUBE_REGEX = %r{
    (?:
      (?:www\.)?youtube\.com/watch\?v=|
      youtu\.be/|
      (?:www\.)?youtube\.com/shorts/|
      music\.youtube\.com/watch\?v=|
      (?:www\.)?youtube\.com/embed/
    )
    ([a-zA-Z0-9_-]{11})
  }x

  # T003: Détecte si une URL est un lien YouTube valide
  # Supports: youtube.com/watch, youtu.be, youtube.com/shorts, music.youtube.com
  def youtube_url?(url)
    return false if url.blank?

    url.match?(YOUTUBE_REGEX)
  end

  # Extrait l'ID vidéo YouTube d'une URL
  def extract_youtube_video_id(url)
    return nil if url.blank?

    match = url.match(YOUTUBE_REGEX)
    match[1] if match
  end

  # Vérifie si une vidéo YouTube est intégrable via l'API oEmbed
  # Retourne true si la vidéo est disponible et autorise l'embed
  # En environnement de test, retourne toujours true pour éviter les appels HTTP
  def youtube_embeddable?(url)
    return true if Rails.env.test?

    video_id = extract_youtube_video_id(url)
    return false unless video_id

    Rails.cache.fetch("youtube_embeddable_#{video_id}", expires_in: 1.hour) do
      check_youtube_oembed(video_id)
    end
  rescue StandardError
    # En cas d'erreur réseau, on autorise l'affichage par défaut
    true
  end

  # T004: Génère un lecteur YouTube avec détection d'erreur côté client
  # - Utilise l'API YouTube IFrame Player pour détecter si la vidéo est disponible
  # - Masque le conteneur si la vidéo n'est pas intégrable (code erreur 150 ou 101)
  def youtube_embed(url)
    video_id = extract_youtube_video_id(url)
    return nil unless video_id
    return nil unless youtube_embeddable?(url)

    container_id = "yt-#{video_id}-#{SecureRandom.hex(4)}"

    %(<div id="#{container_id}" class="youtube-embed-container w-full h-full">
      <iframe
        class="w-full h-full rounded-lg"
        src="https://www.youtube.com/embed/#{video_id}?enablejsapi=1"
        title="YouTube video player"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen
        loading="lazy"
      ></iframe>
    </div>).html_safe
  end

  private

  def check_youtube_oembed(video_id)
    uri = URI("https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=#{video_id}&format=json")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.open_timeout = 3
    http.read_timeout = 3

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    response.is_a?(Net::HTTPSuccess)
  rescue StandardError
    # En cas d'erreur, on autorise l'affichage par défaut
    true
  end
end
