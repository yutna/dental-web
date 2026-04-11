import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "chartData", "detailPanel", "detailToothLabel", "detailRecords",
    "detailRecordsList", "detailEmpty", "toothInput"
  ]

  get charts() {
    if (!this._charts) {
      try {
        this._charts = JSON.parse(this.chartDataTarget.textContent)
      } catch {
        this._charts = []
      }
    }
    return this._charts
  }

  toothSelected(event) {
    const { selected } = event.detail
    if (!selected || selected.length === 0) {
      this.detailPanelTarget.classList.add("hidden")
      return
    }

    const toothId = selected[selected.length - 1]
    this.#showDetail(toothId)
    this.#autoFillEntry(toothId)
  }

  closeDetail() {
    this.detailPanelTarget.classList.add("hidden")
  }

  #showDetail(toothId) {
    this.detailToothLabelTarget.textContent = `#${toothId}`

    const records = this.charts.filter((c) => {
      return (c.tooth_code || c["tooth_code"]) === toothId
    })

    if (records.length > 0) {
      this.detailRecordsTarget.classList.remove("hidden")
      this.detailEmptyTarget.classList.add("hidden")
      this.detailRecordsListTarget.innerHTML = records.map((r) => {
        const code = r.charting_code || r["charting_code"] || ""
        const surfaces = Array.isArray(r.surface_codes || r["surface_codes"])
          ? (r.surface_codes || r["surface_codes"]).join(", ")
          : (r.surface_codes || r["surface_codes"] || "")
        const note = r.note || r["note"] || ""
        return `<div class="rounded-lg bg-app-surface-primary p-2 text-xs">
          <span class="font-medium text-app-text-primary">${this.#escapeHtml(code)}</span>
          ${surfaces ? `<span class="ml-2 text-app-text-secondary">${this.#escapeHtml(surfaces)}</span>` : ""}
          ${note ? `<span class="ml-2 text-app-text-tertiary">${this.#escapeHtml(note)}</span>` : ""}
        </div>`
      }).join("")
    } else {
      this.detailRecordsTarget.classList.add("hidden")
      this.detailEmptyTarget.classList.remove("hidden")
    }

    this.detailPanelTarget.classList.remove("hidden")
  }

  #autoFillEntry(toothId) {
    if (this.hasToothInputTarget) {
      this.toothInputTarget.value = toothId
      this.toothInputTarget.focus()
    }
  }

  #escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
