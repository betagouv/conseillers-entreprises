(function () {
  // Make external links work properly when the site is inside an iframe.
  // This adds target="_parent" to all <a> whose url isn't ours.

  this.onload = function () {
    if (inIframe()) {
      makeExternalLinksOpenInParent()
    }
  }

  function inIframe () {
    try {
      return window.self !== window.top
    } catch (e) {
      return true
    }
  }

  function makeExternalLinksOpenInParent () {
    const links = document.getElementsByTagName('a')
    for (let i = 0; i < links.length; ++i) {
      targetParentIfExternal(links[i])
    }
  }

  function targetParentIfExternal (link) {
    if (link.host !== window.location.host) {
      link.target = '_parent'
    }
  }
})()
