import Vue from 'vue'
import axios from 'axios'
import AddContactModal from '../../packs/diagnosis/addContactModal.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('addContactModal', () => {

    var contact = {
        "id": 1,
        "full_name": "Monsieur Daron",
        "email": "daron@patron.com",
        "phone_number": "",
        "role": "Patron",
        "company_id": 1
    };

    it('sets the correct default data', () => {
        expect(typeof AddContactModal.data).toBe('function');

        const defaultData = AddContactModal.data();
        expect(defaultData.name).toEqual('');
        expect(defaultData.job).toEqual('');
        expect(defaultData.email).toEqual('');
        expect(defaultData.phoneNumber).toEqual('');
        expect(defaultData.errorShowing).toBeFalsy();
    });

    describe('dataCompleted', () => {
        var addContactModal;

        beforeEach(function () {
            var propsData = {'show': true};
            const vueApp = Vue.extend(AddContactModal);
            addContactModal = new vueApp({propsData: propsData});
        });

        it('is true when all data is completed', async function () {
            addContactModal.name = 'Jean Jean';
            addContactModal.job = 'Peon';
            addContactModal.email = 'email@com.fr';
            addContactModal.phoneNumber = '010203040506';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeTruthy();
        });

        it('is true when all data but email is completed', async function () {
            addContactModal.name = 'Jean Jean';
            addContactModal.job = 'Peon';
            addContactModal.email = '';
            addContactModal.phoneNumber = '010203040506';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeTruthy();
        });

        it('is true when all data but phone is completed', async function () {
            addContactModal.name = 'Jean Jean';
            addContactModal.job = 'Peon';
            addContactModal.email = 'email@com.fr';
            addContactModal.phoneNumber = '';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeTruthy();
        });

        it('is false when phone and email are missing', async function () {
            addContactModal.name = 'Jean Jean';
            addContactModal.job = 'Peon';
            addContactModal.email = '';
            addContactModal.phoneNumber = '';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeFalsy();
        });

        it('is false when name is missing', async function () {
            addContactModal.name = '';
            addContactModal.job = 'Peon';
            addContactModal.email = 'email@com.fr';
            addContactModal.phoneNumber = '010203040506';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeFalsy();
        });

        it('is false when job is missing', async function () {
            addContactModal.name = 'Jean Jean';
            addContactModal.job = '';
            addContactModal.email = 'email@com.fr';
            addContactModal.phoneNumber = '010203040506';
            await Vue.nextTick();

            expect(addContactModal.dataCompleted).toBeFalsy();
        });
    });

    describe('clickSaveButton', () => {
        var addContactModal;

        beforeEach(function () {
            var propsData = {'show': true};
            const vueApp = Vue.extend(AddContactModal);
            addContactModal = new vueApp({propsData: propsData});
        });

        describe('when all the data is not completed', () => {

            beforeEach(function () {
                spyOn(addContactModal, 'createContact');
                spyOn(addContactModal, '$emit');
                spyOn(addContactModal, 'dataCompleted').and.returnValue(false);

                addContactModal.saveButtonClicked();
            });

            it('passes the value of error showing at true', () => {
                expect(addContactModal.errorShowing).toBeTruthy();
            });
            it('does not emit the save event nor does it change the show state', () => {
                expect(addContactModal.$emit.calls.count()).toEqual(0);
            });
            it('does not call createContact function', () => {
                expect(addContactModal.createContact.calls.count()).toEqual(0);
            });
        });
    });

    describe('click on close button', () => {
        var addContactModal;

        beforeEach(async function () {
            var propsData = {'show': true};
            const vueApp = Vue.extend(AddContactModal);
            addContactModal = new vueApp({propsData: propsData});

            spyOn(addContactModal, '$emit');

            addContactModal.name = 'Jean Jean';
            addContactModal.job = 'Peon';
            addContactModal.email = 'email@com.fr';
            addContactModal.phoneNumber = '010203040506';
            addContactModal.errorShowing = true;
            await Vue.nextTick();

            addContactModal.closeButtonClicked();
        });

        it('passes the value of error showing at false', async function () {
            await Vue.nextTick();
            expect(addContactModal.errorShowing).toBeFalsy();
        });
        it('does emit the close event and it changes the show state', async function () {
            await Vue.nextTick();
            expect(addContactModal.$emit.calls.count()).toEqual(2);
            expect(addContactModal.$emit.calls.argsFor(0)).toEqual(['update:show', false]);
            expect(addContactModal.$emit.calls.argsFor(1)).toEqual(['close']);
        });
        it('does puts the form data back at default value', async function () {
            await Vue.nextTick();
            expect(addContactModal.name).toEqual('');
            expect(addContactModal.job).toEqual('');
            expect(addContactModal.email).toEqual('');
            expect(addContactModal.phoneNumber).toEqual('');
        });
    });

    xdescribe('| HTTP calls |', () => {
        var contactModal;

        beforeEach(function () {
            var propsData = {'visitId': '0', 'assistanceId': '1', 'expertId': '2'};
            const vueApp = Vue.extend(ContactModal);
            contactModal = new vueApp({propsData: propsData});
        });

        it('has a RequestService object', function () {
            expect(typeof contactModal.requestService).toBe('object');
            expect(typeof contactModal.requestService.send).toBe('function');
            expect(typeof contactModal.requestService.axios).toBe('function');
        });

        describe('create contact', function () {

            beforeEach(function () {
                var promise = Promise.resolve({data: [contact]});
                spyOn(contactModal.requestService, 'axios').and.returnValue(promise);
                contactModal.loadContacts();
            });

            it('calls axios with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: `/api/visits/0/contacts.json`
                };
                expect(contactModal.requestService.axios.calls.count()).toEqual(1);
                expect(contactModal.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the contacts data', async function () {
                await Vue.nextTick();
                expect(contactModal.contacts.length).toEqual(1);
                expect(contactModal.contacts).toEqual([contact]);
            });
        });
    });
});