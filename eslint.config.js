const {
    defineConfig,
    globalIgnores,
} = require("eslint/config");

const globals = require("globals");
const js = require("@eslint/js");

const {
    FlatCompat,
} = require("@eslint/eslintrc");

const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

module.exports = defineConfig([{
    languageOptions: {
        globals: {
            ...globals.browser,
            require: true,
            _paq: true,
            Highcharts: true,
        },
    },

    extends: compat.extends("eslint:recommended"),
    rules: {},
}, globalIgnores(
    ["app/front/javascripts/application/controllers/autocomplete_controller.js"],
), {

    languageOptions: {
        globals: {
            ...globals.node,
        },
    },
}]);
