addEventListener('turbo:load', function () {
  $('.ui.modal').modal({ closable: false }).modal('show') // Show modal before activating other elements that may be inside the modal
  $('.popup-hover').popup({ hoverable: true })
  $('select.ui.selection.search.dropdown').dropdown({ fullTextSearch: 'exact', ignoreDiacritics: true })
  $('.ui.dropdown').not('.simple').dropdown()
  $('.tabular.menu .item').tab()
  $('.ui.accordion').accordion({ exclusive: false })
})
