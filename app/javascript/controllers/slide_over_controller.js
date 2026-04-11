import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  open() {
    this.panelTarget.classList.remove("hidden")
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    requestAnimationFrame(() => {
      const content = this.panelTarget.querySelector("[data-slide-content]")
      if (content) {
        content.classList.remove("translate-x-full", "-translate-x-full")
      }
    })
  }

  close() {
    const content = this.panelTarget.querySelector("[data-slide-content]")
    if (content) {
      const isLeft = content.closest("[data-slide-content]")?.parentElement?.classList.contains("left-0")
      content.classList.add(isLeft ? "-translate-x-full" : "translate-x-full")
    }
    setTimeout(() => {
      this.panelTarget.classList.add("hidden")
      this.backdropTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 200)
  }

  closeOnEsc(event) {
    if (event.key === "Escape") this.close()
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }
}
