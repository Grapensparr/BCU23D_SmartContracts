module.exports = {
    webpack: {
        configure: (webpackConfig) => {
            webpackConfig.resolve.fallback = {
                http: require.resolve('stream-http'),
                https: require.resolve('https-browserify'),
                zlib: require.resolve('browserify-zlib'),
                url: require.resolve('url/'),
                assert: require.resolve('assert/'),
                stream: require.resolve('stream-browserify')
            };
            return webpackConfig;
        },
    },
};