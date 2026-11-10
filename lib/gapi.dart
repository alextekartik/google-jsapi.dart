/// The gapi loader: [loadGapiPlatform] (`platform.js`, then `gapi.load` a
/// module such as `picker`), [loadGapiClientPlatform] / [loadGapi]
/// (`client:platform.js`), the [Gapi] wrapper of `window.gapi`.
///
/// On `dart:js_interop` and `package:web`: dart2js and dart2wasm.
library;

export 'src/gapi_impl.dart'
    show
        Gapi,
        GapiException,
        gapiResponseParseException,
        loadGapiPlatform,
        loadGapiClientPlatform,
        loadGapi;
