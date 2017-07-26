import Vue from 'vue'
import SelectCompany from '../../packs/step-1/selectCompany.vue.erb'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

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
})