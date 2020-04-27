(function(){
  // See also views/application/_insee_code_field.html.haml
  // Uses the api-adresse to load communes insee codes for a postal code, and fill the <option>s of a <select>.
  addEventListener("turbolinks:load", setupInseeCodeFields);

  function setupInseeCodeFields(event) {
    var containers = document.querySelectorAll('.insee-code-field');
    containers.forEach( container => setupInseeCodeField(container) )
  }

  function setupInseeCodeField(container) {
    var text_field = container.querySelector('input#postal_code');
    text_field.addEventListener('input', (event) => loadInseeCodes(container, text_field));
  }

  function loadInseeCodes(container, text_field) {
    if (!text_field.validity.valid) {
      return
    }

    var loader = container.querySelector('.insee-code-loader');
    var select = container.querySelector('select#insee_code');

    loader.classList.add('active');

    var url = `https://api-adresse.data.gouv.fr/search/?type=municipality&q=${text_field.value}`;
    var request = new XMLHttpRequest();
    request.open('GET', url);
    request.addEventListener('load', function () {
      loader.classList.remove('active');
      select.length = 0;
      var json = JSON.parse(this.response);
      var cities = json['features'];
      cities.forEach(hash => select.add(new Option(hash['properties']['name'], hash['properties']['citycode'])));
    });
    request.send();
  }
})();
