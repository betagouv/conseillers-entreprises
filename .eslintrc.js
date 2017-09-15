module.exports = {
    extends: [
        'standard',
        'plugin:vue/base',
        'vue'
    ],
    'parserOptions': {
        'ecmaVersion': 6
    },
    rules: {
        // override/add rules' settings here
        'vue/no-invalid-v-if': 'error',
        'quotes': ['error', 'single']
    }
}

