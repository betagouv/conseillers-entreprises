import axios from 'axios'
import ContactStore from '../../../packs/step-2/store/step2Store'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactStore', () => {

    describe('mutations', () => {

        var mutations = ContactStore.mutations;

        describe('DIAGNOSTIC_ID', function () {

            it('updates the diagnosisID', function () {
                const state = {diagnosisId: undefined};
                mutations.DIAGNOSTIC_ID(state, '12');
                expect(state.diagnosisId).toEqual('12');
            });
        });

        describe('DIAGNOSTIC_CONTENT', function () {

            it('updates the diagnosis content', function () {
                const state = {diagnosisContent: ""};
                mutations.DIAGNOSTIC_CONTENT(state, "Random Content");
                expect(state.diagnosisContent).toEqual("Random Content");
            });
        });

        xdescribe('DIAGNOSTIC_REQUEST_UNDERWAY', function () {

            it('updates the isDiagnosisRequestUnderWay', function () {
                const state = {isDiagnosisRequestUnderWay: false};
                mutations.DIAGNOSTIC_REQUEST_UNDERWAY(state, true);
                expect(state.isDiagnosisRequestUnderWay).toBeTruthy();
            });
        });
    });

    xdescribe('actions', () => {

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