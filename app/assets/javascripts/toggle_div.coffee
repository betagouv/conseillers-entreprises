window.ToggleDiv =
  setup: ->
    $('.toggle-show-button').on 'click', ->
      window.ToggleDiv.show($(this).parent())
    $('.toggle-hide-button').on 'click', ->
      window.ToggleDiv.hide($(this).parent())
    $('.toggle-hide-button').hide()
    $('.toggle-div').hide()

  show: ($wrapperDiv) ->
    $wrapperDiv.find('.toggle-show-button').hide()
    $wrapperDiv.find('.toggle-hide-button').show()
    $wrapperDiv.find('.toggle-div').show()

  hide: ($wrapperDiv) ->
    $wrapperDiv.find('.toggle-hide-button').hide()
    $wrapperDiv.find('.toggle-show-button').show()
    $wrapperDiv.find('.toggle-div').hide()

$(document).on 'turbolinks:load', ->
  if $('#company-show').length > 0 || $('.assistance').length > 0
    window.ToggleDiv.setup()
