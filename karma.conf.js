// Karma configuration
// Generated on Wed Jul 05 2017 16:59:45 GMT+0200 (CEST)

module.exports = function (config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],

    // list of files / patterns to load in the browser
    files: [
      './app/javascript/spec/**/*Spec.js'
    ],

    // list of files to exclude
    exclude: [],

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      './app/javascript/spec/**/*Spec.js': ['webpack']
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['nyan'],

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,

    webpack: {
      context: __dirname + '/app/javascript',

      module: {
        loaders: [
          {
            test: /\.vue(\.erb)?$/,
            loader: 'vue-loader',
            options: {
              extractCSS: true,
              loaders: {
                js: 'babel-loader',
                file: 'file-loader',
                scss: 'vue-style-loader!css-loader!postcss-loader!sass-loader',
                sass: 'vue-style-loader!css-loader!postcss-loader!sass-loader?indentedSyntax'
              }
            }
          },
          {
            test: /\.js(\.erb)?$/,
            exclude: /node_modules/,
            loader: 'babel-loader'
          }
        ]
      },

      resolve: {
        extensions: ['.coffee', '.vue', '.js', '.jsx']
      },

      resolveLoader: {
        modules: ['node_modules']
      }
    },

    webpackMiddleware: {
      // webpack-dev-middleware configuration
      // i. e.
      noInfo: true,
      stats: 'errors-only'
    },

    webpackServer: {
      noInfo: true
    }
  })
}
