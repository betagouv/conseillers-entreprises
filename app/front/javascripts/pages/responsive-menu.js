(function () {
  addEventListener('DOMContentLoaded', setupMenuAriaExpanded)
  function setupMenuAriaExpanded () {
    $('#responsive-button-main-navigation').click( function() {
      if ($("#responsive-main-navigation.active")[0]) {
        $('#responsive-button-main-navigation').attr("aria-expanded","true")
      } else {
        $('#responsive-button-main-navigation').attr("aria-expanded","false")
      }
    })
  }
})()
