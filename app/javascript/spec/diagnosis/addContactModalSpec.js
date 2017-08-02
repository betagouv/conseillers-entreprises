import Vue from 'vue'
import axios from 'axios'
import AddContactModal from '../../packs/diagnosis/addContactModal.vue.erb'

//for the async function to work
require('babel-core/register')
require('babel-polyfill')

describe('addContactModal', () => {

    var contact = {
        'id': 1,
        'full_name': 'Monsieur Daron',
        'email': 'daron@patron.com',
        'phone_number': '',
        'role': 'Patron',
        'company_id': 1
    }

    it('sets the correct default data', () => {
        expect(typeof AddContactModal.data).toBe('function')

        const defaultData = AddContactModal.data()
        expect(defaultData.name).toEqual('')
        expect(defaultData.job).toEqual('')
        expect(defaultData.email).toEqual('')
        expect(defaultData.phoneNumber).toEqual('')
        expect(defaultData.errorShowing).toBeFalsy()
        expect(defaultData.showErrorMessage).toBeFalsy()
        expect(defaultData.isSaving).toBeFalsy()
    })

    describe('dataCompleted', () => {
        var addContactModal

        beforeEach(function () {
            var propsData = {'show': true, 'visitId': '10'}
            const vueApp = Vue.extend(AddContactModal)
            addContactModal = new vueApp({propsData: propsData})
        })

        it('is true when all data is completed', async function () {
            addContactModal.name = 'Jean Jean'
            addContactModal.job = 'Peon'
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = '010203040506'
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeTruthy()
        })

        it('is true when all data but email is completed', async function () {
            addContactModal.name = 'Jean Jean'
            addContactModal.job = 'Peon'
            addContactModal.email = ''
            addContactModal.phoneNumber = '010203040506'
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeTruthy()
        })

        it('is true when all data but phone is completed', async function () {
            addContactModal.name = 'Jean Jean'
            addContactModal.job = 'Peon'
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = ''
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeTruthy()
        })

        it('is false when phone and email are missing', async function () {
            addContactModal.name = 'Jean Jean'
            addContactModal.job = 'Peon'
            addContactModal.email = ''
            addContactModal.phoneNumber = ''
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeFalsy()
        })

        it('is false when name is missing', async function () {
            addContactModal.name = ''
            addContactModal.job = 'Peon'
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = '010203040506'
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeFalsy()
        })

        it('is false when job is missing', async function () {
            addContactModal.name = 'Jean Jean'
            addContactModal.job = ''
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = '010203040506'
            await Vue.nextTick()

            expect(addContactModal.dataCompleted).toBeFalsy()
        })
    })

    describe('click on dimmer', () => {
        var addContactModal

        beforeEach(async function () {
            var propsData = {'show': true, 'visitId': '10'}
            const vueApp = Vue.extend(AddContactModal)
            addContactModal = new vueApp({propsData: propsData})

            spyOn(addContactModal, '$emit')

            addContactModal.name = 'Jean Jean'
            addContactModal.job = ''
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = ''
            addContactModal.errorShowing = true
            await Vue.nextTick()
        })

        describe('when the dimmer is not the event target', () => {

            beforeEach(function () {
                var className = 'ui right labeled icon button'
                var eventMock = {target: {className: className}}

                addContactModal.dimmerClicked(eventMock)
            })

            it('does not modify the value of errorShowing', async function () {
                await Vue.nextTick()
                expect(addContactModal.errorShowing).toBeTruthy()
            })

            it('does not emit the close event nor change the show state', async function () {
                await Vue.nextTick()
                expect(addContactModal.$emit.calls.count()).toEqual(0)
            })

            it('does not puts the form data back at default value', async function () {
                await Vue.nextTick()
                expect(addContactModal.name).toEqual('Jean Jean')
                expect(addContactModal.job).toEqual('')
                expect(addContactModal.email).toEqual('email@com.fr')
                expect(addContactModal.phoneNumber).toEqual('')
            })
        })

        describe('when the dimmer is the event target and that no saving action is under way', () => {

            beforeEach(async function () {
                addContactModal.isSaving = false
                await Vue.nextTick()

                var className = 'ui dimmer'
                var eventMock = {target: {className: className}}

                addContactModal.dimmerClicked(eventMock)
            })

            it('does not modify the value of errorShowing', async function () {
                await Vue.nextTick()
                expect(addContactModal.errorShowing).toBeTruthy()
            })

            it('does emits a close event and changes the show state', async function () {
                await Vue.nextTick()
                expect(addContactModal.$emit.calls.count()).toEqual(2)
                expect(addContactModal.$emit.calls.argsFor(0)).toEqual(['update:show', false])
                expect(addContactModal.$emit.calls.argsFor(1)).toEqual(['close'])
            })

            it('does not puts the form data back at default value', async function () {
                await Vue.nextTick()
                expect(addContactModal.name).toEqual('Jean Jean')
                expect(addContactModal.job).toEqual('')
                expect(addContactModal.email).toEqual('email@com.fr')
                expect(addContactModal.phoneNumber).toEqual('')
            })
        })

        describe('when the dimmer is the event target and that a saving action is under way', () => {

            beforeEach(async function () {
                addContactModal.isSaving = true
                await Vue.nextTick()

                var className = 'ui dimmer'
                var eventMock = {target: {className: className}}

                addContactModal.dimmerClicked(eventMock)
            })

            it('does not modify the value of errorShowing', async function () {
                await Vue.nextTick()
                expect(addContactModal.errorShowing).toBeTruthy()
            })

            it('does not emit the close event nor change the show state', async function () {
                await Vue.nextTick()
                expect(addContactModal.$emit.calls.count()).toEqual(0)
            })

            it('does not puts the form data back at default value', async function () {
                await Vue.nextTick()
                expect(addContactModal.name).toEqual('Jean Jean')
                expect(addContactModal.job).toEqual('')
                expect(addContactModal.email).toEqual('email@com.fr')
                expect(addContactModal.phoneNumber).toEqual('')
            })
        })
    })

    describe('click on save button', () => {
        var addContactModal

        beforeEach(function () {
            var propsData = {'show': true, 'visitId': '10'}
            const vueApp = Vue.extend(AddContactModal)
            addContactModal = new vueApp({propsData: propsData})
        })

        describe('when all the data is not completed', () => {

            beforeEach(function () {
                spyOn(addContactModal, 'createContact')
                spyOn(addContactModal, '$emit')
                spyOn(addContactModal, 'dataCompleted').and.returnValue(false)

                addContactModal.saveButtonClicked()
            })

            it('passes the value of error showing at true', () => {
                expect(addContactModal.errorShowing).toBeTruthy()
            })

            it('does not emit the save event nor does it change the show state', () => {
                expect(addContactModal.$emit.calls.count()).toEqual(0)
            })

            it('does not call createContact function', () => {
                expect(addContactModal.createContact.calls.count()).toEqual(0)
            })
        })

        describe('when all the data is completed', () => {

            function sleep(time) {
                return new Promise((resolve) => setTimeout(resolve, time))
            }

            beforeEach(async function () {
                var promise = Promise.resolve(true)

                spyOn(addContactModal, 'dataCompleted').and.returnValue(true)
                spyOn(addContactModal, 'createContact').and.returnValue(promise)
                spyOn(addContactModal, '$emit')
                spyOn(addContactModal, 'clearForm')

                addContactModal.name = 'Jean Jean'
                addContactModal.job = 'Peon'
                addContactModal.email = 'email@com.fr'
                addContactModal.phoneNumber = '010203040506'

                await Vue.nextTick()

                addContactModal.saveButtonClicked()
            })

            it('emits the save event and it changes the show state', async function () {
                await sleep(10)

                expect(addContactModal.$emit.calls.count()).toEqual(2)
                expect(addContactModal.$emit.calls.argsFor(0)).toEqual(['update:show', false])
                expect(addContactModal.$emit.calls.argsFor(1)).toEqual(['save'])
            })

            it('calls the clear form function', async function () {
                await sleep(10)

                expect(addContactModal.clearForm.calls.count()).toEqual(1)
            })

            it('calls createContact function', async function () {
                await sleep(10)

                const contactData = {
                    full_name: 'Jean Jean',
                    email: 'email@com.fr',
                    phone_number: '010203040506',
                    role: 'Peon'
                }
                expect(addContactModal.createContact.calls.count()).toEqual(1)
                expect(addContactModal.createContact.calls.argsFor(0)).toEqual([contactData])
            })
        })
    })

    describe('click on close button', () => {
        var addContactModal

        beforeEach(async function () {
            var propsData = {'show': true, 'visitId': '10'}
            const vueApp = Vue.extend(AddContactModal)
            addContactModal = new vueApp({propsData: propsData})

            spyOn(addContactModal, '$emit')

            addContactModal.name = 'Jean Jean'
            addContactModal.job = 'Peon'
            addContactModal.email = 'email@com.fr'
            addContactModal.phoneNumber = '010203040506'
            addContactModal.errorShowing = true
            await Vue.nextTick()

            addContactModal.closeButtonClicked()
        })

        it('passes the value of error showing at false', async function () {
            await Vue.nextTick()
            expect(addContactModal.errorShowing).toBeFalsy()
        })

        it('does emit the close event and it changes the show state', async function () {
            await Vue.nextTick()
            expect(addContactModal.$emit.calls.count()).toEqual(2)
            expect(addContactModal.$emit.calls.argsFor(0)).toEqual(['update:show', false])
            expect(addContactModal.$emit.calls.argsFor(1)).toEqual(['close'])
        })

        it('does puts the form data back at default value', async function () {
            await Vue.nextTick()
            expect(addContactModal.name).toEqual('')
            expect(addContactModal.job).toEqual('')
            expect(addContactModal.email).toEqual('')
            expect(addContactModal.phoneNumber).toEqual('')
        })
    })
})