library;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_browser_utils/js_utils.dart';

class Gapi {
  JsObject? jsObject;
  Gapi(this.jsObject);

  JsObject? get jsGapi => jsObject;

  dynamic operator [](String key) => jsObject![key];

  Future load(String api) {
    final completer = Completer<void>();
    void onLoaded([jsData]) {
      completer.complete();
    }

    var jsOptions = JsObject.jsify({'callback': onLoaded});
    final args = [api, jsOptions];
    jsObject!.callMethod('load', args);

    return completer.future;
  }
}

class GapiException implements Exception {
  /// A message describing the format error.
  final String message;

  /// Creates a new FormatException with an optional error [message].
  const GapiException([this.message = '']);
  @override
  String toString() => 'GapiException: $message';
}

Exception? gapiResponseParseException(JsObject jsData) {
  var jsError = jsData['error'];
  if (jsError != null) {
    if ((jsError is JsObject) && (jsError is! JsArray)) {
      var code = jsError['code'] as int?;
      final message = jsError['message'] as String?;
      return GapiException('$code - $message');
    } else {
      return const GapiException('error');
    }
  }

  return null;
}

//Gapi _gapi;

bool _debug = false;
bool _checkGapiProperties([List<String> properties = const []]) {
  final jsGapi = context['gapi'] as JsObject?;
  if (_debug) {
    print('_check gapi: ${jsGapi != null}');
  }
  if (jsGapi == null) {
    return false;
  }
  var ok = true;
  for (final property in properties) {
    if (_debug) {
      print('_check gapi[$property]: ${jsGapi[property] != null}');
    }
    if (jsGapi[property] == null) {
      ok = false;
      if (!_debug) {
        break;
      }
    }
  }
  return ok;
}

bool _checkPlatformLoaded() {
  return _checkGapiProperties();
}

Future _waitForGapiPlatformLoaded() async {
  if (_checkPlatformLoaded()) {
    return;
  }
  // wait 1ms..and repeat
  await Future<void>.delayed(const Duration(milliseconds: 1));
  await _waitForGapiPlatformLoaded();
}

bool _checkClientLoaded() {
  return _checkGapiProperties(['auth', 'client']);
}

Future _waitForGapiClientLoaded() async {
  if (_checkClientLoaded()) {
    return;
  }
  // wait 1ms..and repeat
  await Future<void>.delayed(const Duration(milliseconds: 1));
  await _waitForGapiClientLoaded();
}

JsObject? get _gapiJsObject => context['gapi'] as JsObject?;

///
/// if you want the bare feature
///
Future<Gapi> loadGapiPlatform() async {
  // check if loaded first
  if (_checkPlatformLoaded()) {
    return Gapi(_gapiJsObject);
  }
  await loadJavascriptScript('//apis.google.com/js/platform.js');
  await _waitForGapiPlatformLoaded();
  return Gapi(_gapiJsObject);
}

///
/// if you want the whole feature set
///
Future<Gapi> loadGapiClientPlatform() async {
  // check if loaded first
  if (_checkClientLoaded()) {
    return Gapi(_gapiJsObject);
  }
  await loadJavascriptScript('//apis.google.com/js/client:platform.js');
  await _waitForGapiClientLoaded();
  return Gapi(_gapiJsObject);
}

// compatibility - load client
Future<Gapi> loadGapi() => loadGapiClientPlatform();
