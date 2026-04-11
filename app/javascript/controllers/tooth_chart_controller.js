import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chart", "input", "summary"]
  static values = {
    multiSelect: { type: Boolean, default: true },
    readOnly: { type: Boolean, default: false },
    selected: { type: Array, default: [] },
    conditions: { type: Object, default: {} }
  }

  connect() {
    this.handleToothClick = this.selectTooth.bind(this)
    this.applyConditions()
    this.applySelected()
    this.bindToothClicks()
  }

  disconnect() {
    this.toothElements().forEach((el) => {
      el.removeEventListener("click", this.handleToothClick)
    })
  }

  // ---- actions ----

  selectTooth(event) {
    if (this.readOnlyValue) return

    const toothEl = event.currentTarget
    const toothId = toothEl.dataset.tooth
    if (!toothId) return

    const selected = [...this.selectedValue]
    const index = selected.indexOf(toothId)

    if (index >= 0) {
      selected.splice(index, 1)
      toothEl.classList.remove("selected")
    } else {
      if (!this.multiSelectValue) {
        // Deselect all others
        this.toothElements().forEach((el) => el.classList.remove("selected"))
        selected.length = 0
      }
      selected.push(toothId)
      toothEl.classList.add("selected")
    }

    this.selectedValue = selected
    this.syncInput()
    this.updateSummary()
    this.dispatch("change", { detail: { selected } })
  }

  // ---- private ----

  bindToothClicks() {
    this.toothElements().forEach((el) => {
      el.addEventListener("click", this.handleToothClick)
    })
  }

  toothElements() {
    return this.chartTarget.querySelectorAll("[data-tooth]")
  }

  applyConditions() {
    const conditions = this.conditionsValue
    Object.entries(conditions).forEach(([toothId, condition]) => {
      const el = this.chartTarget.querySelector(`[data-tooth="${toothId}"]`)
      if (!el) return

      // Remove any existing condition class
      el.classList.remove("condition-treated", "condition-planned", "condition-problematic", "condition-missing")

      const cls = `condition-${condition}`
      el.classList.add(cls)
    })
  }

  applySelected() {
    this.selectedValue.forEach((toothId) => {
      const el = this.chartTarget.querySelector(`[data-tooth="${toothId}"]`)
      if (el) el.classList.add("selected")
    })
  }

  syncInput() {
    if (!this.hasInputTarget) return
    this.inputTarget.value = this.selectedValue.join(",")
  }

  updateSummary() {
    if (!this.hasSummaryTarget) return

    const selected = this.selectedValue
    if (selected.length === 0) {
      this.summaryTarget.textContent = ""
    } else {
      this.summaryTarget.textContent = `${selected.length} selected: ${selected.join(", ")}`
    }
  }
}
