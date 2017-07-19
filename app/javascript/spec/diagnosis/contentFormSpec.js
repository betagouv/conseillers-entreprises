import Vue from 'vue'
import axios from 'axios'
import ContentForm from '../../packs/diagnosis/contentForm.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('ContentForm', () => {
    it('has a created hook', () => {
        expect(typeof ContentForm.mounted).toBe('function')
    });

    it('sets the correct default data', () => {
        expect(typeof ContentForm.data).toBe('function');

        const defaultData = ContentForm.data();
        expect(defaultData.diagnosis.content).toEqual('');
        expect(defaultData.disabled).toBe(true);
    });

    describe('| HTTP calls |', () => {
        var contentForm;
        var promise = Promise.resolve({data: {content: 'content test'}});

        beforeEach(function () {
            var propsData = {'diagnosis_id': 0};
            const vueApp = Vue.extend(ContentForm);
            contentForm = new vueApp({propsData: propsData});

            spyOn(contentForm.requestService, 'axios').and.returnValue(promise);
        });

        it('has a RequestService object', function () {
            expect(typeof contentForm.requestService).toBe('object');
            expect(typeof contentForm.requestService.send).toBe('function');
            expect(typeof contentForm.requestService.axios).toBe('function');
        });

        describe('calling getDiagnosis', function () {

            beforeEach(function () {
                contentForm.getDiagnosis();
            });

            it('calls axios with the right arguments', function () {
                var config = {
                    method: 'get',
                    url: `/api/diagnoses/0.json`,
                };
                expect(contentForm.requestService.axios.calls.count()).toEqual(1);
                expect(contentForm.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the diagnostic data', async function () {
                await Vue.nextTick();
                expect(contentForm.diagnosis.content).toEqual('content test');
            });
        });

        describe('calling updateDiagnosis', function () {

            beforeEach(function () {
                contentForm.diagnosis.content = 'update test';
                contentForm.updateDiagnosis();
            });

            it('calls axios with the right arguments', function () {
                var config = {
                    method: 'patch',
                    url: `/api/diagnoses/0`,
                    data: {
                        diagnosis: {
                            content: 'update test'
                        }
                    }
                };
                expect(contentForm.requestService.axios.calls.count()).toEqual(1);
                expect(contentForm.requestService.axios.calls.argsFor(0)).toEqual([config]);
            });

            it('updates the diagnostic data', async function () {
                await Vue.nextTick();
                expect(contentForm.diagnosis.content).toEqual('content test');
            });
        });
    });
});