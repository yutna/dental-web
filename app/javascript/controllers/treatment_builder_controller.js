import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowTemplate", "rowsBody", "rowCount", "notes", "selectedProcedure"]

  nextRowIndex = 0

  connect() {
    this.nextRowIndex = this.rowsBodyTarget.querySelectorAll("tr[data-row-index]").length
  }

  addRow(event) {
    event.preventDefault()
    this.#insertRow()
  }

  addFromSearch(event) {
    const option = event.currentTarget
    const code = option.dataset.value
    const price = option.dataset.price
    const row = this.#insertRow()
    if (row) {
      const codeInput = row.querySelector("input[name*='procedure_item_code']")
      const priceInput = row.querySelector("input[name*='price']")
      if (codeInput) codeInput.value = code
      if (priceInput && price) priceInput.value = price
    }
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.target.closest("tr[data-row-index]")
    if (row) {
      row.remove()
      this.#updateRowCount()
    }
  }

  #insertRow() {
    const index = this.nextRowIndex++
    const html = this.rowTemplateTarget.innerHTML.replace(/__INDEX__/g, index)
    this.rowsBodyTarget.insertAdjacentHTML("beforeend", html)
    this.#updateRowCount()

    const newRow = this.rowsBodyTarget.querySelector(`tr[data-row-index="${index}"]`)
    if (newRow) {
      const firstInput = newRow.querySelector("input")
      if (firstInput) firstInput.focus()
    }
    return newRow
  }

  #updateRowCount() {
    if (this.hasRowCountTarget) {
      const count = this.rowsBodyTarget.querySelectorAll("tr[data-row-index]").length
      this.rowCountTarget.textContent = count
    }
  }
}
