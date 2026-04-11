import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  open() {
    this.panelTarget.classList.remove("hidden")
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    requestAnimationFrame(() => {
      this.panelTarget.querySelector("[data-modal-content]")?.classList.remove("scale-95", "opacity-0")
      this.panelTarget.querySelector("[data-modal-content]")?.classList.add("scale-100", "opacity-100")
    })
  }

  close() {
    const content = this.panelTarget.querySelector("[data-modal-content]")
    if (content) {
      content.classList.remove("scale-100", "opacity-100")
      content.classList.add("scale-95", "opacity-0")
    }
    setTimeout(() => {
      this.panelTarget.classList.add("hidden")
      this.backdropTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 150)
  }

  closeOnEsc(event) {
    if (event.key === "Escape") this.close()
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }
}
