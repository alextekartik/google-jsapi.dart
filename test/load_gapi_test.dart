@TestOn('browser')
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/gapi.dart';

void main() {
  group('gapi', () {
    Gapi gapi;
    setUp(() {
      return loadGapi().then((Gapi _gapi) {
        gapi = _gapi;
      });
    });

    test('load', () async {
      await loadGapi();
      expect(gapi['auth2'], isNotNull);
      expect(gapi['client'], isNotNull);
      expect(gapi['auth'], isNotNull);
    });
  });
}
