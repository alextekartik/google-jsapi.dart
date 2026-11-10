// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_google_jsapi/gapi_client.dart';
import 'package:test/test.dart';

void main() {
  group('gapi_client', () {
    test('load', () async {
      expect(globalContext['gapi'], isNull);
      final gapiClient = await loadGapiClient();
      expect(gapiClient, isNotNull);
      expect((globalContext['gapi'] as JSObject)['client'], isNotNull);
      expect(
        ((globalContext['gapi'] as JSObject)['client'] as JSObject)['people'],
        isNull,
      );
      await gapiClient.load('people', 'v1');
      expect(
        ((globalContext['gapi'] as JSObject)['client'] as JSObject)['people'],
        isNotNull,
      );

      var success = false;
      try {
        await gapiClient.load('people', 'v0');
        success = true;
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
      expect(success, false);
    });
  });
}
