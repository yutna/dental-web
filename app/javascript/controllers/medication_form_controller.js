import { Controller } from "@hotwired/stimulus"

const HIGH_ALERT_KEYWORDS = [
  "diazepam", "morphine", "fentanyl", "midazolam", "ketamine",
  "warfarin", "heparin", "insulin", "methotrexate", "digoxin"
]

export default class extends Controller {
  static targets = [
    "codeInput", "form", "highAlertInput", "allergyInput",
    "modalItemName", "allergyDetail", "overrideReasonInput"
  ]

  checkHighAlert() {
    const code = this.codeInputTarget.value.toLowerCase()
    const isHighAlert = HIGH_ALERT_KEYWORDS.some((keyword) => code.includes(keyword))

    if (isHighAlert) {
      // Set the modal item name text
      if (this.hasModalItemNameTarget) {
        this.modalItemNameTarget.textContent = this.codeInputTarget.value
      }
      // Open the high-alert modal via its controller
      this.#openModal("high-alert-modal")
    }
  }

  confirmHighAlert() {
    if (this.hasHighAlertInputTarget) {
      this.highAlertInputTarget.value = "true"
    }
    this.#closeModal("high-alert-modal")
  }

  cancelHighAlert() {
    if (this.hasHighAlertInputTarget) {
      this.highAlertInputTarget.value = ""
    }
    this.codeInputTarget.value = ""
  }

  removeMedication() {
    this.codeInputTarget.value = ""
    if (this.hasHighAlertInputTarget) this.highAlertInputTarget.value = ""
    if (this.hasAllergyInputTarget) this.allergyInputTarget.value = ""
  }

  requestOverride() {
    if (this.hasOverrideReasonInputTarget && this.hasAllergyInputTarget) {
      const reason = this.overrideReasonInputTarget.value.trim()
      if (!reason) {
        this.overrideReasonInputTarget.focus()
        return
      }
      this.allergyInputTarget.value = reason
    }
    this.#closeAllModals()
  }

  #openModal(id) {
    const modal = this.element.querySelector(`#${id}`)
    if (modal) {
      const ctrl = this.application.getControllerForElementAndIdentifier(modal, "modal")
      if (ctrl) ctrl.open()
    }
  }

  #closeModal(id) {
    const modal = this.element.querySelector(`#${id}`)
    if (modal) {
      const ctrl = this.application.getControllerForElementAndIdentifier(modal, "modal")
      if (ctrl) ctrl.close()
    }
  }

  #closeAllModals() {
    this.element.querySelectorAll('[data-controller="modal"]').forEach((el) => {
      const ctrl = this.application.getControllerForElementAndIdentifier(el, "modal")
      if (ctrl) ctrl.close()
    })
  }
}
