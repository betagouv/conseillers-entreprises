$ ->
  if $('#new-visit-form').length > 0
    window.Visits.setupModalDisplay()
    window.Visits.setupDatePicker()
    window.Visits.updateSubmitDisplay()

window.Visits =
  setCompanyInfoAndCloseModal: (companySiret, companyName, companyLocation) ->
    $('#visit-siret').val(companySiret)
    $('#company-info .name').text(' : ' + companyName)
    $('#company-info .location').text(' : ' + companyLocation)
    window.Visits.updateSubmitDisplay()
    $('#company-name-modal').modal('hide')

  setupCompanyLink: ->
    $('.company-link').off 'click'
    $('.company-link').on 'click', ->
      window.Visits.setCompanyInfoAndCloseModal($(@).data('company-siren'), $(@).data('company-name'), $(@).data('company-location'))

  setupModalDisplay: ->
    $('.open-company-name-modal').click ->
      $('#company-name-modal').modal('show')

  updateSubmitDisplay: ->
    if $('#visit-siret').val() == ''
      $('#add-company').show()
      $('#company-info').hide()
      $('#new-visit-submit-wrapper').hide()
    else
      $('#add-company').hide()
      $('#company-info').show()
      $('#new-visit-submit-wrapper').show()

  setupDatePicker: ->
    $('#datepicker').calendar
      type: 'date',
      firstDayOfWeek: 1,
      ampm: false,
      text:
        days: ['D', 'L', 'Ma', 'Me', 'J', 'V', 'S'],
        months: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
        monthsShort: ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aou', 'Sep', 'Oct', 'Nov', 'Déc'],
        today: "Aujourd'hui",
        now: 'Maintenant',
        am: 'AM',
        pm: 'PM'
      formatter:
        date: (date, settings) ->
          return '' unless date
          day = date.getDate() + ''
          day = '0' + day if (day.length < 2)
          month = (date.getMonth() + 1) + ''
          month = '0' + month if (month.length < 2)
          year = date.getFullYear()
          return day + '/' + month + '/' + year