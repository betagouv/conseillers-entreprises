window.DiagnosisStep4 =
  setupCheckboxes: ->
    $('input:checkbox').on 'click', =>
      @changeConfirmText()

  changeConfirmText: ->
    checkedCheckboxesCount = $('input:checkbox:checked').length
    $('#step4-form').attr('data-confirm', @confirmText(checkedCheckboxesCount))

  confirmText: (checkedCheckboxesCount) ->
    if checkedCheckboxesCount > 1
      return 'Voulez-vous contacter les référents sélectionnés ?'
    else if checkedCheckboxesCount > 0
      return 'Voulez-vous contacter le référent sélectionné ?'
    else
      return 'Vous n\'avez sélectionné aucun référent. Êtes vous sûr de vouloir continuer ?'

$(document).on 'turbolinks:load', ->
  if $('#step4-app').length > 0
    window.DiagnosisStep4.setupCheckboxes()
    window.DiagnosisStep4.changeConfirmText()

# IE9 compatibility
$ ->
  if $('#step4-app').length > 0
    window.DiagnosisStep4.setupCheckboxes()
    window.DiagnosisStep4.changeConfirmText()
