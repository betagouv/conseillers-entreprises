// Short functions that may be used among multiple files =======

// Check if html element exists
export function exists (element) {
  return typeof element !== 'undefined' && element != null
}

// Simple debounce function
export function debounce (fn, delay) {
  let timer = null
  return function () {
    const context = this
    const args = arguments
    clearTimeout(timer)
    timer = setTimeout(function () {
      fn.apply(context, args)
    }, delay)
  }
}
