// Searchable selects for /admin, backed by the ActiveAdmin index JSON endpoints.
// Replaces the activeadmin-ajax_filter gem, which pins activeadmin < 4 and whose
// selectize frontend depends on jQuery, dropped in ActiveAdmin 4.
//
// Markup comes from app/inputs/active_admin/inputs/*ajax_select_input.rb: a
// `select[data-ajax-select]` carrying the endpoint and the Ransack predicate to
// query. Only the current selection is rendered server side; everything else is
// fetched here as the user types.
import SlimSelect from 'slim-select';

function buildUrl(select, query) {
  const url = new URL(select.dataset.url, window.location.origin);

  url.searchParams.set('q[' + select.dataset.searchParam + ']', query);
  url.searchParams.set('limit', select.dataset.limit || '20');
  return url;
}

function toOptions(records, labelField) {
  return records.map(function(record) {
    // Fall back to the id rather than rendering "undefined" when the label is a
    // computed attribute that as_json does not expose.
    const label = record[labelField];

    return {
      value: String(record.id),
      text: (label === null || label === undefined || label === '') ? String(record.id) : String(label),
    };
  });
}

function search(select, query) {
  return fetch(buildUrl(select, query), {
    headers: { Accept: 'application/json' },
    credentials: 'same-origin',
  }).then(function(response) {
    if (!response.ok) { throw new Error('Search failed with status ' + response.status); }
    return response.json();
  }).then(function(records) {
    return toOptions(records, select.dataset.labelField);
  });
}

function enhance(select) {
  if (select.dataset.ajaxSelectInitialized === 'true') { return; }
  select.dataset.ajaxSelectInitialized = 'true';

  new SlimSelect({
    select: select,
    settings: {
      placeholderText: select.dataset.placeholderText,
      searchPlaceholder: select.dataset.searchPlaceholder,
      searchText: select.dataset.searchText,
      searchingText: select.dataset.searchingText,
    },
    events: {
      search: function(query) {
        if (query.length === 0) { return Promise.resolve([]); }

        // Surfacing the message keeps slim-select from silently showing "no result"
        // when the endpoint is actually failing.
        return search(select, query).catch(function(error) { return Promise.reject(error.message); });
      },
    },
  });
}

function enhanceWithin(root) {
  root.querySelectorAll('select[data-ajax-select]').forEach(enhance);
}

document.addEventListener('DOMContentLoaded', function() {
  enhanceWithin(document);

  // has_many fields append new rows after load, so pick those up too
  const form = document.querySelector('form.formtastic');
  if (form === null) { return; }

  new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.nodeType === Node.ELEMENT_NODE) { enhanceWithin(node); }
      });
    });
  }).observe(form, { childList: true, subtree: true });
});
