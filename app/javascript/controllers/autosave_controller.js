import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "indicator"]
  static values = {
    formId: String
  }

  connect() {
    this.form = this.resolveForm()
    if (!this.form) return

    this.boundMarkDirty = this.markDirty.bind(this)
    this.boundMarkClean = this.markClean.bind(this)

    this.form.addEventListener("input", this.boundMarkDirty)
    this.form.addEventListener("change", this.boundMarkDirty)
    this.form.addEventListener("submit", this.boundMarkClean)
    this.form.addEventListener("reset", this.boundMarkClean)
  }

  disconnect() {
    if (!this.form) return

    this.form.removeEventListener("input", this.boundMarkDirty)
    this.form.removeEventListener("change", this.boundMarkDirty)
    this.form.removeEventListener("submit", this.boundMarkClean)
    this.form.removeEventListener("reset", this.boundMarkClean)
  }

  markDirty() {
    this.indicatorTargets.forEach((el, index) => {
      if (index === 0) {
        el.hidden = false
      } else {
        el.classList.add("hidden")
      }
    })
  }

  markClean() {
    this.indicatorTargets.forEach((el, index) => {
      if (index === 0) {
        el.hidden = true
      } else {
        el.classList.remove("hidden")
      }
    })
  }

  // ---- private ----

  resolveForm() {
    if (this.hasFormIdValue && this.formIdValue) {
      return document.getElementById(this.formIdValue)
    }

    return this.element.closest("form")
  }
}
