// process.env.NODE_ENV = process.env.NODE_ENV || 'production'
// const webpack = require('webpack');

// const base = require('./base')

// // Config specifique pour eviter une erreur CSP
// // cf https://github.com/webpack/webpack/issues/5627#issuecomment-394309966
// const extraConfig = {
//   node: {
//     global: false,
//   },
//   plugins: [
//     new webpack.DefinePlugin({
//       global: "window", // Placeholder for global used in any node_modules
//     }),
//   ],
// };

// base.config.merge(extraConfig);

// module.exports = base.toWebpackConfig()

// const { EsbuildPlugin } = require('esbuild-loader')
// const CompressionPlugin = require('compression-webpack-plugin')
const webpack = require("webpack")

module.exports = (webpackConfig) => {
  webpackConfig.devtool = 'source-map'
  webpackConfig.stats = 'normal'
  webpackConfig.node = {
    global: false,
  },
  // webpackConfig.bail = true

  // webpackConfig.plugins.push(
  //   new CompressionPlugin({
  //     filename: '[path][base].gz[query]',
  //     algorithm: 'gzip',
  //     test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/
  //   })
  // )
  webpackConfig.plugins.push(
    new webpack.DefinePlugin({
      global: "window", // Placeholder for global used in any node_modules
    }),
  )

  // const prodOptimization = {
  //   minimize: true,
  //   minimizer: [
  //     new EsbuildPlugin({
  //       target: 'es2015',
  //       css: true  // Apply minification to CSS assets
  //     })
  //   ]
  // }

  // Object.assign(webpackConfig.optimization, prodOptimization);

  return webpackConfig;
}