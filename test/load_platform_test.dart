@TestOn('browser')
library;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

void main() {
  group('gapi', () {
    Gapi gapi;

    test('load', () async {
      expect(context['gapi'], isNull);
      gapi = await loadGapiPlatform();
      expect(context['gapi'], isNotNull);
      expect(gapi['auth'], isNull);
      expect(gapi['load'], isNotNull);
      expect(gapi['auth2'], isNull);
      expect(gapi['client'], isNull);

      gapi = await loadGapiPlatform();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(gapi['auth'], isNull);
      expect(gapi['auth2'], isNull);
      expect(gapi['client'], isNull);
      // load auth
      await gapi.load('auth');

      expect(gapi['auth'], isNotNull);
      expect(gapi['client'], isNull);
      expect(gapi['auth2'], isNotNull);

      // load client
      await gapi.load('client');
      expect(gapi['client'], isNotNull);
      expect(gapi['auth2'], isNotNull);

      // load auth2
      await gapi.load('auth2');
      expect(gapi['auth2'], isNotNull);
    });
  });
}
