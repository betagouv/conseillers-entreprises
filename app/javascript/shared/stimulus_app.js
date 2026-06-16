import { Application } from "@hotwired/stimulus"

const stimulus_app = Application.start()

// Configure Stimulus development experience
stimulus_app.debug = false
window.Stimulus   = stimulus_app

export { stimulus_app }
