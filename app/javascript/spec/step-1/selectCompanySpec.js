import SelectCompany from '../../packs/step-1/selectCompany.vue.erb'

//for the async function to work
require("babel-core/register");
require("babel-polyfill");

describe('selectCompany', () => {
    it('sets the correct default data', () => {
        expect(typeof SelectCompany.data).toBe('function');

        const defaultData = SelectCompany.data();
        expect(defaultData.siret).toEqual('');
        expect(defaultData.isLoading).toBeFalsy();
        expect(defaultData.siretFormatError).toBeFalsy();
        expect(defaultData.companyNotFoundError).toBeFalsy();
    });
});