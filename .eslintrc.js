module.exports = {
  env: {
    browser: true,
    es2021: true,
    jquery: true,
  },
  extends: ["eslint:recommended"],
  parser: "babel-eslint",
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  rules: {},
  globals: {
    $: true,
    require: true,
    _paq: true,
    Highcharts: true
  },
  overrides: [
    {
      files: ["config/webpack/**/*.js", "babel.config.js", "postcss.config.js"],
      env: {
        node: true,
      },
    },
  ],
};
