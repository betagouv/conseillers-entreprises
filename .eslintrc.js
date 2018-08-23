module.exports = {
  extends: [
    'standard',
    'plugin:vue/recommended'
  ],
  'parserOptions': {
    'ecmaVersion': 2017
  },
  rules: {
    // override/add rules' settings here
    'quotes': ['error', 'single'],
    'indent': ['error', 2]
  }
}
