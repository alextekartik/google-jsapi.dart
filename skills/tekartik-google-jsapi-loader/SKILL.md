---
name: tekartik-google-jsapi-loader
description: >-
  Use when a Dart web app has to load Google's legacy gapi javascript
  (apis.google.com platform.js / client:platform.js) with
  tekartik_google_jsapi: loadGapi, loadGapiPlatform, loadGapiClientPlatform,
  Gapi.load, loadGapiClient/GapiClient.load, loadGapiAuth/GapiAuth.authorize,
  loadGapiAuth2/GapiAuth2InitParams/GoogleAuth/GoogleUser/BasicProfile,
  GapiException and the gapi.dart, gapi_client.dart, gapi_auth.dart,
  gapi_auth2.dart imports. The package is deprecated: read it before touching
  existing gapi code, do not pick it for a new app.
---

# Loading the Google javascript api (tekartik_google_jsapi)

`tekartik_google_jsapi` injects Google's `apis.google.com` loader script into
the page and wraps the resulting `window.gapi` object in Dart classes: module
loading, the old `gapi.client`, the old `gapi.auth` token flow and the
`gapi.auth2` sign-in flow.

**The whole package is deprecated** (every library carries `@Deprecated`, the
README says so) and the Google APIs it wraps - `gapi.auth` and `gapi.auth2` -
have been retired by Google in favour of Google Identity Services. Use this
skill to read or repair an existing browser app; write new sign-in code
against a current library instead.

## Guidelines

* Dependency (git only, package at the repo root, so no `path:`):
  ```yaml
  dependencies:
    tekartik_google_jsapi:
      git:
        url: https://github.com/alextekartik/google-jsapi.dart
  ```
* Browser only. Every library imports the legacy `dart:js`, so the code
  compiles with `dart compile js` / `build_web_compilers` but not to wasm, and
  tests must be `@TestOn('browser')` (`dart test -p chrome`, or
  `dart run build_runner test -- -p chrome` for the html-backed ones).
* Imports, one per concern:
  * `package:tekartik_google_jsapi/gapi.dart`: `loadGapiPlatform()`,
    `loadGapiClientPlatform()`, `loadGapi()`, `Gapi`, `GapiException`,
    `gapiResponseParseException()`.
  * `package:tekartik_google_jsapi/gapi_client.dart`: `loadGapiClient()`,
    `GapiClient`.
  * `package:tekartik_google_jsapi/gapi_auth.dart`: `loadGapiAuth()`,
    `GapiAuth`.
  * `package:tekartik_google_jsapi/gapi_auth2.dart`: `loadGapiAuth2()`,
    `GapiAuth2`, `GapiAuth2InitParams`, `GapiAuth2SignInParams`,
    `GoogleAuth`, `GoogleUser`, `BasicProfile`, `GoogleAuthResponse`.
  * `package:tekartik_google_jsapi/promise.dart`: `Promise(jsObject).asFuture`
    to await a raw javascript promise.
  * `package:tekartik_google_jsapi/google_jsapi.dart` is the old html-era
    umbrella. It exports *different* `Gapi`, `GapiAuth` and `GapiClient`
    classes (its `Gapi` has `.auth` / `.client` getters, its `GapiAuth` and
    `GapiClient` take a `JsObject` in their constructor). Never import it in
    the same file as `gapi.dart`, and prefer the `gapi.dart` family.
* Loading: `loadGapiPlatform()` injects `//apis.google.com/js/platform.js` and
  resolves once `window.gapi` exists (only `gapi.load` is available then);
  `loadGapiClientPlatform()` injects `//apis.google.com/js/client:platform.js`
  and waits for `gapi.auth` *and* `gapi.client`. `loadGapi()` is an alias of
  `loadGapiClientPlatform()`.
* Both loaders are idempotent: they return immediately when the script is
  already there. They poll every 1 ms with no timeout, so a blocked or failing
  script load hangs the future forever - add `.timeout(...)` if the app must
  survive that.
* `Gapi`: `gapi['client']`, `gapi['auth2']` index into the underlying js
  object (`null` = module not loaded yet), `gapi.jsGapi` / `gapi.jsObject`
  give the raw `JsObject`, and `await gapi.load('picker')` loads one gapi
  module by name (it wraps gapi's `callback` option in a `Future`).
* `loadGapiClient([gapi])` loads the `client` module if needed and returns a
  `GapiClient`; `client.load('people', 'v1')` loads one discovery api. Errors
  come back as a completed-with-error `GapiException('<code> - <message>')`
  built by `gapiResponseParseException`. The bare `GapiClient()` constructor
  reads `window.gapi.client` directly and throws if gapi is not loaded yet;
  always go through `loadGapiClient()`.
* Old token flow: `loadGapiAuth([gapi])` returns a `GapiAuth`;
  `authorize(clientId, scopes, approvalPrompt: GapiAuth.approvalPromptForce)`
  opens the consent popup (`immediate` is always false) and completes with the
  OAuth access token; `getAccessToken()` re-reads the current token.
  `GapiAuth.scopeEmail` is the `'email'` scope. `SCOPE_EMAIL` and
  `APPROVAL_PROMPT_FORCE` are deprecated aliases. Call `authorize` from a
  click handler: browsers block the popup otherwise.
* auth2 flow: `loadGapiAuth2()` then `gapiAuth2.init(GapiAuth2InitParams())`
  once (`clientId` plus `scopes`, joined with spaces for js), which returns a
  `GoogleAuth`; later code gets the same instance with
  `gapiAuth2.getAuthInstance()`. `GoogleAuth` has `signIn([params])`,
  `signOut()`, `disconnect()`, `getIsSignedIn()`, the `onSignedIn` stream and
  `getCurrentUser()` -> `GoogleUser` (`id`, `isSignedIn`, `basicProfile` with
  `name`/`id`/`email`/`imageUrl`, `getAuthResponse()`, `disconnect()`).
  `GapiAuth2SignInParams()..prompt = 'select_account'` forces the account
  chooser (`none`, `login`, `consent`, `select_account`).
* `GapiAuth2InitParams.scopes` is a `late` non-nullable field: set both
  `clientId` and `scopes` before `init`, or you get a
  `LateInitializationError`. `GoogleAuthResponse.token` calls `id_token` as a
  javascript *method* although gapi exposes it as a property, so it does not
  work: read the auth response from the js object yourself if you need the id
  token.
* Never hardcode a client id or secret. The package's own example reads a
  git-ignored `local.config.yaml` at runtime (copied from
  `sample.local.config.yaml`); do the same, and register the JavaScript origin
  (`http://localhost:<port>`) for that client id in the Google Cloud console.

## Examples

### Load gapi and call a discovery api

```dart
// ignore_for_file: deprecated_member_use
import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_client.dart';

Future<void> main() async {
  var gapi = await loadGapi(); // = loadGapiClientPlatform()
  var client = await loadGapiClient(gapi);
  try {
    await client.load('people', 'v1');
    print('people api ready');
  } on GapiException catch (e) {
    print('load failed: $e');
  }
}
```

### Platform-only load, then one gapi module

```dart
// ignore_for_file: deprecated_member_use
import 'package:tekartik_google_jsapi/gapi.dart';

/// Loads the bare platform script then the `auth2` module.
/// `gapi.load(name)` is the generic module loader ('auth', 'client',
/// 'auth2', 'picker', ...); the picker module lands on `window.google.picker`,
/// not on `gapi`.
Future<Gapi> loadGapiWithAuth2() async {
  var gapi = await loadGapiPlatform();
  if (gapi['auth2'] == null) {
    await gapi.load('auth2');
  }
  return gapi;
}
```

### Authorize with the old token flow (from a click handler)

```dart
// ignore_for_file: deprecated_member_use
import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_auth.dart';
import 'package:web/web.dart' as web;

/// [clientId] comes from a runtime config file, never from the source.
void setupAuthorizeButton(String clientId) {
  var button = web.document.querySelector('button.app-authorize')!;
  button.onClick.listen((event) async {
    event.preventDefault();
    var gapi = await loadGapi();
    var auth = await loadGapiAuth(gapi);
    try {
      var token = await auth.authorize(
        clientId,
        [GapiAuth.scopeEmail],
        approvalPrompt: GapiAuth.approvalPromptForce,
      );
      print('token: ${token.substring(0, 4)}...');
    } on GapiException catch (e) {
      print('authorize failed: $e');
    }
  });
}
```

### auth2 sign-in and current user

```dart
// ignore_for_file: deprecated_member_use
import 'package:tekartik_google_jsapi/gapi_auth2.dart';

/// [clientId] is read from a git-ignored runtime config, e.g.
/// `my-app.apps.googleusercontent.com`.
Future<void> signInAndPrintUser(String clientId) async {
  var gapiAuth2 = await loadGapiAuth2();
  var auth = gapiAuth2.init(
    GapiAuth2InitParams()
      ..clientId = clientId
      ..scopes = ['email', 'profile'],
  );
  auth.onSignedIn.listen((signedIn) => print('signed in: $signedIn'));
  if (auth.getIsSignedIn() != true) {
    await auth.signIn(GapiAuth2SignInParams()..prompt = 'select_account');
  }
  var user = auth.getCurrentUser();
  if (user != null && user.isSignedIn == true) {
    print('${user.basicProfile.email} (${user.basicProfile.name})');
  }
}
```

### Browser test

```dart
@TestOn('browser')
// ignore_for_file: deprecated_member_use
library;

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

void main() {
  test('load platform', () async {
    var gapi = await loadGapiPlatform();
    expect(gapi['load'], isNotNull);
    await gapi.load('auth2');
    expect(gapi['auth2'], isNotNull);
  });
}
```

## Common mistakes

* Importing `google_jsapi.dart` and `gapi.dart` together: two unrelated `Gapi`
  classes, and the errors are confusing.
* Calling `loadGapiClient()` / `GapiClient()` before any loader ran, or
  expecting `gapi['client']` to exist after `loadGapiPlatform()` alone.
* Awaiting `authorize()` or `signIn()` outside a user gesture: the popup is
  blocked and the future never completes.
* Calling `getAuthInstance()` before `init()`.
* Forgetting `scopes` on `GapiAuth2InitParams` (`LateInitializationError`).
* Compiling to wasm or running these libraries on the Dart VM.
