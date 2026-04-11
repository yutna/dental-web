import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "img"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file || !file.type.startsWith("image/")) {
      this.previewTarget.classList.add("hidden")
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      this.imgTarget.src = e.target.result
      this.previewTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }
}
