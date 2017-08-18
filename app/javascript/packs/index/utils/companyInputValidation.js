export default {
    validateSiret: function (siret) {
        return siret.match(/^[0-9]{14}$/)
    }
}