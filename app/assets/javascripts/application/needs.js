addEventListener('turbolinks:load', function(event) {
  $('.need-section .feed .event .user').popup({ hoverable: true });
  $('select.ui.selection.search.dropdown').dropdown({ fullTextSearch: 'exact', ignoreDiacritics: true });
  $('select.ui.selection.dropdown').dropdown();
});
