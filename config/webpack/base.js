const path    = require("path")
// const { resolve } = require("path");
const webpack = require("webpack")
const { sourcePath, additionalPaths } = require("./config")

const getCssLoader = () => {
  return {
    loader: require.resolve('css-loader'),
    options: { sourceMap: true, importLoaders: 2 }
  }
}

const sharedWebpackConfig = (mode) => {
  const isProduction = (mode === "production");

  return {
    mode: mode,
    devtool: "source-map",
    entry: {
      application: "./app/front/packs/application.js",
      pages: "./app/front/packs/pages.js",
      gouvfrNomodule: "./app/front/packs/gouvfr-nomodule.js",
      gouvfrModule: "./app/front/packs/gouvfr-module.js",
    },
    // optimization: // optimization rules
    resolve: {
      extensions: [
        '.erb', '.js',
        '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css',
        '.png', '.svg', '.gif', '.jpeg', '.jpg'
      ],
      modules: [ 'node_modules' ],
    },
    resolveLoader: {
      modules: [ 'node_modules' ], // default settings
    },
    module: {
      strictExportPresence: true,
      rules: [
        // CSS
        {
          test: /\.(css)$/i,
          use: [
            // MiniCssExtractPlugin.loader,
            getCssLoader(),
            // getEsbuildCssLoader()
          ]
        },
        // SASS
        {
          test: /\.(scss|sass)(\.erb)?$/i,
          use: [
            // MiniCssExtractPlugin.loader,
            getCssLoader(),
            {
              loader: require.resolve('sass-loader'),
              options: {
                sassOptions: {
                  includePaths: additionalPaths
                }
              }
            }
          ]
        }
      ]
    },
    output:   {
      filename: "[name].js",
      sourceMapFilename: "[file].map",
      chunkFormat: "module",
      path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1
      })
    ]
  }
}

module.exports = sharedWebpackConfig;




// const { environment } = require('@rails/webpacker')

// const webpack = require('webpack')

// // Pour que jquery soit aussi accessible à Sprockets le temps de la cohabitation sprockets/webpacker
// environment.loaders.append('expose', {
//   test: require.resolve('jquery'),
//   loader: 'expose-loader',
//   options: {
//     exposes: ['$', 'jQuery']
//   }
// })

// environment.plugins.append(
//   'Provide',
//   new webpack.ProvidePlugin({
//     $: 'jquery',
//     jQuery: 'jquery',
//     jquery: 'jquery',
//     'window.jQuery': 'jquery'
//   })
// )

// module.exports = environment



