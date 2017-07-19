import axios from 'axios'
import ContactStore from '../../../packs/diagnosis/store/contactStore'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactStore', () => {

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

    describe('mutations', () => {

        var mutations = ContactStore.mutations;

        describe('CONTACT_REQUEST_UNDERWAY', function () {

            it('updates the isContactRequestUnderWay state', function () {
                const state = {isContactRequestUnderWay: false};
                mutations.CONTACT_REQUEST_UNDERWAY(state, {isContactRequestUnderWay: true});
                expect(state.isContactRequestUnderWay).toBeTruthy();
            });
        });

        describe('CONTACT', function () {

            it('updates the contact data', function () {
                const state = {contact: undefined};
                mutations.CONTACT(state, {contact: contact});
                expect(state.contact).toEqual(contact);
            });
        });

        describe('VISIT_ID', function () {

            it('updates the visitId data', function () {
                const state = {visitId: undefined};
                mutations.VISIT_ID(state, {visitId: 10});
                expect(state.visitId).toEqual(10);
            });
        });
    });

    describe('actions', () => {

        var actions = ContactStore.actions;

        var contactAPIServiceMock = {
            createContactOnVisit: () => {
                var promise = Promise.resolve(contact);
                return promise;
            },
            getContacts: () => {
                var promise = Promise.resolve([contact]);
                return promise;
            }
        };
        var createContactContext = function (commit, state) {
            return {
                commit: commit,
                state: state,
                contactAPIServiceDependency: contactAPIServiceMock
            };
        };

        describe('createContact', function () {

            var commit;
            var state;

            beforeEach(function () {
                state = {visitId: 7, isContactRequestUnderWay: false};
                spyOn(contactAPIServiceMock, 'createContactOnVisit').and.callThrough();
                commit = jasmine.createSpy();
            });

            it('returns a promise', function () {
                var promise = actions.createContact(createContactContext(commit, state), contactData);
                expect(typeof promise.then).toBe('function')
            });

            it('calls contactAPIService with the visitId and the contact data', async function () {
                await actions.createContact(createContactContext(commit, state), contactData);

                expect(contactAPIServiceMock.createContactOnVisit.calls.count()).toEqual(1);
                expect(contactAPIServiceMock.createContactOnVisit.calls.argsFor(0)).toEqual([7, contactData]);
            });

            it('calls commit CONTACT with the contact data', async function () {
                await actions.createContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(3);
                expect(commit.calls.argsFor(1)).toEqual(['CONTACT', {contact: contact}]);
            });

            it('calls commit CONTACT_REQUEST_UNDERWAY with true at start of action', function () {
                actions.createContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(1);
                expect(commit.calls.argsFor(0)).toEqual([
                    'CONTACT_REQUEST_UNDERWAY',
                    {isContactRequestUnderWay: true}
                ]);
            });

            it('calls commit CONTACT_REQUEST_UNDERWAY with false at end of action', async function () {
                await actions.createContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(3);
                expect(commit.calls.argsFor(2)).toEqual([
                    'CONTACT_REQUEST_UNDERWAY',
                    {isContactRequestUnderWay: false}
                ]);
            });
        });

        describe('getContact', function () {

            var commit;
            var state;

            beforeEach(function () {
                state = {visitId: 7, isContactRequestUnderWay: false};
                spyOn(contactAPIServiceMock, 'getContacts').and.callThrough();
                commit = jasmine.createSpy();
            });

            it('returns a promise', function () {
                var promise = actions.getContact(createContactContext(commit, state), contactData);
                expect(typeof promise.then).toBe('function')
            });

            it('calls contactAPIService with the visitId and the contact data', async function () {
                await actions.getContact(createContactContext(commit, state), contactData);

                expect(contactAPIServiceMock.getContacts.calls.count()).toEqual(1);
                expect(contactAPIServiceMock.getContacts.calls.argsFor(0)).toEqual([7]);
            });

            it('calls commit CONTACT with the contact data', async function () {
                await actions.getContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(3);
                expect(commit.calls.argsFor(1)).toEqual(['CONTACT', {contact: contact}]);
            });

            it('calls commit CONTACT_REQUEST_UNDERWAY with true at start of action', function () {
                actions.getContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(1);
                expect(commit.calls.argsFor(0)).toEqual([
                    'CONTACT_REQUEST_UNDERWAY',
                    {isContactRequestUnderWay: true}
                ]);
            });

            it('calls commit CONTACT_REQUEST_UNDERWAY with false at end of action', async function () {
                await actions.createContact(createContactContext(commit, state), contactData);

                expect(commit.calls.count()).toEqual(3);
                expect(commit.calls.argsFor(2)).toEqual([
                    'CONTACT_REQUEST_UNDERWAY',
                    {isContactRequestUnderWay: false}
                ]);
            });
        });
    });
});