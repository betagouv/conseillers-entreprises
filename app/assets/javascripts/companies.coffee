window.Companies =
  setupMandatairesDisplay: ->
    $('#show-mandataires').on 'click', =>
      @showMandataires()
    $('#hide-mandataires').on 'click', =>
      @hideMandataires()

  showMandataires: ->
    $('#show-mandataires').hide()
    $('#hide-mandataires').show()
    $('#mandataires').show()

  hideMandataires: ->
    $('#hide-mandataires').hide()
    $('#show-mandataires').show()
    $('#mandataires').hide()

$ ->
  if $('#company-show').length > 0
    window.Companies.setupMandatairesDisplay()
