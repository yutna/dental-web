import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button", "menu", "announcement" ]
  static values = {
    themeSavedMessage: String
  }

  connect() {
    this.boundHandleOutsideClick = this.handleOutsideClick.bind(this)
    this.boundThemeChanged = this.themeChanged.bind(this)
    document.addEventListener("click", this.boundHandleOutsideClick)
    document.addEventListener("theme:changed", this.boundThemeChanged)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleOutsideClick)
    document.removeEventListener("theme:changed", this.boundThemeChanged)
    clearTimeout(this.announcementTimeout)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.isOpen()) {
      this.close()
      return
    }

    this.open()
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")

    const first = this.menuItems()[0]
    if (first) first.focus()
  }

  close({ focusButton = true } = {}) {
    if (!this.isOpen()) return

    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    if (focusButton) this.buttonTarget.focus()
  }

  onMenuKeydown(event) {
    if (!this.isOpen()) return

    const items = this.menuItems()
    if (items.length === 0) return

    const currentIndex = items.indexOf(document.activeElement)

    if (event.key === "ArrowDown") {
      event.preventDefault()
      const nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % items.length
      items[nextIndex].focus()
      return
    }

    if (event.key === "ArrowUp") {
      event.preventDefault()
      const prevIndex = currentIndex < 0 ? items.length - 1 : (currentIndex - 1 + items.length) % items.length
      items[prevIndex].focus()
      return
    }

    if (event.key === "Home") {
      event.preventDefault()
      items[0].focus()
      return
    }

    if (event.key === "End") {
      event.preventDefault()
      items[items.length - 1].focus()
    }
  }

  keepOpen(event) {
    event.stopPropagation()
  }

  handleOutsideClick(event) {
    if (this.element.contains(event.target)) return
    this.close({ focusButton: false })
  }

  themeChanged(event) {
    if (!this.hasAnnouncementTarget) return

    this.announcementTarget.textContent = this.themeSavedMessageValue || event.detail.mode
    this.announcementTarget.classList.remove("hidden")

    clearTimeout(this.announcementTimeout)
    this.announcementTimeout = setTimeout(() => {
      this.announcementTarget.classList.add("hidden")
    }, 1800)
  }

  isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  menuItems() {
    return Array.from(this.menuTarget.querySelectorAll("a[href], button:not([disabled]), input:not([disabled])"))
  }
}
