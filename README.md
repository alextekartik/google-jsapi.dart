# tekartik_google_jsapi

Dart wrappers around Google's `gapi` javascript loader
(`apis.google.com/js/platform.js` and `client:platform.js`): load gapi, load
a gapi module (`picker`, `client`, `auth2`...), load a discovery based Google
API with `gapi.client`.

On `dart:js_interop` and `package:web`: it builds with dart2js and dart2wasm
(`dart compile js`, `dart compile wasm`, a Flutter web `--wasm` build). It
never runs on the Dart VM.

The sign-in parts wrap Google APIs that Google deprecated: `gapi.auth`
(`authorize`, the old OAuth token flow of the js client) and `gapi.auth2`
(Google Sign-In for Web). They still load and work for existing client ids,
but new client ids cannot use them: a new app signs in with
[Google Identity Services](https://developers.google.com/identity/gsi/web)
(`accounts.google.com/gsi/client`, `google.accounts.oauth2.initTokenClient`
for an access token). Their libraries (`gapi_auth.dart`, `gapi_auth2.dart`)
stay `@Deprecated`.

## Getting started

Git dependency (not on pub.dev, the package is at the repository root):

```yaml
dependencies:
  tekartik_google_jsapi:
    git:
      url: https://github.com/alextekartik/google-jsapi.dart
```

Load gapi and a discovery api (browser, dart2js or dart2wasm):

```dart
// ignore_for_file: avoid_print
import 'dart:async';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_client.dart';

Future<void> main() async {
  try {
    // Injects //apis.google.com/js/client:platform.js once, waits (30 s at
    // most) for gapi.client and gapi.auth.
    var gapi = await loadGapi();
    var client = await loadGapiClient(gapi);
    await client.load('drive', 'v3');
    print('drive api ready');
  } on GapiException catch (e) {
    print('load failed: $e');
  } on TimeoutException catch (e) {
    print('gapi not ready: $e');
  }
}
```

## What it holds

| Import | What |
|---|---|
| `package:tekartik_google_jsapi/gapi.dart` | `loadGapiPlatform()` (platform.js, only `gapi.load`), `loadGapiClientPlatform()` and its alias `loadGapi()` (client:platform.js), `Gapi` (`gapi['client']`, `await gapi.load('picker')`, `gapi.jsObject`), `GapiException` |
| `package:tekartik_google_jsapi/gapi_client.dart` | `loadGapiClient()`, `GapiClient.load(api, version)` |
| `package:tekartik_google_jsapi/gapi_auth.dart` | `loadGapiAuth()`, `GapiAuth.authorize` (deprecated by Google) |
| `package:tekartik_google_jsapi/gapi_auth2.dart` | `loadGapiAuth2()`, `GapiAuth2`, `GoogleAuth`, `GoogleUser` (deprecated by Google) |
| `package:tekartik_google_jsapi/promise.dart` | `Promise(jsObject).asFuture` (deprecated: `JSPromise.toDart` of `dart:js_interop`) |
| `package:tekartik_google_jsapi/google_jsapi.dart` | the old umbrella library, now the same classes as the ones above (deprecated) |

The raw javascript objects are `dart:js_interop` types: `Gapi.jsObject` is a
`JSObject?`, `gapi['client']` a `JSAny?` (`as JSObject` to use it with
`dart:js_interop_unsafe`).

## Pitfalls

- The loaders and `Gapi.load` fail with a `TimeoutException` after 30 s by
  default (`timeout:` to change it), and `Gapi.load` with a `GapiException`
  when gapi reports the module failed (an extension blocking it, the
  network). A script that cannot be loaded throws at once.
- `authorize()` and `signIn()` open a popup: call them from a click handler,
  browsers block popups otherwise.
- `GoogleAuth.onSignedIn` is a broadcast stream, one javascript listener per
  `GoogleAuth` (`getAuthInstance()` returns a new `GoogleAuth` each call:
  keep the one you listen to).
- Never put a client id or secret in the source: `example/` reads a
  git-ignored `local.config.yaml` copied from `sample.local.config.yaml`.

## Example

`example/` holds browser pages: `index.html` links to the
`google_jsapi_example` (load, authorize) and `gapi_auth2_example` pages.
Serve them with `dart run tool/webdev_serve.dart` (webdev, port 8081: register
`http://localhost:8081` as a JavaScript origin of the client id).

## Migrating from 0.2 (`dart:js`)

- `JsObject` became `JSObject` (`dart:js_interop`): `Gapi(jsObject)`,
  `Gapi.jsObject`, `GapiAuth(jsObject)`, `GapiClient(jsObject)`,
  `gapiResponseParseException(jsData)`, `Promise(jsObject)`,
  `GapiAuth2SignInParams.jsify()`, `GapiAuth2InitParams.jsify()`.
- `gapi['key']` returns a `JSAny?` instead of a `JsObject` or a Dart value:
  compare it to null, or cast it (`gapi['client'] as JSObject`).
- `google_jsapi.dart` and `gapi.dart` export the same `Gapi`, `GapiAuth` and
  `GapiClient` now: both can be imported together.
