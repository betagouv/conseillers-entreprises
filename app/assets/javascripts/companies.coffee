$ ->
  if $('#mandataires').length > 0
    window.Companies.setupMandatairesShowHide()

window.Companies =
  setupMandatairesShowHide: ->
    $('#show-mandataires').on 'click', ->
      $('#show-mandataires').hide()
      $('#hide-mandataires').show()
      $('#mandataires').show()

    $('#hide-mandataires').on 'click', ->
      $('#hide-mandataires').hide()
      $('#show-mandataires').show()
      $('#mandataires').hide()
