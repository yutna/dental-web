import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toast", "progress"]
  static values = {
    defaultDuration: Number,
    maxVisible: Number,
    swipeThreshold: Number,
  }

  connect() {
    this.toastState = new WeakMap()
    this.touchState = new WeakMap()
    this.queue = []

    this.toastTargets.forEach((toast, index) => {
      if (index < this.maxVisibleCount) {
        this.startToast(toast)
      } else {
        toast.classList.add("hidden")
        this.queue.push(toast)
      }
    })
  }

  dismissLatest() {
    const active = this.activeToasts
    if (active.length === 0) return

    this.hideToast(active[active.length - 1])
  }

  pause(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    this.pauseToast(toast)
  }

  resume(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    this.resumeToast(toast)
  }

  dismiss(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    this.hideToast(toast)
  }

  touchStart(event) {
    if (event.touches.length !== 1) return

    const toast = this.toastFromEvent(event)
    if (!toast) return

    const x = event.touches[0].clientX
    this.touchState.set(toast, { startX: x, deltaX: 0, dragging: true })
    toast.classList.add("is-dragging")
    this.pauseToast(toast)
  }

  touchMove(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    const touch = this.touchState.get(toast)
    if (!touch || !touch.dragging || event.touches.length !== 1) return

    const deltaX = event.touches[0].clientX - touch.startX
    touch.deltaX = deltaX

    toast.style.transform = `translateX(${deltaX}px)`
    toast.style.opacity = String(Math.max(0.5, 1 - Math.abs(deltaX) / 240))
  }

  touchEnd(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    const touch = this.touchState.get(toast)
    if (!touch || !touch.dragging) return

    touch.dragging = false
    const shouldDismiss = Math.abs(touch.deltaX) >= this.swipeThresholdPixels

    if (shouldDismiss) {
      const direction = touch.deltaX >= 0 ? 1 : -1
      this.dismissBySwipe(toast, direction)
      return
    }

    this.resetSwipe(toast)
    this.resumeToast(toast)
  }

  touchCancel(event) {
    const toast = this.toastFromEvent(event)
    if (!toast) return

    this.resetSwipe(toast)
    this.resumeToast(toast)
  }

  startToast(toast) {
    toast.classList.remove("hidden")

    const timeout = Number(toast.dataset.timeout || this.defaultDurationValue || 4500)
    const state = {
      remaining: timeout,
      paused: false,
      startedAt: null,
      timer: null,
    }

    this.toastState.set(toast, state)

    const progress = toast.querySelector(".flash-toast-progress")
    if (progress) {
      progress.style.animationDuration = `${timeout}ms`
      progress.style.animationPlayState = "running"
    }

    requestAnimationFrame(() => toast.classList.add("is-visible"))
    this.startTimer(toast, state)
  }

  startTimer(toast, state) {
    state.startedAt = Date.now()
    state.timer = setTimeout(() => this.hideToast(toast), state.remaining)
  }

  stopTimer(_toast, state) {
    if (!state.timer) return

    clearTimeout(state.timer)
    state.timer = null
    const elapsed = Date.now() - state.startedAt
    state.remaining = Math.max(0, state.remaining - elapsed)
  }

  hideToast(toast) {
    if (toast.classList.contains("is-leaving")) return

    const state = this.toastState.get(toast)
    if (state) this.stopTimer(toast, state)

    toast.classList.remove("is-visible")
    toast.classList.add("is-leaving")

    window.setTimeout(() => this.removeToast(toast), 220)
  }

  dismissBySwipe(toast, direction) {
    const state = this.toastState.get(toast)
    if (state) this.stopTimer(toast, state)

    toast.classList.remove("is-visible")
    toast.classList.add("is-leaving")
    toast.style.transform = `translateX(${direction * 130}%)`
    toast.style.opacity = "0"

    window.setTimeout(() => this.removeToast(toast), 220)
  }

  removeToast(toast) {
    const item = toast.closest("li")
    if (item) item.remove()

    this.showNextToast()

    if (this.activeToasts.length === 0 && this.queue.length === 0) {
      this.element.remove()
    }
  }

  pauseToast(toast) {
    const state = this.toastState.get(toast)
    if (!state || state.paused) return

    this.stopTimer(toast, state)
    state.paused = true

    const progress = toast.querySelector(".flash-toast-progress")
    if (progress) progress.style.animationPlayState = "paused"
  }

  resumeToast(toast) {
    const state = this.toastState.get(toast)
    if (!state || !state.paused) return

    state.paused = false
    this.startTimer(toast, state)

    const progress = toast.querySelector(".flash-toast-progress")
    if (progress) progress.style.animationPlayState = "running"
  }

  resetSwipe(toast) {
    this.touchState.delete(toast)
    toast.classList.remove("is-dragging")
    toast.style.transform = ""
    toast.style.opacity = ""
  }

  showNextToast() {
    const nextToast = this.queue.shift()
    if (!nextToast) return

    this.startToast(nextToast)
  }

  get activeToasts() {
    return this.toastTargets.filter((toast) => !toast.classList.contains("hidden") && !toast.classList.contains("is-leaving"))
  }

  get maxVisibleCount() {
    return this.hasMaxVisibleValue ? this.maxVisibleValue : 3
  }

  get swipeThresholdPixels() {
    return this.hasSwipeThresholdValue ? this.swipeThresholdValue : 72
  }

  toastFromEvent(event) {
    return event.target.closest('[data-flash-toast-target="toast"]')
  }
}
