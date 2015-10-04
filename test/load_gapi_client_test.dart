@TestOn("browser && !content-shell")
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/gapi_client.dart';
import 'dart:js';

void main() {
  group('gapi_client', () {
    test('load', () async {
      expect(context['gapi'], isNull);
      GapiClient gapiClient = await loadGapiClient();
      expect(gapiClient, isNotNull);
      expect(context['gapi']['client'], isNotNull);
      expect(context['gapi']['client']['plus'], isNull);

      await gapiClient.load("plus", "v1");

      expect(context['gapi']['client']['plus'], isNotNull);



      bool success = false;
      try {
        await gapiClient.load("plus", "v0");
        success = true;
      } catch (e) {
      }
      expect(success, false);

    });

  });
}