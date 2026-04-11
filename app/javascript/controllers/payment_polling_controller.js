import { Turbo } from "@hotwired/turbo-rails"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 30000 }
  }

  connect() {
    this.tick = this.tick.bind(this)
    this.start()
  }

  disconnect() {
    this.stop()
  }

  start() {
    this.stop()
    this.timer = window.setInterval(this.tick, this.intervalValue)
  }

  stop() {
    if (!this.timer) return
    window.clearInterval(this.timer)
    this.timer = null
  }

  tick() {
    if (document.visibilityState !== "visible") return
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
