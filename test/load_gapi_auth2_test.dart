// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'package:test/test.dart';

void main() {
  group('gapi_auth2', () {
    test('load', () async {
      expect(globalContext['gapi'], isNull);
      final gapiAuth2 = await loadGapiAuth2();
      expect(gapiAuth2, isNotNull);
      expect((globalContext['gapi'] as JSObject)['auth2'], isNotNull);
      expect((globalContext['gapi'] as JSObject)['signin2'], isNotNull);
    });
  });
}
