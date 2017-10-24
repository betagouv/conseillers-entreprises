export default {
  validateEmail: function (email) {
    const regex = /^.+@.+\..+$/

    return regex.test(email)
  },

  validatePhoneNumber: function (phoneNumber) {
    const regex = /^[0-9+. ]{10,}$/

    return regex.test(phoneNumber)
  }
}
