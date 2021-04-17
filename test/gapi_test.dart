@TestOn('browser')
// somehow it does not work in content-shell
library gapi_test;

import 'dart:async';

import 'package:test/test.dart';

// ignore: deprecated_member_use_from_same_package
import 'package:tekartik_google_jsapi/google_jsapi.dart';

late Gapi gapi;
Future<Gapi> testLoadGapi() {
  return loadGapi().then((Gapi _gapi) {
    gapi = _gapi;
    return gapi;
  });
}

void main() {
  group('gapi', () {
    gapiMain();
  });
}

void gapiMain() {
  group('not loaded', () {
    test('load gapi', () {
      return loadGapi().then((Gapi gapi) {
        expect(gapi.jsGapi!['auth'], isNotNull);
        expect(gapi.jsGapi!['client'], isNotNull);
      });
    });
  });

  group('ok', () {
    setUp(() {
      return testLoadGapi();
    });

    test('load bad client', () {
      return gapi.client!.load('drive', 'v3').catchError((e) {
        expect(e is GapiException, true);
      }); // v3 does not exist yet
    });

    test('load drive v2 client', () {
      return gapi.client!.load('drive', 'v2'); // v2 does exist
    });

    test('load picker', () {
      return gapi.load('picker');
    });

    /*
    skip_test('load picker 1', () {
      return gapi.client.load('picker', '1');
    });
    */
  });
}
