import companyInputValidation from '../../../../packs/common/companySearch/utils/companyInputValidation'

//for the async function to work
require('babel-core/register')

describe('companyInputValidation', () => {

    describe('validateSiret', () => {

        const validateSiret = companyInputValidation.validateSiret

        it('returns true when the siret is valid', function () {
            const siret = '48245813000010'
            expect(validateSiret(siret)).toBeTruthy()
        })

        it('returns false when the siret is not valid (too short number)', function () {
            const siret = '4824581300'
            expect(validateSiret(siret)).toBeFalsy()
        })

        it('returns false when the siret is not valid (too long number)', function () {
            const siret = '4824581300001032'
            expect(validateSiret(siret)).toBeFalsy()
        })

        it('returns false when the siret is not valid (random text)', function () {
            const siret = 'sdfsdfzef'
            expect(validateSiret(siret)).toBeFalsy()
        })
    })

    describe('validateCounty', () => {

        const validateCounty = companyInputValidation.validateCounty

        it('returns true when the county is valid', function () {
            const county = '75'
            expect(validateCounty(county)).toBeTruthy()
        })

        it('returns false when the county is not valid (too short number)', function () {
            const county = ''
            expect(validateCounty(county)).toBeFalsy()
        })

        it('returns false when the county is not valid (too long number)', function () {
            const county = '7575'
            expect(validateCounty(county)).toBeFalsy()
        })

        it('returns false when the county is not valid (random text)', function () {
            const county = 'sdfsdfzef'
            expect(validateCounty(county)).toBeFalsy()
        })
    })
})