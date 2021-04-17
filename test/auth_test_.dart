@TestOn('browser')
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/gapi_auth.dart';
import 'test_config.dart';

void main() {
  group('auth', () {
    authMain();
  });
}

void authMain() {
  group('gapi', () {
    late GapiAuth gapiAuth;
    setUp(() async {
      gapiAuth = await loadGapiAuth();
    });

    test('auth', () {
      expect(gapiAuth, isNotNull);
    });

    test('authorize auth', () {
      return gapiAuth.authorize(clientId, [GapiAuth.scopeEmail]);
    });

    /*
    // to skip
    skip_test('authorize auth prompt', () {
      return gapi.auth.authorize(CLIENT_ID, [GapiAuth.SCOPE_EMAIL], approvalPrompt: GapiAuth.APPROVAL_PROMPT_FORCE);
    });
    */
  });
}
