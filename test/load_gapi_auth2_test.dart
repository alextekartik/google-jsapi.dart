@TestOn('browser')
library auth_test;

import 'dart:js';

import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'package:test/test.dart';

void main() {
  group('gapi_auth2', () {
    test('load', () async {
      expect(context['gapi'], isNull);
      final gapiAuth2 = await loadGapiAuth2();
      expect(gapiAuth2, isNotNull);
      expect((context['gapi'] as JsObject)['auth2'], isNotNull);
      expect((context['gapi'] as JsObject)['signin2'], isNotNull);
    });
  });
}
