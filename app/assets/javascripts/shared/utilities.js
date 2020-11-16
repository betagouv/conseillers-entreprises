// Short functions that may be used among multiple files =======

// Check if html element exists
function exists(element) {
  return typeof element != "undefined" && element != null;
}

// Simple debounce function
function debounce(fn, delay) {
  var timer = null;
  return function () {
    var context = this,
      args = arguments;
    clearTimeout(timer);
    timer = setTimeout(function () {
      fn.apply(context, args);
    }, delay);
  };
}
