const path = require("path");
const { publicRootPath, publicOutputPath } = require("./config");

module.exports = (webpackConfig) => {
  webpackConfig.devtool = "cheap-module-source-map"

  webpackConfig.stats = {
    colors: true,
    entrypoints: false,
    errorDetails: true,
    modules: false,
    moduleTrace: false
  }

  // Add dev server configs
  webpackConfig.devServer = {
    https: false,
    host: 'localhost',
    port: 3035,
    public: 'localhost:3035',
    // Use gzip compression
    compress: true,
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    static: {
      publicPath: path.resolve(process.cwd(), `${publicRootPath}/${publicOutputPath}`),
      watch: {
        ignored: "**/node_modules/**"
      }
    },
    devMiddleware: {
      publicPath: `/${publicOutputPath}/`
    },
    // Reload upon new webpack build
    liveReload: true,
  }

  return webpackConfig;
}
