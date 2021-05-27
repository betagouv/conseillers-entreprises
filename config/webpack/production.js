process.env.NODE_ENV = process.env.NODE_ENV || 'production'
const webpack = require('webpack');

const SentryWebpackPlugin = require("@sentry/webpack-plugin");

const environment = require('./environment')

environment.plugins.append('sentry',
  new SentryWebpackPlugin({
    // what folders to scan for sources
    include: ['app/front', 'public/assets', 'assets', 'app/views'],
    // ignore
    ignore: ['node_modules', 'webpack.config.js', 'vendor'],
  })
)

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
