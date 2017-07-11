import Vue from 'vue'
import axios from 'axios'
import ContactModal from '../../packs/diagnosis/contactModal.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactModal', () => {

    var contact = {
        "id": 1,
        "full_name": "Monsieur Daron",
        "email": "daron@patron.com",
        "phone_number": "",
        "role": "Patron",
        "company_id": 1
    };

    it('has a created hook', () => {
        expect(typeof ContactModal.mounted).toBe('function')
    });

    it('sets the correct default data', () => {
        expect(typeof ContactModal.data).toBe('function');

        const defaultData = ContactModal.data();
        expect(defaultData.isLoading).toBeFalsy();
        expect(defaultData.contacts).toEqual([]);
    });

    describe('| life cycle |', () => {
        var contactModal;

        beforeEach(function () {
            var propsData = {'visitId': '0', 'assistanceId': '1', 'expertId': '2'};
            const vueApp = Vue.extend(ContactModal);
            contactModal = new vueApp({propsData: propsData});
        });

        describe('right after the modal is mounted', function () {

            beforeEach(function () {
                spyOn(contactModal, 'loadContacts');
                contactModal.$mount();
            });

            it('calls loadContacts', function () {
                expect(contactModal.loadContacts.calls.count()).toEqual(1);
            });
        });

        describe('after the contacts are updated', function () {
            beforeEach(function () {
                spyOn(contactModal, 'getExpertButton').and.callFake(function() {
                });
                contactModal.contacts = [contact];
            });

            it('calls getExpertButton if there is at least one contact', function (done) {
                setTimeout(function () {
                    expect(contactModal.getExpertButton.calls.count()).toEqual(1);
                    done(); // call this to finish off the it block
                }, 50);
            });
        });
    });

    describe('| HTTP calls |', () => {
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

        describe('calling loadContacts', function () {

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

        describe('calling getExpertButton', function () {

            var escapedHtmlButton = '&lt;button&gt;BUTTON&lt;/button&gt;';
            var htmlButton = '<button>BUTTON</button>';


            beforeEach(function () {
                var promise = Promise.resolve({data: {html: escapedHtmlButton}});
                spyOn(contactModal.requestService, 'axios').and.returnValue(promise);
                contactModal.getExpertButton();
            });

            it('calls axios with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: '/api/contacts/contact_button_expert.json',
                    params: {
                        visit_id: '0',
                        assistance_id: '1',
                        expert_id: '2'
                    }
                };
                expect(contactModal.requestService.axios.calls.count()).toEqual(1);
                expect(contactModal.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the button html with the decoded data', async function () {
                await Vue.nextTick();
                expect(contactModal.expertButton).toEqual(htmlButton);
            });
        });
    });
});