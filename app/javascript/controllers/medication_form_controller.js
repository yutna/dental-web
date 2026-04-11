import { Controller } from "@hotwired/stimulus"

const HIGH_ALERT_KEYWORDS = [
  "diazepam", "morphine", "fentanyl", "midazolam", "ketamine",
  "warfarin", "heparin", "insulin", "methotrexate", "digoxin"
]

export default class extends Controller {
  static targets = [
    "codeInput", "highAlertPanel", "highAlertCheckbox",
    "allergyPanel", "allergyReasonInput", "form"
  ]

  checkHighAlert() {
    const code = this.codeInputTarget.value.toLowerCase()
    const isHighAlert = HIGH_ALERT_KEYWORDS.some((keyword) => code.includes(keyword))

    if (isHighAlert) {
      this.highAlertPanelTarget.classList.remove("hidden")
    } else {
      this.highAlertPanelTarget.classList.add("hidden")
    }
  }

  showAllergyPanel() {
    this.allergyPanelTarget.classList.remove("hidden")
  }

  hideAllergyPanel() {
    this.allergyPanelTarget.classList.add("hidden")
    this.allergyReasonInputTarget.value = ""
  }
}
