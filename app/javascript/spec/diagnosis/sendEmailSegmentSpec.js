import Vue from 'vue'
import axios from 'axios'
import SendEmailSegment from '../../packs/diagnosis/sendEmailSegment.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('sendEmailSegment', () => {

    var contact = {
        "id": 1,
        "full_name": "Monsieur Daron",
        "email": "daron@patron.com",
        "phone_number": "",
        "role": "Patron",
        "company_id": 1
    };

    it('has a created hook', () => {
        expect(typeof SendEmailSegment.mounted).toBe('function')
    });

    it('sets the correct default data', () => {
        expect(typeof SendEmailSegment.data).toBe('function');

        const defaultData = SendEmailSegment.data();
        expect(defaultData.isLoading).toBeFalsy();
        expect(defaultData.contacts).toEqual([]);
    });

    describe('| life cycle |', () => {
        var sendEmailSegment;

        beforeEach(function () {
            var propsData = {'visitId': '0', 'assistanceId': '1', 'expertId': '2'};
            const vueApp = Vue.extend(SendEmailSegment);
            sendEmailSegment = new vueApp({propsData: propsData});
        });

        describe('right after the modal is mounted', function () {

            beforeEach(function () {
                spyOn(sendEmailSegment, 'loadContacts');
                sendEmailSegment.$mount();
            });

            it('calls loadContacts', function () {
                expect(sendEmailSegment.loadContacts.calls.count()).toEqual(1);
            });
        });

        describe('after the contacts are updated', function () {
            beforeEach(function () {
                spyOn(sendEmailSegment, 'getExpertButton').and.callFake(function() {
                });
                sendEmailSegment.contacts = [contact];
            });

            it('calls getExpertButton if there is at least one contact', function (done) {
                setTimeout(function () {
                    expect(sendEmailSegment.getExpertButton.calls.count()).toEqual(1);
                    done(); // call this to finish off the it block
                }, 50);
            });
        });
    });

    describe('| HTTP calls |', () => {
        var sendEmailSegment;

        beforeEach(function () {
            var propsData = {'visitId': '0', 'assistanceId': '1', 'expertId': '2'};
            const vueApp = Vue.extend(SendEmailSegment);
            sendEmailSegment = new vueApp({propsData: propsData});
        });

        it('has a RequestService object', function () {
            expect(typeof sendEmailSegment.requestService).toBe('object');
            expect(typeof sendEmailSegment.requestService.send).toBe('function');
            expect(typeof sendEmailSegment.requestService.axios).toBe('function');
        });

        describe('calling loadContacts', function () {

            beforeEach(function () {
                var promise = Promise.resolve({data: [contact]});
                spyOn(sendEmailSegment.requestService, 'axios').and.returnValue(promise);
                sendEmailSegment.loadContacts();
            });

            it('calls axios with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: `/api/visits/0/contacts.json`
                };
                expect(sendEmailSegment.requestService.axios.calls.count()).toEqual(1);
                expect(sendEmailSegment.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the contacts data', async function () {
                await Vue.nextTick();
                expect(sendEmailSegment.contacts.length).toEqual(1);
                expect(sendEmailSegment.contacts).toEqual([contact]);
            });
        });

        describe('calling getExpertButton', function () {

            var escapedHtmlButton = '&lt;button&gt;BUTTON&lt;/button&gt;';
            var htmlButton = '<button>BUTTON</button>';


            beforeEach(function () {
                var promise = Promise.resolve({data: {html: escapedHtmlButton}});
                spyOn(sendEmailSegment.requestService, 'axios').and.returnValue(promise);
                sendEmailSegment.getExpertButton();
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
                expect(sendEmailSegment.requestService.axios.calls.count()).toEqual(1);
                expect(sendEmailSegment.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the button html with the decoded data', async function () {
                await Vue.nextTick();
                expect(sendEmailSegment.expertButton).toEqual(htmlButton);
            });
        });
    });
});