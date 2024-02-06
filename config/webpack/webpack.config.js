// const path    = require("path")
// const webpack = require("webpack")

// module.exports = {
//   mode: "production",
//   devtool: "source-map",
//   entry: {
//     application: "./app/javascript/application.js"
//   },
//   output: {
//     filename: "[name].js",
//     sourceMapFilename: "[file].map",
//     chunkFormat: "module",
//     path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
//   },
//   plugins: [
//     new webpack.optimize.LimitChunkCountPlugin({
//       maxChunks: 1
//     })
//   ]
// }

const baseConfig = require('./base')

module.exports = (_, argv) => {
  let webpackConfig = baseConfig(argv.mode);

  if (argv.mode === 'development') {
    const devConfig = require('./development');
    devConfig(webpackConfig);
  }

  if (argv.mode === 'production') {
    const prodConfig = require('./production');
    prodConfig(webpackConfig);
  }

  return webpackConfig;
}