window.Visits =
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

$(document).on 'turbolinks:load', ->
  if $('#new-visit-form').length > 0
    window.Visits.setupDatePicker()

# IE9 compatibility
$ ->
  if $('#new-visit-form').length > 0
    window.Visits.setupDatePicker()
