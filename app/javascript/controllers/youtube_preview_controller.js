import { Controller } from "@hotwired/stimulus"

// Contrôleur pour la prévisualisation YouTube en temps réel
// Met à jour l'iframe lorsque l'utilisateur modifie l'URL dans le formulaire de proposition.
// Compatible avec les URLs : youtube.com/watch, youtu.be, youtube.com/shorts, music.youtube.com

const YOUTUBE_REGEX = /(?:(?:www\.)?youtube\.com\/watch\?v=|youtu\.be\/|(?:www\.)?youtube\.com\/shorts\/|music\.youtube\.com\/watch\?v=|(?:www\.)?youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})/

export default class extends Controller {
  static targets = ["input", "preview", "iframe"]

  connect() {
    this._update(this.inputTarget.value)
  }

  handleInput() {
    this._update(this.inputTarget.value)
  }

  _update(url) {
    const videoId = this._extractVideoId(url)
    if (videoId) {
      const src = `https://www.youtube.com/embed/${videoId}?enablejsapi=1`
      if (this.iframeTarget.src !== src) {
        this.iframeTarget.src = src
      }
      this.previewTarget.hidden = false
    } else {
      this.previewTarget.hidden = true
      this.iframeTarget.src = ""
    }
  }

  _extractVideoId(url) {
    if (!url) return null
    const match = url.match(YOUTUBE_REGEX)
    return match ? match[1] : null
  }
}
