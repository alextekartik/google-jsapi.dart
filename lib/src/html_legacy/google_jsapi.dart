@Deprecated('No longer supported')
library;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_browser_utils/js_loader_utils.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'gapi.dart';

export 'auth.dart';
export 'client.dart';
export 'gapi.dart';

// Gapi _gapi;

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

///
/// if you want the bare feature
///
Future<Gapi> loadGapiPlatform() async {
  // check if loaded first
  if (_checkPlatformLoaded()) {
    return Gapi(context['gapi'] as JsObject?);
  }
  await loadJavascriptScript('//apis.google.com/js/platform.js');
  await _waitForGapiPlatformLoaded();
  return Gapi(context['gapi'] as JsObject?);
}

///
/// if you want the whole feature set
///
Future<Gapi> loadGapiClientPlatform() async {
  // check if loaded first
  if (_checkClientLoaded()) {
    return Gapi(context['gapi'] as JsObject?);
  }
  await loadJavascriptScript('//apis.google.com/js/client:platform.js');
  await _waitForGapiClientLoaded();
  return Gapi(context['gapi'] as JsObject?);
}

// compatibility - load client
Future<Gapi> loadGapi() => loadGapiClientPlatform();
