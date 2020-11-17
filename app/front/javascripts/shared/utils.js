// Short functions that may be used among multiple files =======

// Check if html element exists
export function exists(element) {
  return typeof element != "undefined" && element != null;
}

// Simple debounce function
export function debounce(fn, delay) {
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
