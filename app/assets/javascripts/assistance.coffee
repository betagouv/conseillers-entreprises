$ ->
  if $('.mailto-expert-button').length > 0
    window.Assistances.setupMailToLogger()

window.Assistances =
  setupMailToLogger: ->
    $('.mailto-expert-button').off 'click'
    $('.mailto-expert-button').on 'click', (event) ->
      if $(this).data('mailto-logged') == false
        url = $(this).data('mailto-log-path')
        $.ajax url,
          data:
            format: 'js'
          type: 'POST'
          success: =>
            $(this).data('mailto-logged', true)