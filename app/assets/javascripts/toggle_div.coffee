window.ToggleDiv =
  setupButtons: ->
    $('.toggle-show-button').on 'click', ->
      window.ToggleDiv.show($(this).parent())
    $('.toggle-hide-button').on 'click', ->
      window.ToggleDiv.hide($(this).parent())

  hideToggleDiv: ->
    $('.toggle-hide-button').hide()
    $('.toggle-div').hide()

  hideToggleShow: ->
    $('.toggle-show-button').hide()

  show: ($wrapperDiv) ->
    $wrapperDiv.find('.toggle-show-button').first().hide()
    $wrapperDiv.find('.toggle-hide-button').first().show()
    $wrapperDiv.find('.toggle-div').first().show()

  hide: ($wrapperDiv) ->
    $wrapperDiv.find('.toggle-hide-button').first().hide()
    $wrapperDiv.find('.toggle-show-button').first().show()
    $wrapperDiv.find('.toggle-div').first().hide()

$(document).on 'turbolinks:load', ->
  if $('#company-show').length > 0
    window.ToggleDiv.setupButtons()
    window.ToggleDiv.hideToggleDiv()
  if $('#diagnoses-index').length > 0
    window.ToggleDiv.setupButtons()
    window.ToggleDiv.hideToggleShow()

# IE9 compatibility
$ ->
  if $('#company-show').length > 0
    window.ToggleDiv.setupButtons()
    window.ToggleDiv.hideToggleDiv()
  if $('#diagnoses-index').length > 0
    window.ToggleDiv.setupButtons()
    window.ToggleDiv.hideToggleShow()
