export default class DateUtils {

    constructor(selectedDate) {
        this.selectedDate = selectedDate
    }

    get dateString() {
        return this.selectedDate.toLocaleDateString()
    }

    get daysOfMonth() {
        const firstDayOfMonth = new Date(this.selectedDate.getFullYear(), this.selectedDate.getMonth())
        const lastDayOfMonth = new Date(this.selectedDate.getFullYear(), this.selectedDate.getMonth() + 1, 0)

        const mondayAsFirstDayOfWeekOffset = 1
        const firstDayOfFirstWeek = new Date(firstDayOfMonth.getFullYear(),
            firstDayOfMonth.getMonth(),
            firstDayOfMonth.getDate() - firstDayOfMonth.getDay() + mondayAsFirstDayOfWeekOffset)

        let monthArray = []
        let isLastDayOfMonthPassed = false

        let workingDate = new Date(firstDayOfFirstWeek.getFullYear(),
            firstDayOfFirstWeek.getMonth(),
            firstDayOfFirstWeek.getDate())

        while (!isLastDayOfMonthPassed) {

            let weekArray = []
            let firstDayOfWeek = new Date(workingDate.getFullYear(),
                workingDate.getMonth(),
                workingDate.getDate())

            for (let i = 1; i < 8; i++) {

                let isDaySelected = workingDate.toLocaleDateString() == this.selectedDate.toLocaleDateString()
                let isInCuurentMonth = workingDate.getMonth() == this.selectedDate.getMonth()
                weekArray.push({day: workingDate.getDate(), selected: isDaySelected, inCurrentMonth: isInCuurentMonth})

                isLastDayOfMonthPassed = ((workingDate.toLocaleDateString() == lastDayOfMonth.toLocaleDateString())
                || isLastDayOfMonthPassed)

                workingDate = new Date(firstDayOfWeek.getFullYear(),
                    firstDayOfWeek.getMonth(),
                    firstDayOfWeek.getDate() + i)
            }

            monthArray.push(weekArray)
        }
        return monthArray
    }

    selectDay(day) {
        this.selectedDate = new Date(this.selectedDate.getFullYear(),
            this.selectedDate.getMonth(),
            day.day)
    }
}