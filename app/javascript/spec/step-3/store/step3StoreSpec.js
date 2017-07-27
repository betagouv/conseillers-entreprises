import axios from 'axios'
import Step3Store from '../../../packs/step-3/store/step3Store'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

describe('step3Store', () => {

    describe('getters', () => {

        const getters = Step3Store.getters
        let state

        beforeEach(() => {
            state = {
                isRequestInProgress: false,
                name: '',
                job: '',
                email: '',
                phoneNumber: '',
                visitDate: ''
            }
        })

        describe('isNameCompleted', function () {

            it('returns false when empty', function () {
                state.name = ''
                expect(getters.isNameCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.name = 'Jacques'
                expect(getters.isNameCompleted(state)).toBeTruthy()
            })
        })

        describe('isJobCompleted', function () {

            it('returns false when empty', function () {
                state.job = ''
                expect(getters.isJobCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.job = 'not empty'
                expect(getters.isJobCompleted(state)).toBeTruthy()
            })
        })

        describe('areContactDetailsCompleted', function () {

            it('returns false when both are empty', function () {
                state.email = ''
                state.phoneNumber = ''
                expect(getters.areContactDetailsCompleted(state)).toBeFalsy()
            })

            it('returns true when email is not empty', function () {
                state.email = 'not empty'
                state.phoneNumber = ''
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })

            it('returns true when phoneNumber is not empty', function () {
                state.email = ''
                state.phoneNumber = 'not empty'
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })

            it('returns true when both are not empty', function () {
                state.email = 'not empty'
                state.phoneNumber = 'not empty'
                expect(getters.areContactDetailsCompleted(state)).toBeTruthy()
            })
        })

        describe('isFormCompleted', function () {

            it('returns false when at least one of the completion getters is false', function () {
                getters.isNameCompleted = false
                getters.isJobCompleted = true
                getters.areContactDetailsCompleted = true

                expect(getters.isFormCompleted(state, getters)).toBeFalsy()
            })

            it('returns true when all of the completion getters are true', function () {
                getters.isNameCompleted = true
                getters.isJobCompleted = true
                getters.areContactDetailsCompleted = true

                expect(getters.isFormCompleted(state, getters)).toBeTruthy()
            })
        })

        describe('isDateCompleted', function () {

            it('returns false when empty', function () {
                state.visitDate = ''
                expect(getters.isDateCompleted(state)).toBeFalsy()
            })

            it('returns true when not empty', function () {
                state.visitDate = '10/20/30'
                expect(getters.isDateCompleted(state)).toBeTruthy()
            })
        })
    })

    describe('mutations', () => {

        const mutations = Step3Store.mutations

        describe('REQUEST_IN_PROGRESS', function () {

            it('updates the isDiagnosisRequestUnderWay', function () {
                const state = {isRequestInProgress: false}
                mutations.REQUEST_IN_PROGRESS(state, true)
                expect(state.isRequestInProgress).toBeTruthy()
            })
        })

        describe('CONTACT_NAME', function () {

            it('updates the name', function () {
                const state = {name: 'whatever'}
                mutations.CONTACT_NAME(state, 'Jean-Jacques')
                expect(state.name).toEqual('Jean-Jacques')
            })
        })

        describe('CONTACT_JOB', function () {

            it('updates the name', function () {
                const state = {job: 'jobless'}
                mutations.CONTACT_JOB(state, 'random job')
                expect(state.job).toEqual('random job')
            })
        })

        describe('CONTACT_EMAIL', function () {

            it('updates the name', function () {
                const state = {email: 'no email'}
                mutations.CONTACT_EMAIL(state, 'email@email.com')
                expect(state.email).toEqual('email@email.com')
            })
        })

        describe('CONTACT_PHONE_NUMBER', function () {

            it('updates the name', function () {
                const state = {phoneNumber: 'no number'}
                mutations.CONTACT_PHONE_NUMBER(state, '060606060606')
                expect(state.phoneNumber).toEqual('060606060606')
            })
        })

        describe('VISIT_DATE', function () {

            it('updates the date', function () {
                const state = {visitDate: 'no date'}
                mutations.VISIT_DATE(state, '01/04/2029')
                expect(state.visitDate).toEqual('01/04/2029')
            })
        })

        describe('FORM_FIELDS_ERROR', function () {

            it('updates the showFormFieldsError boolean', function () {
                const state = {showFormFieldErrors: false}
                mutations.FORM_FIELDS_ERROR(state, true)
                expect(state.showFormFieldErrors).toBeTruthy()
            })
        })

        xdescribe('FORM_ERROR_MESSAGE', function () {

            it('updates the date', function () {
                const state = {showFormErrorMessage: false}
                mutations.FORM_ERROR_MESSAGE(state, true)
                expect(state.showFormErrorMessage).toBeTruthy()
            })
        })
    })

    describe('actions', () => {
    })
})
