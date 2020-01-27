addEventListener('turbolinks:load', function(event) {
  $('.popup-hover').popup({ hoverable: true });
  $('select.ui.selection.search.dropdown').dropdown({ fullTextSearch: 'exact', ignoreDiacritics: true });
  $('select.ui.selection.dropdown').dropdown();
  $('.tabular.menu .item').tab()
});
