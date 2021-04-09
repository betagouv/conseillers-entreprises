import { Controller } from 'stimulus'

export default class extends Controller {

  collapse() {
    var button = event.currentTarget
    const collapsible = document.getElementById(button.getAttribute('aria-controls'))
    var buttons = document.getElementsByClassName('fr-accordion__btn')
    var state = button.getAttribute('aria-expanded')
    if (state == 'true') {
      collapsible.style.setProperty('max-height', '')
      button.setAttribute('aria-expanded', false)
      collapsible.classList.remove('fr-collapse--expanded')
    } else {
      buttons.forEach(element => element.setAttribute('aria-expanded', false));
      button.setAttribute('aria-expanded', true)
      collapsible.classList.add('fr-collapse--expanded')
      collapsible.style.setProperty('--collapser', 'none')
      const height = collapsible.offsetHeight
      collapsible.style.setProperty('--collapse', -height + 'px')
      collapsible.style.setProperty('--collapser', '')
      collapsible.style.setProperty('max-height', 'none')
    }
  }
}
