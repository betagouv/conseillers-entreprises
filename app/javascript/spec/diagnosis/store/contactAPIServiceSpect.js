import axios from 'axios'
import ContactAPIService from '../../../packs/diagnosis/store/contactAPIService'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactAPIService', () => {

    var contact = {
        "id": 1,
        "full_name": "Monsieur Daron",
        "email": "daron@patron.com",
        "phone_number": "",
        "role": "Patron",
        "company_id": 1
    };

    describe('createContactOnVisit', () => {

        beforeEach(function () {

        });

        describe('with a success', function () {

            beforeEach(function () {
                var promise = Promise.resolve({data: contact});
                spyOn(ContactAPIService, 'send').and.return(promise);

                ContactAPIService.createContact(10, contact);
            });

            it('calls send with the right arguments', function () {
                var config = {
                    method: 'post',
                    url: `/api/visits/10/contacts.json`,
                    data: {
                        contact: {
                            full_name: 'name',
                            email: 'email@google.com',
                            phone_number: '0102030405',
                            role: 'JOB!!'
                        }
                    }
                };
                expect(ContactAPIService.send.calls.count()).toEqual(1);
                expect(ContactAPIService.send.calls.argsFor(0)).toEqual([config]);
            });
        });
    });
});