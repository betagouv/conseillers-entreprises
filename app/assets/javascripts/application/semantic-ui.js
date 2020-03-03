addEventListener('turbolinks:load', function(event) {
  $('.ui.modal').modal( { closable: false }).modal('show'); // Show modal before activating other elements that may be inside the modal
  $('.popup-hover').popup({ hoverable: true });
  $('select.ui.selection.search.dropdown').dropdown({ fullTextSearch: 'exact', ignoreDiacritics: true });
  $('select.ui.selection.dropdown').dropdown();
  $('.tabular.menu .item').tab();
  $('.ui.accordion').accordion();
});
