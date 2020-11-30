const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

// Pour que jquery soit aussi accessible à Sprockets le temps de la cohabitation sprockets/webpacker
environment.loaders.append('expose', {
  test: require.resolve('jquery'),
  loader: 'expose-loader',
  options: {
    exposes: ['$', 'jQuery']
  }
})

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.jQuery': 'jquery'
  })
)

module.exports = environment
