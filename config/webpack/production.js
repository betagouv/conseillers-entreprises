process.env.NODE_ENV = process.env.NODE_ENV || 'production'
const webpack = require('webpack');

const environment = require('./environment')

// Config speciique pour eviter une erreur CSP
// cf https://github.com/webpack/webpack/issues/5627#issuecomment-394309966
const extraConfig = {
  node: {
    global: false,
  },
  plugins: [
    new webpack.DefinePlugin({
      global: "window", // Placeholder for global used in any node_modules
    }),
  ],
};

environment.config.merge(extraConfig);

module.exports = environment.toWebpackConfig()
