<template>
    <div class="ui calendar">
        <div class="ui form field input left icon">
            <i class="calendar icon"></i>
            <input type="text">
        </div>
    </div>
</template>

<script>
/* global $:false */

import 'semantic-ui-calendar/dist/calendar.css'
import 'semantic-ui-calendar/dist/calendar.js'
import 'jquery/dist/jquery.js'
import moment from 'moment'
import DateValidator from './dateValidator'

export default {
  name: 'date-picker',
  props: [
    'value'
  ],
  data () {
    return {
      dateValue: '',
      dateValidator: {}
    }
  },
  mounted: function () {
    this.prepareJQueryCalendar()
  },
  watch: {
    value: function (value) {
      if (value != null && value.length !== 0) {
        let dateValidator = new DateValidator(value)
        if (dateValidator.isValid) {
          this.setDate(dateValidator.toDate)
        }
      }
    }
  },
  methods: {
    prepareJQueryCalendar: function () {
      moment.locale('fr')
      $(this.$el).calendar({
        type: 'date',
        firstDayOfWeek: 1,
        closable: false,
        constantHeight: true,
        today: true,
        disableMonth: true,
        disableYear: true,
        multiMonth: 1,
        text: {
          days: moment.weekdaysMin(),
          months: moment.months().map((month) => {
            return month.charAt(0).toUpperCase() + month.slice(1)
          }),
          monthsShort: moment.monthsShort(),
          today: 'Aujourd\'hui'
        },
        onChange: (date, text, mode) => {
          this.updateValue(date)
        },
        formatter: {
          date: function (date, settings) {
            return moment(date).format('DD/MM/YYYY')
          }
        },
        parser: {
          date: function (text, settings) {
            let date = moment(text, ['DD/MM/YYYY', 'YYYY-MM-DD'], true)
            if (date.isValid()) {
              return date.toDate()
            }
          }
        }
      })
    },
    setDate: function (date) {
      $(this.$el).calendar('set date', date, true, false)
    },
    updateValue: function (date) {
      let dateString = moment(date).format('YYYY-MM-DD')
      this.$emit('input', dateString)
    }
  }
}
</script>

<style lang="sass">
    .ui.popup
        padding: 0 !important
    .link.prev, .link.next, .link.focus
        cursor: pointer
    .link.focus
        color: #85B7D9
</style>
