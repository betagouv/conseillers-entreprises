addEventListener('turbolinks:load', function () {
  $('.popup-hover').popup({ hoverable: true })
  $('select.ui.selection.search.dropdown').dropdown({ fullTextSearch: 'exact', ignoreDiacritics: true })
  $('.tabular.menu .item').tab()
  $('.ui.accordion').accordion({ exclusive: false })
})
