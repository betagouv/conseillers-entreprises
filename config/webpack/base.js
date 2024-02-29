const path    = require("path")
const webpack = require("webpack")
const { sourcePath, additionalPaths } = require("./config")

const sharedWebpackConfig = (mode) => {
  const isProduction = (mode === "production");

  return {
    mode: mode,
    devtool: "source-map",
    entry: {
      application: "./app/front/packs/application.js",
      pages: "./app/front/packs/pages.js",
      'gouvfr-nomodule': "./app/front/packs/gouvfr-nomodule.js",
      'gouvfr-module': "./app/front/packs/gouvfr-module.js",
    },
    // optimization: // optimization rules
    resolveLoader: {
      modules: [ 'node_modules' ],
    },
    output:   {
      filename: "[name].js",
      chunkFilename: "[name]-[contenthash].digested.js",
      sourceMapFilename: "[file]-[fullhash].map",
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
