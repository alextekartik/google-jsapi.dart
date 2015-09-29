@TestOn("browser && !content-shell")
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'dart:js';

void main() {
  group('gapi_auth2', () {
    test('load', () async {
      expect(context['gapi'], isNull);
      GapiAuth2 gapiAuth2 = await loadGapiAuth2();
      expect(gapiAuth2, isNotNull);
      expect(context['gapi']['auth2'], isNotNull);
      expect(context['gapi']['signin2'], isNotNull);
    });

  });
}