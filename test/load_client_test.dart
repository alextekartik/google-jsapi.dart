@TestOn("browser && !content-shell")
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'dart:js';
import 'dart:async';

void main() {
  group('gapi', () {
    Gapi gapi;

    test('load', () async {
      expect(context['gapi'], isNull);
      gapi = await loadGapiClientPlatform();
      expect(context['gapi'], isNotNull);
      expect(gapi['auth'], isNotNull);
      expect(gapi['load'], isNotNull);
      expect(gapi['auth2'], isNull);
      expect(gapi['client'], isNotNull);

      gapi = await loadGapiClientPlatform();

      await new  Future.delayed(new Duration(milliseconds: 100));
      expect(gapi['auth2'], isNull);

      // load auth
      await gapi.load('auth2');
      expect(gapi['auth2'], isNotNull);



    });

  });
}