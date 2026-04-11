import { Controller } from "@hotwired/stimulus"

const THEME_STORAGE_KEY = "theme-preference"
const THEME_MODES = [ "light", "dark", "system" ]

export default class extends Controller {
  static targets = [ "select", "resolvedLabel" ]
  static values = {
    darkLabel: String,
    lightLabel: String
  }

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.systemPreferenceChanged = this.systemPreferenceChanged.bind(this)
    this.mediaQuery.addEventListener("change", this.systemPreferenceChanged)
    this.syncFromDocument()
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.systemPreferenceChanged)
  }

  change(event) {
    this.applyMode(event.target.value, { persist: true })
  }

  selectMode(event) {
    this.applyMode(event.target.value, { persist: true })
  }

  cycle() {
    const current = this.currentMode()
    const idx = THEME_MODES.indexOf(current)
    const next = THEME_MODES[(idx + 1) % THEME_MODES.length]
    this.applyMode(next, { persist: true })
  }

  syncFromDocument() {
    const mode = this.currentMode()
    if (this.hasSelectTarget) {
      this.selectTarget.value = mode
    }

    this.element.querySelectorAll('input[name="workspace-theme-mode"]').forEach((input) => {
      input.checked = input.value === mode
    })

    this.updateResolvedLabel()
  }

  systemPreferenceChanged() {
    if (this.currentMode() !== "system") return
    this.applyMode("system", { persist: false })
  }

  currentMode() {
    const mode = document.documentElement.dataset.themeMode
    return THEME_MODES.includes(mode) ? mode : "system"
  }

  applyMode(mode, { persist }) {
    if (!THEME_MODES.includes(mode)) return

    const resolvedTheme = mode === "system" ? this.systemTheme() : mode
    const root = document.documentElement

    root.dataset.themeMode = mode
    root.dataset.theme = resolvedTheme
    root.classList.toggle("dark", resolvedTheme === "dark")

    if (persist) {
      localStorage.setItem(THEME_STORAGE_KEY, mode)
      this.dispatch("changed", { detail: { mode, resolvedTheme } })
    }

    if (this.hasSelectTarget) {
      this.selectTarget.value = mode
    }

    this.element.querySelectorAll('input[name="workspace-theme-mode"]').forEach((input) => {
      input.checked = input.value === mode
    })

    this.updateResolvedLabel()
  }

  systemTheme() {
    return this.mediaQuery.matches ? "dark" : "light"
  }

  updateResolvedLabel() {
    if (!this.hasResolvedLabelTarget) return

    const resolvedTheme = document.documentElement.dataset.theme === "dark" ? "dark" : "light"
    this.resolvedLabelTarget.textContent = resolvedTheme === "dark" ? this.darkLabelValue : this.lightLabelValue
  }
}
