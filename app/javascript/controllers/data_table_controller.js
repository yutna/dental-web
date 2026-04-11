import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row"]

  sort(event) {
    const { keyParam, dirParam } = event.params

    // If the table lives inside a Turbo frame with a filter form,
    // delegate sorting to the server via hidden inputs + form submission.
    const form = this.element.closest("[data-controller='filter-bar']")
                 ?.querySelector("form")

    if (form) {
      this.setHiddenInput(form, "sort_key", keyParam)
      this.setHiddenInput(form, "sort_dir", dirParam)
      form.requestSubmit()
      return
    }

    // Fallback: client-side sort by text content
    this.clientSort(keyParam, dirParam)
  }

  // ---- private ----

  clientSort(key, dir) {
    const tbody = this.element.querySelector("tbody")
    if (!tbody) return

    const rows = Array.from(this.rowTargets)
    const headers = Array.from(this.element.querySelectorAll("thead th"))
    const colIndex = headers.findIndex((th) => {
      const btn = th.querySelector("[data-data-table-key-param]")
      return btn && btn.dataset.dataTableKeyParam === key
    })

    if (colIndex < 0) return

    rows.sort((a, b) => {
      const aText = a.children[colIndex]?.textContent.trim() ?? ""
      const bText = b.children[colIndex]?.textContent.trim() ?? ""

      const aNum = parseFloat(aText)
      const bNum = parseFloat(bText)
      const numeric = !isNaN(aNum) && !isNaN(bNum)

      const cmp = numeric
        ? aNum - bNum
        : aText.localeCompare(bText, undefined, { sensitivity: "base" })

      return dir === "desc" ? -cmp : cmp
    })

    rows.forEach((row) => tbody.appendChild(row))
  }

  setHiddenInput(form, name, value) {
    let input = form.querySelector(`input[name="${name}"]`)

    if (!input) {
      input = document.createElement("input")
      input.type = "hidden"
      input.name = name
      form.appendChild(input)
    }

    input.value = value
  }
}
