const webpack = require("webpack")

module.exports = (webpackConfig) => {
  webpackConfig.devtool = 'source-map'
  webpackConfig.stats = 'normal'
  webpackConfig.node = {
    global: false,
  },

  webpackConfig.plugins.push(
    new webpack.DefinePlugin({
      global: "window", // Placeholder for global used in any node_modules
    }),
    new webpack.ProvidePlugin({
      $: 'jquery/src/jquery',
      jQuery: 'jquery/src/jquery'
    })
  )

  return webpackConfig;
}
