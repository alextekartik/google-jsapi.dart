@TestOn('browser')
library auth_test;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

void main() {
  group('gapi', () {
    Gapi gapi;

    test('load', () async {
      expect(context['gapi'], isNull);
      gapi = await loadGapiClientPlatform();
      expect(context['gapi'], isNotNull);
      expect(gapi['auth'], isNotNull);
      expect(gapi['load'], isNotNull);
      expect(gapi['auth2'], isNotNull);
      expect(gapi['client'], isNotNull);

      gapi = await loadGapiClientPlatform();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(gapi['auth2'], isNotNull);

      // load auth
      await gapi.load('auth2');
      expect(gapi['auth2'], isNotNull);
    });
  });
}
