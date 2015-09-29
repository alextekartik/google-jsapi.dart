library tekartik_google_jsapi.gapi;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_utils/js_utils.dart';

class Gapi {
  JsObject jsObject;
  Gapi(this.jsObject);

  JsObject get jsGapi => jsObject;

  operator [](String key) => jsObject[key];

  Future load(String api) {
    Completer completer = new Completer();
    void _onLoaded([jsData]) {
      completer.complete();
    }
    var jsOptions = new JsObject.jsify({'callback': _onLoaded});
    List args = [ api, jsOptions ];
    jsObject.callMethod('load', args);

    return completer.future;
  }

}



class GapiException implements Exception {
  /**
   * A message describing the format error.
   */
  final String message;

  /**
   * Creates a new FormatException with an optional error [message].
   */
  const GapiException([this.message = ""]);
  String toString() => "GapiException: $message";
}

Exception gapiResponseParseException(JsObject jsData) {
  if (jsData != null) {
    var jsError = jsData['error'];
    if (jsError != null) {
      if ((jsError is JsObject) && (!(jsError is JsArray))) {
        int code = jsError['code'];
        String message = jsError['message'];
        return new GapiException("$code - $message");
      } else {
        return new GapiException('error');
      }
    }
  }
  return null;
}

//Gapi _gapi;

bool _debug = false;
bool _checkGapiProperties([List<String> properties = const []]) {
  JsObject jsGapi = context['gapi'];
  if (_debug) {
    print('_check gapi: ${jsGapi != null}');
  }
  if (jsGapi == null) {
    return false;
  }
  bool ok = true;
  for (String property in properties) {
    if (_debug) {
      print('_check gapi[${property}]: ${jsGapi[property] != null}');
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
  await new Future.delayed(new Duration(milliseconds: 1));
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
  await new Future.delayed(new Duration(milliseconds: 1));
  await _waitForGapiClientLoaded();
}

///
/// if you want the bare feature
///
Future<Gapi> loadGapiPlatform() async {

  // check if loaded first
  if (_checkPlatformLoaded()) {
    return new Gapi(context['gapi']);
  }
  await loadJavascriptScript('//apis.google.com/js/platform.js');
  await _waitForGapiPlatformLoaded();
  return new Gapi(context['gapi']);
}

///
/// if you want the whole feature set
///
Future<Gapi> loadGapiClientPlatform() async {

  // check if loaded first
  if (_checkClientLoaded()) {
    return new Gapi(context['gapi']);
  }
  await loadJavascriptScript('//apis.google.com/js/client:platform.js');
  await _waitForGapiClientLoaded();
  return new Gapi(context['gapi']);
}

// compatibility - load client
Future<Gapi> loadGapi() => loadGapiClientPlatform();