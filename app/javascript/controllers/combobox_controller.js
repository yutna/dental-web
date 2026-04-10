import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "hiddenInput", "menu", "option" ]

  connect() {
    this.close()
  }

  open() {
    this.menuTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()

    this.optionTargets.forEach((option) => {
      const label = option.dataset.label.toLowerCase()
      option.classList.toggle("hidden", query.length > 0 && !label.includes(query))
    })

    this.open()
  }

  select(event) {
    const option = event.currentTarget
    this.hiddenInputTarget.value = option.dataset.value
    this.inputTarget.value = option.dataset.label
    this.close()
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
      this.inputTarget.blur()
    }
  }

  closeOnOutsideClick(event) {
    if (this.element.contains(event.target)) return

    this.close()
  }
}
