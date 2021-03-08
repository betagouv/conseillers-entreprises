(function () {
  addEventListener('turbo:load', setupSemanticUiCalendar)

  function setupSemanticUiCalendar () {
    const semanticUiCalendars = document.querySelectorAll("[data-calendar='semantic-ui']")

    for (let i = 0; i < semanticUiCalendars.length; i++) {
      const calendar = semanticUiCalendars[i]
      const params = setSemanticUiCalendarDatepickerParams()
      params.text = {
        days: JSON.parse(calendar.dataset.days),
        months: JSON.parse(calendar.dataset.months)
      }
      $('.ui.calendar#datepicker').calendar(params)
    }

    function setSemanticUiCalendarDatepickerParams () {
      // This can’t just be in semantic-ui.js with the other initializer, as we need to dynamically set the text from rails i18n.
      return {
        type: 'date',
        firstDayOfWeek: 1,
        disableMonth: true,
        disableYear: true,
        formatter: {
          date: function (date) {
            const d = date.getDate()
            const m = date.getMonth() + 1
            const y = date.getFullYear()
            return ('0' + d).slice(-2) + '/' + ('0' + m).slice(-2) + '/' + y
          }
        },
        parser: {
          date: function (text) {
            let parts = text.split('-')
            if (parts.length !== 3) {
              parts = text.split('/').reverse()
            }
            if (parts.length === 3) {
              return new Date(parts[0], parts[1] - 1, parts[2])
            }
          }
        }
      }
    }
  }
})()
