import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "frame", "skeleton" ]

  connect() {
    this.start = this.start.bind(this)
    this.finish = this.finish.bind(this)

    this.frameTarget.addEventListener("turbo:before-fetch-request", this.start)
    this.frameTarget.addEventListener("turbo:frame-load", this.finish)
  }

  disconnect() {
    this.frameTarget.removeEventListener("turbo:before-fetch-request", this.start)
    this.frameTarget.removeEventListener("turbo:frame-load", this.finish)
  }

  start() {
    this.skeletonTarget.classList.remove("hidden")
    this.frameTarget.classList.add("opacity-40", "pointer-events-none")
  }

  finish() {
    this.skeletonTarget.classList.add("hidden")
    this.frameTarget.classList.remove("opacity-40", "pointer-events-none")
  }
}
