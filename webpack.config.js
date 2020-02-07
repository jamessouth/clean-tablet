const path = require('path');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const HTMLWebpackPlugin = require('html-webpack-plugin');
const ScriptExtHTMLWebpackPlugin = require('script-ext-html-webpack-plugin');
const TerserWebpackPlugin = require('terser-webpack-plugin');

module.exports = {
  // mode: 'development',
  // devtool: 'inline-source-map',
  mode: 'production',
  devtool: 'source-map',
  entry: {
    main: './src/front/index.js',
  },
  output: {
    filename: '[name].[contenthash].js',
    chunkFilename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.m?js$/,
        include: [
          path.resolve(__dirname, 'src/front/'),
        ],
        exclude: /(node_modules|\.test\.js$)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              [
                '@babel/preset-env',
                {
                  'useBuiltIns': 'usage',
                  'corejs': '3.6.4',
                },
              ],
              [
                '@babel/preset-react',
                {
                  'useBuiltIns': true,
                  'development': false,
                },
              ],
            ],
            plugins: [
              '@babel/plugin-proposal-class-properties'
            ],
            cacheDirectory: true,
          },
        },
      },
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          "style-loader",
          {
            loader: "css-loader",
            options: {
              modules: true,
              sourceMap: true,
            },
          },
        ],
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              outputPath: 'images/',
              publicPath: 'images/',
            },
          },
        ],
      },
    ],
  },
  optimization: {
    minimizer: [
      new TerserWebpackPlugin({
        parallel: true,
        sourceMap: true,
      }),
    ],
    runtimeChunk: 'single',
    splitChunks: {
      chunks: 'all',
    },
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HTMLWebpackPlugin({
      template: './src/front/index.html',
      title: 'Blank Slate',
      favicon: './src/assets/icons/favicon-16x16.png'
    }),
    new ScriptExtHTMLWebpackPlugin({
      defaultAttribute: 'async',
    }),
    new webpack.HashedModuleIdsPlugin(),
  ],
  devServer: {
    port: 4200,
    contentBase: path.join(__dirname, 'dist'),
    index: 'index.html',
  },
};
