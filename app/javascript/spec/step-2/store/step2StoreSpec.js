import axios from 'axios'
import Step2Store from '../../../packs/step-2/store/step2Store'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContactStore', () => {

    describe('mutations', () => {

        var mutations = Step2Store.mutations;

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

        describe('DIAGNOSTIC_REQUEST_UNDERWAY', function () {

            it('updates the isDiagnosisRequestUnderWay', function () {
                const state = {isDiagnosisRequestUnderWay: false};
                mutations.DIAGNOSTIC_REQUEST_UNDERWAY(state, true);
                expect(state.isDiagnosisRequestUnderWay).toBeTruthy();
            });
        });
    });

    describe('actions', () => {

        var actions = Step2Store.actions;

        var step2StoreAPIServiceMock = {
            udpateDiagnosisContent: () => {
            }
        };
        var apiServiceContext = function (commit, state) {
            return {
                commit: commit,
                state: state,
                step2APIServiceDependency: step2StoreAPIServiceMock
            };
        };

        describe('udpateDiagnosisContent', function () {

            var commit;
            const state = {
                diagnosisContent: 'content !',
                diagnosisId: 12,
                isDiagnosisRequestUnderWay: false
            };

            describe('when api call is a success', function () {

                const positivePromise = Promise.resolve(true);

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'udpateDiagnosisContent').and.returnValue(positivePromise);
                    commit = jasmine.createSpy();
                });

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));
                    expect(typeof promise.then).toBe('function')
                });

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));

                    expect(step2StoreAPIServiceMock.udpateDiagnosisContent.calls.count()).toEqual(1);
                    expect(step2StoreAPIServiceMock.udpateDiagnosisContent.calls.argsFor(0)).toEqual([12, 'content !']);
                });

                it('calls commit DIAGNOSTIC_REQUEST_UNDERWAY with true at start of action', function () {
                    actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));

                    expect(commit.calls.count()).toEqual(1);
                    expect(commit.calls.argsFor(0)).toEqual([
                        'DIAGNOSTIC_REQUEST_UNDERWAY',
                        true
                    ]);
                });

                it('calls commit DIAGNOSTIC_REQUEST_UNDERWAY with false at end of action', async function () {
                    await actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));

                    expect(commit.calls.count()).toEqual(2);
                    expect(commit.calls.argsFor(1)).toEqual([
                        'DIAGNOSTIC_REQUEST_UNDERWAY',
                        false
                    ]);
                });
            });

            describe('when api call throws an error', function () {

                const apiError = new Error('error :-(');
                const negativePromise = Promise.reject(apiError);

                beforeEach(function () {
                    spyOn(step2StoreAPIServiceMock, 'udpateDiagnosisContent').and.returnValue(negativePromise);
                    commit = jasmine.createSpy();
                });

                it('returns a promise', function () {
                    var promise = actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));
                    expect(typeof promise.then).toBe('function')
                });

                it('calls contactAPIService with the diagnosisId and the content', async function () {
                    await actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));

                    expect(step2StoreAPIServiceMock.udpateDiagnosisContent.calls.count()).toEqual(1);
                    expect(step2StoreAPIServiceMock.udpateDiagnosisContent.calls.argsFor(0)).toEqual([12, 'content !']);
                });

                it('calls commit DIAGNOSTIC_REQUEST_UNDERWAY with true at start of action', function () {
                    actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state));

                    expect(commit.calls.count()).toEqual(1);
                    expect(commit.calls.argsFor(0)).toEqual([
                        'DIAGNOSTIC_REQUEST_UNDERWAY',
                        true
                    ]);
                });

                it('calls commit DIAGNOSTIC_REQUEST_UNDERWAY with false at end of action', async function () {
                    await actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state)).catch( () => {});

                    expect(commit.calls.count()).toEqual(2);
                    expect(commit.calls.argsFor(1)).toEqual([
                        'DIAGNOSTIC_REQUEST_UNDERWAY',
                        false
                    ]);
                });

                it('propagtes the error', async function () {
                    var catchedError;
                    await actions.sendDiagnosisContentUdpate(apiServiceContext(commit, state))
                        .catch( (error) => {
                            catchedError = error;
                        });
                    expect(catchedError).toEqual(apiError);
                });
            });
        });
    });
});
