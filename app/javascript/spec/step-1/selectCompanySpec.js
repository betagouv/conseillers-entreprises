import Vue from 'vue'
import SelectCompany from '../../packs/step-1/selectCompany.vue.erb'

//for the async function to work
require('babel-core/register')

describe('selectCompany', () => {
    it('sets the correct default data', () => {
        expect(typeof SelectCompany.data).toBe('function')

        const defaultData = SelectCompany.data()
        expect(defaultData.siret).toEqual('')
        expect(defaultData.companyName).toEqual('')
        expect(defaultData.facilityLocation).toEqual('')
        expect(defaultData.companyFormDisplayed).toBeTruthy()
        expect(defaultData.companyInfoDisplayed).toBeFalsy()
        expect(defaultData.nextStepButtonDisabled).toBeTruthy()
        expect(defaultData.isLoading).toBeFalsy()
        expect(defaultData.siretFormatError).toBeFalsy()
        expect(defaultData.companyNotFoundError).toBeFalsy()
        expect(defaultData.diagnosisSaveError).toBeFalsy()
    })

    describe('submitSelectCompany', () => {
        let selectCompany
        const searchFacilityPath = '/random/path'

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()
        })

        it('calls fetchCompany if SIRET is valid', function () {
            spyOn(selectCompany, 'siretFormatValid').and.returnValue(true)
            spyOn(selectCompany, 'fetchCompany')

            selectCompany.submitSelectCompany(searchFacilityPath)

            expect(selectCompany.fetchCompany).toHaveBeenCalledWith(searchFacilityPath)
            expect(selectCompany.siretFormatError).toBe(false)
        })

        it('makes siretFormatError true if SIRET is not valid', function () {
            spyOn(selectCompany, 'siretFormatValid').and.returnValue(false)
            spyOn(selectCompany, 'fetchCompany')

            selectCompany.submitSelectCompany(searchFacilityPath)

            expect(selectCompany.fetchCompany).not.toHaveBeenCalled()
            expect(selectCompany.siretFormatError).toBe(true)
        })
    })

    describe('siretFormatValid', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()
        })

        it('is true when SIRET number has good format', function () {
            selectCompany.siret = '12345678901234'

            expect(selectCompany.siretFormatValid()).toBeTruthy()
        })

        it('is false when SIRET number is too short', function () {
            selectCompany.siret = '1234'

            expect(selectCompany.siretFormatValid()).toBeFalsy()
        })

        it('is false when SIRET number has letters', function () {
            selectCompany.siret = 'a2345b78901c3d'

            expect(selectCompany.siretFormatValid()).toBeFalsy()
        })
    })

    describe('editCompanyForm', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()
        })

        it('removes errors and displays company form', function () {
            spyOn(selectCompany, 'removeErrors')
            spyOn(selectCompany, 'displayCompanyForm')

            selectCompany.editCompanyForm()

            expect(selectCompany.removeErrors).toHaveBeenCalled()
            expect(selectCompany.displayCompanyForm).toHaveBeenCalled()
        })
    })

    describe('displayCompanyForm', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()

            selectCompany.companyFormDisplayed = false
            selectCompany.companyInfoDisplayed = true
            selectCompany.nextStepButtonDisabled = false
        })

        it('activates company form and disables next step button', function () {
            selectCompany.displayCompanyForm()

            expect(selectCompany.companyFormDisplayed).toBe(true)
            expect(selectCompany.companyInfoDisplayed).toBe(false)
            expect(selectCompany.nextStepButtonDisabled).toBe(true)
        })
    })

    describe('displayCompanyInfo', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()

            selectCompany.companyFormDisplayed = true
            selectCompany.companyInfoDisplayed = false
            selectCompany.nextStepButtonDisabled = true
        })

        it('activates company info and enables next step button', function () {
            selectCompany.displayCompanyInfo()

            expect(selectCompany.companyFormDisplayed).toBe(false)
            expect(selectCompany.companyInfoDisplayed).toBe(true)
            expect(selectCompany.nextStepButtonDisabled).toBe(false)
        })
    })

    describe('formHasError', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()
        })

        it('assumes the form has no error by default', function () {
            selectCompany.formHasError()

            expect(selectCompany.formHasError()).toBe(false)
        })

        it('assumes the form has an error when there is a SIRET format error', function () {
            selectCompany.siretFormatError = true

            selectCompany.formHasError()

            expect(selectCompany.formHasError()).toBe(true)
        })

        it('assumes the form has an error when company is not found', function () {
            selectCompany.companyNotFoundError = true

            selectCompany.formHasError()

            expect(selectCompany.formHasError()).toBe(true)
        })

        it('assumes the form has an error when diagnosis was not saved', function () {
            selectCompany.diagnosisSaveError = true

            selectCompany.formHasError()

            expect(selectCompany.formHasError()).toBe(true)
        })
    })

    describe('removeErrors', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()

            selectCompany.siretFormatError = true
            selectCompany.companyNotFoundError = true
            selectCompany.diagnosisSaveError = true
        })

        it('removes all errors', function () {
            selectCompany.removeErrors()

            expect(selectCompany.siretFormatError).toBe(false)
            expect(selectCompany.companyNotFoundError).toBe(false)
            expect(selectCompany.diagnosisSaveError).toBe(false)
        })
    })

    describe('watch SIRET', () => {
        let selectCompany

        beforeEach(function () {
            const vueApp = Vue.extend(SelectCompany)
            selectCompany = new vueApp().$mount()
        })

        it('removes all errors', async function () {
            spyOn(selectCompany, 'removeErrors')

            selectCompany.siret = '1234'
            await Vue.nextTick()

            expect(selectCompany.removeErrors).toHaveBeenCalled()
        })
    })
})
