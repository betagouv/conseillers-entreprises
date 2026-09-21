// Drag-and-drop row reordering for /admin index tables.
// Replaces the activeadmin_reorderable gem, which pins activeadmin < 4.
//
// Any table containing a `.reorder-handle[data-reorder-url]` becomes reorderable:
// dropping a row POSTs its new 1-based position to that URL.
(function() {
  // Renumber rows after a move, so striping and the position column stay in sync
  // until the next page load.
  function refreshRows(table) {
    Array.from(table.tBodies[0].rows).forEach(function(row, index) {
      const position = index + 1;

      row.classList.remove('odd', 'even');
      row.classList.add(position % 2 === 0 ? 'even' : 'odd');

      const positionCell = row.querySelector('.col-position');
      if (positionCell !== null) { positionCell.textContent = position; }
    });
  }

  function persistPosition(row) {
    const handle = row.querySelector('.reorder-handle');
    const position = Array.from(row.parentNode.rows).indexOf(row) + 1;
    const headers = {};

    const csrfElement = document.querySelector('meta[name=csrf-token]');
    if (csrfElement !== null) {
      headers['X-CSRF-Token'] = csrfElement.getAttribute('content');
    }

    const body = new FormData();
    body.append('position', position);

    fetch(handle.dataset.reorderUrl, { method: 'POST', headers: headers, body: body });
  }

  function setupReorderable(table) {
    let draggedRow = null;
    let initialIndex = null;

    Array.from(table.tBodies[0].rows).forEach(function(row) {
      const handle = row.querySelector('.reorder-handle');
      if (handle === null) { return; }

      // Only the handle starts a drag, so selecting text in the row still works
      handle.addEventListener('mousedown', function() { row.setAttribute('draggable', 'true'); });
      handle.addEventListener('mouseup', function() { row.setAttribute('draggable', 'false'); });

      row.addEventListener('dragstart', function(event) {
        event.dataTransfer.effectAllowed = 'move';
        draggedRow = row;
        initialIndex = row.rowIndex;
        // Delay the styling so the browser captures the drag image first
        setTimeout(function() { row.classList.add('dragged-row'); }, 1);
      });

      row.addEventListener('dragover', function(event) {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
        if (draggedRow === null || draggedRow === row) { return; }

        if (draggedRow.rowIndex < row.rowIndex) {
          table.tBodies[0].insertBefore(draggedRow, row.nextSibling);
        } else {
          table.tBodies[0].insertBefore(draggedRow, row);
        }
        refreshRows(table);
      });

      row.addEventListener('dragend', function() {
        row.setAttribute('draggable', 'false');
        row.classList.remove('dragged-row');

        if (initialIndex !== row.rowIndex) { persistPosition(row); }

        draggedRow = null;
        initialIndex = null;
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function() {
    const tables = new Set();

    document.querySelectorAll('.reorder-handle[data-reorder-url]').forEach(function(handle) {
      const table = handle.closest('table');
      if (table !== null && table.tBodies.length > 0) { tables.add(table); }
    });

    tables.forEach(setupReorderable);
  });
})();
