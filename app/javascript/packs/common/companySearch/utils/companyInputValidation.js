export default {
  validateSiret: function (siret) {
    return siret.match(/^[0-9]{14}$/)
  },
  validateCounty: function (county) {
    return county.match(/^[0-9]{1,3}$/)
  }
}
