@TestOn('browser')
library;

import 'dart:js';

import 'package:tekartik_google_jsapi/gapi_client.dart';
import 'package:test/test.dart';

void main() {
  group('gapi_client', () {
    test('load', () async {
      expect(context['gapi'], isNull);
      final gapiClient = await loadGapiClient();
      expect(gapiClient, isNotNull);
      expect((context['gapi'] as JsObject)['client'], isNotNull);
      expect(((context['gapi'] as JsObject)['client'] as JsObject)['people'],
          isNull);
      await gapiClient.load('people', 'v1');
      expect(((context['gapi'] as JsObject)['client'] as JsObject)['people'],
          isNotNull);

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
