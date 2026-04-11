import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "search"]

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
  }

  submit() {
    this.formTarget.requestSubmit()
  }

  debounceSubmit() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.submit(), 300)
  }

  reset() {
    this.formTarget.reset()

    // Clear all inputs explicitly for search and select elements
    this.formTarget.querySelectorAll("input[type='search'], input[type='text']").forEach((input) => {
      input.value = ""
    })

    this.formTarget.querySelectorAll("select").forEach((select) => {
      select.selectedIndex = 0
    })

    // Remove dynamic hidden inputs (sort params)
    this.formTarget.querySelectorAll("input[type='hidden'][name='sort_key'], input[type='hidden'][name='sort_dir']").forEach((input) => {
      input.remove()
    })

    this.submit()
  }
}
