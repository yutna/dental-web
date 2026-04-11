import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    this._onResize = this._handleResize.bind(this)
    window.addEventListener("resize", this._onResize)
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
  }

  toggle() {
    const sidebar = this.sidebarTarget
    const isOpen = !sidebar.classList.contains("-translate-x-full")
    isOpen ? this.close() : this.open()
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full")
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden", "lg:overflow-auto")
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden", "lg:overflow-auto")
  }

  _handleResize() {
    if (window.innerWidth >= 1024) {
      this.close()
    }
  }
}
