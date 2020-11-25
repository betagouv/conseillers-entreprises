(function () {
  // See also views/application/_insee_code_field.html.haml
  // Uses the api-adresse to load communes insee codes for a postal code, and fill the <option>s of a <select>.
  addEventListener('turbolinks:load', setupInseeCodeFields)

  function setupInseeCodeFields () {
    const containers = document.querySelectorAll('.insee-code-field')
    for (let i = 0; i < containers.length; i++) {
      setupInseeCodeField(containers[i])
    }
  }

  function setupInseeCodeField (container) {
    const text_field = container.querySelector('input#postal_code')
    text_field.addEventListener('input', () => loadInseeCodes(container, text_field))
  }

  function loadInseeCodes (container, text_field) {
    if (!text_field.validity.valid) {
      return
    }

    const loader = container.querySelector('.insee-code-loader')
    const select = container.querySelector('select#insee_code')

    loader.classList.add('active')

    const url = `https://api-adresse.data.gouv.fr/search/?type=municipality&q=${text_field.value}`
    const request = new XMLHttpRequest()
    request.open('GET', url)
    request.addEventListener('load', function () {
      loader.classList.remove('active')
      select.length = 0
      const json = JSON.parse(this.response)
      const cities = json.features
      cities.forEach(hash => select.add(new Option(hash.properties.name, hash.properties.citycode)))
    })
    request.send()
  }
})()
