import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_browser_utils/js_utils.dart';

/// How long the loaders wait by default for gapi or one of its modules.
const _defaultTimeout = Duration(seconds: 30);

/// The JS `gapi` global object, null when not loaded.
JSObject? get _gapiJsObject => globalContext['gapi'] as JSObject?;

/// The `gapi` object of the page (`window.gapi`): [load] a module, read a
/// property ([operator []]).
class Gapi {
  /// The JS `gapi` object.
  JSObject? jsObject;

  /// Wraps the JS `gapi` object.
  Gapi(this.jsObject);

  /// The JS `gapi` object.
  JSObject? get jsGapi => jsObject;

  GapiAuth? _auth;
  GapiClient? _client;

  /// The legacy `gapi.auth`, null inside when not loaded.
  @Deprecated('Use loadGapiAuth')
  GapiAuth? get auth {
    _auth ??= GapiAuth(jsObject!['auth'] as JSObject?);
    return _auth;
  }

  /// `gapi.client`, null inside when not loaded (use `loadGapiClient`).
  GapiClient? get client {
    _client ??= GapiClient(jsObject!['client'] as JSObject?);
    return _client;
  }

  /// The property [key] of `gapi` (`client`, `auth2`...), null when absent.
  JSAny? operator [](String key) => jsObject![key];

  /// Loads the gapi module [api] (`client`, `auth2`, `picker`...).
  ///
  /// Fails with a [GapiException] when gapi reports an error, and with a
  /// [TimeoutException] when the module is not loaded within [timeout] (30
  /// seconds by default).
  Future<void> load(String api, {Duration? timeout}) {
    timeout ??= _defaultTimeout;
    final completer = Completer<void>();
    var options = JSObject();
    options['callback'] = () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }.toJS;
    options['onerror'] = () {
      if (!completer.isCompleted) {
        completer.completeError(GapiException('gapi.load($api) failed'));
      }
    }.toJS;
    options['timeout'] = timeout.inMilliseconds.toJS;
    options['ontimeout'] = () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('gapi.load($api) timed out', timeout),
        );
      }
    }.toJS;
    jsObject!.callMethod<JSAny?>('load'.toJS, api.toJS, options);
    return completer.future;
  }
}

/// An error reported by gapi.
class GapiException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates a gapi exception with an optional error [message].
  const GapiException([this.message = '']);
  @override
  String toString() => 'GapiException: $message';
}

/// A JS number as a Dart int when it is integral (a dart2wasm number is a
/// double), any other value dartified.
Object? _dartValue(JSAny? value) {
  var dartValue = value?.dartify();
  if (dartValue is double && dartValue == dartValue.truncateToDouble()) {
    return dartValue.toInt();
  }
  return dartValue;
}

/// The [GapiException] of a gapi response holding an `error` (an object with
/// `code` and `message`, or anything else), null when there is none.
Exception? gapiResponseParseException(JSObject jsData) {
  var jsError = jsData['error'];
  if (jsError != null) {
    if (jsError.isA<JSObject>() && !jsError.isA<JSArray>()) {
      var jsErrorObject = jsError as JSObject;
      final code = _dartValue(jsErrorObject['code']);
      final message = _dartValue(jsErrorObject['message']);
      return GapiException('$code - $message');
    } else {
      return const GapiException('error');
    }
  }
  return null;
}

/// True when `gapi` exists with every one of [properties].
bool _checkGapiProperties([List<String> properties = const []]) {
  final jsGapi = _gapiJsObject;
  if (jsGapi == null) {
    return false;
  }
  for (final property in properties) {
    if (jsGapi[property] == null) {
      return false;
    }
  }
  return true;
}

/// Waits until `gapi` has [properties], at most [timeout].
Future<void> _waitForGapi(List<String> properties, Duration timeout) async {
  var stopwatch = Stopwatch()..start();
  while (!_checkGapiProperties(properties)) {
    if (stopwatch.elapsed > timeout) {
      throw TimeoutException(
        properties.isEmpty
            ? 'gapi not defined'
            : 'gapi.${properties.join(', gapi.')} not defined',
        timeout,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// Loads `//apis.google.com/js/platform.js` once and returns [Gapi] (only
/// `gapi.load` is there): the bare feature.
///
/// Throws when the script cannot be loaded, and a [TimeoutException] when
/// `gapi` is not defined within [timeout] (30 seconds by default) once it
/// ran.
Future<Gapi> loadGapiPlatform({Duration? timeout}) async {
  // check if loaded first
  if (!_checkGapiProperties()) {
    await loadJavascriptScript('//apis.google.com/js/platform.js');
    await _waitForGapi(const [], timeout ?? _defaultTimeout);
  }
  return Gapi(_gapiJsObject);
}

/// Loads `//apis.google.com/js/client:platform.js` once and waits for
/// `gapi.auth` and `gapi.client`: the whole feature set.
///
/// Throws when the script cannot be loaded, and a [TimeoutException] when
/// those two properties are not defined within [timeout] (30 seconds by
/// default) once it ran.
Future<Gapi> loadGapiClientPlatform({Duration? timeout}) async {
  const properties = ['auth', 'client'];
  // check if loaded first
  if (!_checkGapiProperties(properties)) {
    await loadJavascriptScript('//apis.google.com/js/client:platform.js');
    await _waitForGapi(properties, timeout ?? _defaultTimeout);
  }
  return Gapi(_gapiJsObject);
}

/// Same as [loadGapiClientPlatform].
Future<Gapi> loadGapi({Duration? timeout}) =>
    loadGapiClientPlatform(timeout: timeout);

/// The legacy `gapi.auth` (OAuth 2 implicit flow of the JS client),
/// deprecated by Google: use Google Identity Services.
class GapiAuth {
  /// The JS `gapi.auth` object.
  JSObject? jsObject;

  /// Wraps the JS `gapi.auth` object.
  GapiAuth(this.jsObject);

  /// The email scope.
  static const scopeEmail = 'email';

  /// Forces the consent prompt.
  static const approvalPromptForce = 'force';
  @Deprecated('Use scopeEmail')
  // ignore: constant_identifier_names
  static const SCOPE_EMAIL = scopeEmail;
  @Deprecated('Use approvalPromptForce')
  // ignore: constant_identifier_names
  static const APPROVAL_PROMPT_FORCE = approvalPromptForce;

  /// The current access token, null when there is none.
  String? getAccessToken() {
    var jsToken = jsObject!.callMethod<JSObject?>('getToken'.toJS);
    return (jsToken?['access_token'] as JSString?)?.toDart;
  }

  /// Asks the user to authorize [scopes] for [clientId] (a popup) and
  /// completes with the access token. [approvalPrompt] can be
  /// [approvalPromptForce].
  ///
  /// Fails with a [GapiException] when gapi reports an error, with a
  /// `String` when there is no token.
  Future<String> authorize(
    String clientId,
    List<String> scopes, {
    String? approvalPrompt,
  }) {
    final completer = Completer<String>();
    var options = {
      'client_id': clientId,
      'scope': scopes,
      'immediate': false,
      'approval_prompt': approvalPrompt,
    }.jsify();
    void onResult(JSObject? authResult) {
      if (authResult != null) {
        final e = gapiResponseParseException(authResult);
        if (e != null) {
          completer.completeError(e);
          return;
        }
        final oauthToken = (authResult['access_token'] as JSString?)?.toDart;
        if (oauthToken == null) {
          completer.completeError('null auth token');
        } else {
          completer.complete(oauthToken);
        }
      } else {
        completer.completeError('no auth token');
      }
    }

    jsObject!.callMethod<JSAny?>('authorize'.toJS, options, onResult.toJS);

    return completer.future;
  }
}

/// Loads the legacy `gapi.auth` module (in [gapi], the platform one by
/// default).
Future<GapiAuth> loadGapiAuth([Gapi? gapi]) async {
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['auth'] == null) {
    await gapi.load('auth');
  }
  return GapiAuth(gapi['auth'] as JSObject?);
}

/// `gapi.client`: loads the discovery based Google APIs.
class GapiClient {
  /// The JS `gapi.client` object.
  JSObject? jsObject;

  /// Wraps [jsObject], `gapi.client` of the page when null.
  GapiClient([JSObject? jsObject])
    : jsObject = jsObject ?? (_gapiJsObject!['client'] as JSObject?);

  /// Loads the [api] at [version] (`drive`, `v3`).
  ///
  /// Fails with a [GapiException] when gapi reports an error (an unknown api
  /// or version).
  Future<void> load(String api, String version) {
    final completer = Completer<void>();
    void onLoaded([JSAny? jsData]) {
      if (jsData != null && jsData.isA<JSObject>()) {
        final e = gapiResponseParseException(jsData as JSObject);
        if (e != null) {
          completer.completeError(e);
          return;
        }
      }
      completer.complete();
    }

    jsObject!.callMethod<JSAny?>(
      'load'.toJS,
      api.toJS,
      version.toJS,
      onLoaded.toJS,
    );

    return completer.future;
  }
}

/// Loads the `client` module (in [gapi], the platform one by default).
Future<GapiClient> loadGapiClient([Gapi? gapi]) async {
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['client'] == null) {
    await gapi.load('client');
  }
  return GapiClient(gapi['client'] as JSObject?);
}
