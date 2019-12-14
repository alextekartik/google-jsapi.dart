@TestOn('browser')
library auth_test;

import 'dart:js';

import 'package:tekartik_google_jsapi/gapi_client.dart';
import 'package:test/test.dart';

void main() {
  group('gapi_client', () {
    test('load', () async {
      expect(context['gapi'], isNull);
      final gapiClient = await loadGapiClient();
      expect(gapiClient, isNotNull);
      expect(context['gapi']['client'], isNotNull);
      expect(context['gapi']['client']['people'], isNull);
      await gapiClient.load('people', 'v1');
      expect(context['gapi']['client']['people'], isNotNull);

      var success = false;
      try {
        await gapiClient.load('people', 'v0');
        success = true;
      } catch (e) {
        print(e);
      }
      expect(success, false);
    });
  });
}
