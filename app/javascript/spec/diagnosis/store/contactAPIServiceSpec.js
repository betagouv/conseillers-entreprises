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
});