import axios from 'axios'
import ContactAPIService from '../../../packs/diagnosis/store/contactAPIService'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactAPIService', () => {

    const contactData = {
        'full_name': 'Monsieur Daron',
        'email': 'daron@patron.com',
        'phone_number': '0102030405',
        'role': 'Patron',
    };

    const contact = {
        'id': 1,
        'full_name': 'Monsieur Daron',
        'email': 'daron@patron.com',
        'phone_number': '',
        'role': 'Patron',
        'company_id': 1
    };

    describe('createContactOnVisit', () => {

        var returnPromise;

        describe('with a success', function () {

            beforeEach(function () {
                var promise = Promise.resolve({data: contact});
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.createContactOnVisit(10, contactData);
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'post',
                    url: `/api/visits/10/contacts.json`,
                    data: {
                        contact: {
                            full_name: 'Monsieur Daron',
                            email: 'daron@patron.com',
                            phone_number: '0102030405',
                            role: 'Patron'
                        }
                    }
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns a contact', async function () {

                var serviceResponse;
                await returnPromise.then((response) => {
                    serviceResponse = response;
                });
                expect(serviceResponse).toEqual(contact);
            });
        });

        describe('with an error', function () {

            let error = new Error('error');
            beforeEach(function () {
                var promise = Promise.reject(error);
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.createContactOnVisit(10, contactData);
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'post',
                    url: `/api/visits/10/contacts.json`,
                    data: {
                        contact: {
                            full_name: 'Monsieur Daron',
                            email: 'daron@patron.com',
                            phone_number: '0102030405',
                            role: 'Patron'
                        }
                    }
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns an error', async function () {

                var serviceResponse;
                var serviceError;
                await returnPromise
                    .then((response) => {
                        serviceResponse = response;
                    })
                    .catch((error) => {
                        serviceError = error;
                    });

                expect(serviceResponse).toBeUndefined();
                expect(serviceError).toEqual(error);
            });
        });
    });

    describe('getExpertEmailButton', () => {

        var returnPromise;
        const escapedHtmlButton = '&lt;button&gt;BUTTON&lt;/button&gt;';
        const htmlButton = '<button>BUTTON</button>';

        describe('with a success', function () {

            beforeEach(function () {

                var promise = Promise.resolve({data: {html: escapedHtmlButton}});
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.getExpertEmailButton('10', '11', '12');
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: '/api/contacts/contact_button_expert.json',
                    params: {
                        visit_id: '10',
                        assistance_id: '11',
                        expert_id: '12'
                    }
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns a button', async function () {
                var serviceResponse;
                await returnPromise.then((response) => {
                    serviceResponse = response;
                });
                expect(serviceResponse).toEqual(htmlButton);
            });
        });

        describe('with an error', function () {

            const error = new Error('error');

            beforeEach(function () {
                var promise = Promise.reject(error);
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.getExpertEmailButton('10', '11', '12');
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: '/api/contacts/contact_button_expert.json',
                    params: {
                        visit_id: '10',
                        assistance_id: '11',
                        expert_id: '12'
                    }
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns an error', async function () {

                var serviceResponse;
                var serviceError;
                await returnPromise
                    .then((response) => {
                        serviceResponse = response;
                    })
                    .catch((error) => {
                        serviceError = error;
                    });

                expect(serviceResponse).toBeUndefined();
                expect(serviceError).toEqual(error);
            });
        });
    });

    describe('getContacts', () => {

        var returnPromise;

        describe('with a success', function () {

            beforeEach(function () {

                var promise = Promise.resolve({data: [contact]});
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.getContacts('17');
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: `/api/visits/17/contacts.json`
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns a button', async function () {
                var serviceResponse;
                await returnPromise.then((response) => {
                    serviceResponse = response;
                });
                expect(serviceResponse).toEqual([contact]);
            });
        });

        describe('with an error', function () {

            const error = new Error('error');

            beforeEach(function () {
                var promise = Promise.reject(error);
                spyOn(ContactAPIService, 'send').and.returnValue(promise);

                returnPromise = ContactAPIService.getContacts('10');
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: `/api/visits/10/contacts.json`
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });

            it('returns a promise', function () {
                expect(typeof returnPromise.then).toBe('function');
            });

            it('returns an error', async function () {

                var serviceResponse;
                var serviceError;
                await returnPromise
                    .then((response) => {
                        serviceResponse = response;
                    })
                    .catch((error) => {
                        serviceError = error;
                    });

                expect(serviceResponse).toBeUndefined();
                expect(serviceError).toEqual(error);
            });
        });
    });
});