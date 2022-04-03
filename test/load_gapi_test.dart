@TestOn('browser')
library load_gapi_test;

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

void main() {
  group('gapi', () {
    late Gapi gapi;
    setUp(() {
      return loadGapi().then((Gapi loadedGapi) {
        gapi = loadedGapi;
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
