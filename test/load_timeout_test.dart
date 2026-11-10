@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

void main() {
  test('client:platform.js without gapi.client times out', () async {
    // A gapi object the Google script can neither replace nor extend:
    // gapi.client never appears.
    var object = globalContext['Object'] as JSObject;
    var gapi = JSObject()..['auth'] = JSObject();
    object.callMethod<JSAny?>('freeze'.toJS, gapi);
    var descriptor = JSObject()
      ..['value'] = gapi
      ..['writable'] = false.toJS
      ..['configurable'] = true.toJS;
    object.callMethod<JSAny?>(
      'defineProperty'.toJS,
      globalContext,
      'gapi'.toJS,
      descriptor,
    );
    try {
      // Used to poll every millisecond, without end
      await expectLater(
        loadGapiClientPlatform(timeout: const Duration(seconds: 2)),
        throwsA(isA<TimeoutException>()),
      );
    } finally {
      globalContext.delete('gapi'.toJS);
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
