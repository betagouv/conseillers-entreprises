import FormValidator from '../../../packs/step-3/utils/formValidator'

// for the async function to work
require('babel-core/register')

describe('FormValidator', () => {
  describe('validateEmail', () => {
    describe('when the email is valid', () => {
      const emails = [
        'apqsd@oceqs.fr',
        'ggg@gmail.com'
      ]

      for (let email of emails) {
        it('returns true', function () {
          expect(FormValidator.validateEmail(email)).toBeTruthy()
        })
      }
    })

    describe('when the email is not valid', () => {
      const emails = [
        'test',
        'sd@tes'
      ]

      for (let email of emails) {
        it('returns false', function () {
          expect(FormValidator.validateEmail(email)).toBeFalsy()
        })
      }
    })
  })

  describe('validatePhoneNumber', () => {
    describe('when the phonenumber is valid', () => {
      const phoneNumbers = [
        '01 02 03 04 05',
        '06.12.23.45.67',
        '+33612234567'
      ]

      for (let phoneNumber of phoneNumbers) {
        it('returns true for ' + phoneNumber, function () {
          expect(FormValidator.validatePhoneNumber(phoneNumber)).toBeTruthy()
        })
      }
    })

    describe('when the email is not valid', () => {
      const phoneNumbers = [
        '06 12 23',
        '06.12.23',
        '+336122ab34567'
      ]

      for (let phoneNumber of phoneNumbers) {
        it('returns false for ' + phoneNumber, function () {
          expect(FormValidator.validatePhoneNumber(phoneNumber)).toBeFalsy()
        })
      }
    })
  })
})
