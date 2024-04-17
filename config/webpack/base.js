const path    = require("path")
const webpack = require("webpack")
// const { sourcePath, additionalPaths } = require("./config")

const sharedWebpackConfig = (mode) => {
  // const isProduction = (mode === "production");

  return {
    mode: mode,
    devtool: "source-map",
    entry: {
      application: "./app/front/packs/application.js",
      pages: "./app/front/packs/pages.js",
      'gouvfr-nomodule': "./app/front/packs/gouvfr-nomodule.js",
      'gouvfr-module': "./app/front/packs/gouvfr-module.js",
    },
    module: {
      rules: [
          {
            test: /\.(js)$/,
            exclude: /node_modules/,
            use: ['babel-loader'],
          }
        ]
    },
    // optimization: // optimization rules
    resolveLoader: {
      modules: [ 'node_modules' ],
    },
    output:   {
      filename: "[name].js",
      chunkFilename: "[name].digested.js",
      sourceMapFilename: "[file].map",
      path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
      hashFunction: "sha256",
      hashDigestLength: 64,
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1
      })
    ]
  }
}

module.exports = sharedWebpackConfig;
