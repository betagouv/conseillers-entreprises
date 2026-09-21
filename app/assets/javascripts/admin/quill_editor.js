// Quill rich-text editors for /admin forms.
// Replaces the activeadmin_quill_editor gem, which pins activeadmin < 4.
//
// Markup comes from app/inputs/quill_editor_input.rb: a `[data-quill-editor]`
// wrapper holding a hidden field and a `[data-quill-content]` editable div.
// Unlike the gem, this does not depend on jQuery, so it survives the drop of
// jQuery in ActiveAdmin 4.
(function() {
  'use strict';

  const TOOLBAR = [
    ['bold', 'italic', 'underline'],
    ['link', 'blockquote', 'code-block'],
    [{ script: 'sub' }, { script: 'super' }],
    [{ align: [] }, { list: 'ordered' }, { list: 'bullet' }],
    [{ color: [] }, { background: [] }],
    ['image'],
    ['clean'],
  ];

  function initEditor(wrapper) {
    if (wrapper.dataset.quillInitialized === 'true') { return; }

    const content = wrapper.querySelector('[data-quill-content]');
    const field = wrapper.querySelector('input[type="hidden"]');
    if (content === null || field === null) { return; }

    wrapper.dataset.quillInitialized = 'true';
    const editor = new Quill(content, { theme: 'snow', modules: { toolbar: TOOLBAR } });

    // Mirror the editor into the hidden field on every keystroke, so the form
    // always carries an up-to-date value whenever and however it is submitted.
    editor.on('text-change', function() {
      field.value = editor.getLength() <= 1 ? '' : editor.root.innerHTML;
    });
  }

  function initEditorsWithin(root) {
    root.querySelectorAll('[data-quill-editor]').forEach(initEditor);
  }

  document.addEventListener('DOMContentLoaded', function() {
    initEditorsWithin(document);

    // has_many fields append new rows after load, so pick those up too
    const form = document.querySelector('form.formtastic');
    if (form === null) { return; }

    new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === Node.ELEMENT_NODE) { initEditorsWithin(node); }
        });
      });
    }).observe(form, { childList: true, subtree: true });
  });
})();
