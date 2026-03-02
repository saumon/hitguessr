import { Controller } from "@hotwired/stimulus"

// Contrôleur Stimulus pour la détection et l'avertissement de doublons de proposition
// Feature 013 — Alerte de doublon de proposition
//
// Algorithme: détection client-only par égalité stricte de guessed_author_id.
// DuplicateWarningState: { has_duplicates, groups, affected_proposal_ids }
export default class extends Controller {
  static targets = ["row", "indicator", "modal", "modalList"]

  connect() {
    // Marquer le contrôleur comme prêt (utilisé par les tests système pour attendre l'initialisation)
    this.element.dataset.controllerReady = "true"
  }

  disconnect() {
    delete this.element.dataset.controllerReady
  }

  // US1 — Écoute les changements de radio et recalcule l'état
  handleChange() {
    this._update()
  }

  // US2 — Intercepte le click sur le bouton submit (avant que Turbo ne traite le form submit)
  // En interceptant au niveau du click sur le bouton, on s'exécute avant l'event submit
  // que Turbo intercepte en phase de capture sur le document.
  // Toujours prévenir le comportement par défaut pour contrôler la soumission.
  interceptSubmit(event) {
    event.preventDefault()
    event.stopImmediatePropagation()

    const state = this._computeState()
    if (state.has_duplicates) {
      this._renderModal(state)
      this._openModal()
    } else {
      // Pas de doublons : soumettre le formulaire via Turbo normalement
      this.element.requestSubmit()
    }
  }

  // US3 — Ferme la modal sans soumettre (Annuler)
  cancelSubmit() {
    this._closeModal()
  }

  // US3 — Confirme et soumet malgré les doublons (Confirmer)
  confirmSubmit() {
    this._closeModal()
    // requestSubmit() déclenche l'event 'submit' sur le form (géré par Turbo),
    // pas un click sur le bouton — donc interceptSubmit n'est PAS rappelé
    this.element.requestSubmit()
  }

  // — Méthodes privées —

  // Recalcule l'état et met à jour les indicateurs inline
  _update() {
    const state = this._computeState()
    this._updateIndicators(state)
  }

  // Calcule le DuplicateWarningState à partir des sélections radio courantes
  _computeState() {
    const groups = {}

    this.rowTargets.forEach(row => {
      const proposalId = row.dataset.proposalId
      const radio = row.querySelector("input[type='radio']:checked")
      if (!radio) return

      const authorId = radio.value
      const label = radio.closest("label")
      const authorName = label
        ? (label.querySelector("span:last-child")?.textContent?.trim() || authorId)
        : authorId

      if (!groups[authorId]) {
        groups[authorId] = {
          guessed_author_id: authorId,
          guessed_author_name: authorName,
          proposal_ids: [],
          count: 0
        }
      }
      groups[authorId].proposal_ids.push(proposalId)
      groups[authorId].count++
    })

    const duplicateGroups = Object.values(groups).filter(g => g.count >= 2)
    const affectedIds = new Set(duplicateGroups.flatMap(g => g.proposal_ids))

    return {
      has_duplicates: duplicateGroups.length > 0,
      groups: duplicateGroups,
      affected_proposal_ids: affectedIds
    }
  }

  // Met à jour la visibilité des indicateurs inline selon l'état
  _updateIndicators(state) {
    this.rowTargets.forEach(row => {
      const proposalId = row.dataset.proposalId
      const indicator = row.querySelector("[data-guess-duplicates-target='indicator']")
      if (!indicator) return

      if (state.affected_proposal_ids.has(proposalId)) {
        indicator.classList.remove("hidden")
      } else {
        indicator.classList.add("hidden")
      }
    })
  }

  // Construit le contenu de la modal avec la liste détaillée des doublons
  _renderModal(state) {
    const list = this.modalListTarget
    list.innerHTML = ""

    state.groups.forEach(group => {
      const li = document.createElement("li")
      const propNums = group.proposal_ids.map(id => {
        const idx = this.rowTargets.findIndex(r => r.dataset.proposalId === id)
        return idx >= 0 ? `#${idx + 1}` : "#?"
      })
      li.textContent = `${group.guessed_author_name} — Propositions ${propNums.join(", ")}`
      li.className = "text-yellow-400"
      list.appendChild(li)
    })
  }

  _openModal() {
    this.modalTarget.classList.remove("hidden")
    const confirmBtn = this.modalTarget.querySelector("[data-testid='duplicate-modal-confirm']")
    confirmBtn?.focus()
  }

  _closeModal() {
    this.modalTarget.classList.add("hidden")
  }
}
