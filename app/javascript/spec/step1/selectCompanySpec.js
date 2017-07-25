import First from '../../packs/step1/first.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('selectCompany', () => {
    it('sets the correct default data', () => {
        expect(typeof First.data).toBe('function');

        const defaultData = First.data();
        expect(defaultData.siret).toEqual('');
        expect(defaultData.isLoading).toBeFalsy();
        expect(defaultData.siretFormatError).toBeFalsy();
        expect(defaultData.companyNotFoundError).toBeFalsy();
    });
});