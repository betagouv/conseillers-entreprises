process.env.NODE_ENV = process.env.NODE_ENV || 'production'

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


module.exports = environment.toWebpackConfig()
