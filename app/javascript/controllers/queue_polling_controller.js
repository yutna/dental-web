import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "filtersForm" ]
  static values = {
    frame: String,
    interval: { type: Number, default: 30000 }
  }

  connect() {
    this.poll = this.poll.bind(this)
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.stopPolling()
    this.intervalId = window.setInterval(this.poll, this.intervalValue)
  }

  stopPolling() {
    if (!this.intervalId) {
      return
    }

    window.clearInterval(this.intervalId)
    this.intervalId = null
  }

  poll() {
    if (document.visibilityState !== "visible") {
      return
    }

    const url = new URL(this.filtersFormTarget.action, window.location.origin)
    const data = new FormData(this.filtersFormTarget)

    for (const [key, value] of data.entries()) {
      if (!value) {
        continue
      }

      url.searchParams.set(key, value)
    }

    url.searchParams.set("queue_only", "1")

    const frame = document.getElementById(this.frameValue)
    if (frame) {
      frame.src = url.toString()
    }
  }
}
