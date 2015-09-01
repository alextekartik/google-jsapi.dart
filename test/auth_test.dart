@TestOn("browser && !content-shell")
library auth_test;

import 'package:test/test.dart';

import 'package:tekartik_google_jsapi/google_jsapi.dart';
import 'test_config.dart';

void main() {
  
  group('auth', () {
    authMain();
  });
}

void authMain() {
  group('gapi', () {
    Gapi gapi;
    setUp(() {
      return loadGapi().then((Gapi _gapi) {
        gapi = _gapi;
      });
    });
    
    test('auth', () {
      expect(gapi.auth, isNotNull);
    });
    
    test('authorize auth', () {
      return gapi.auth.authorize(CLIENT_ID, [GapiAuth.SCOPE_EMAIL]);
    });

    /*
    // to skip
    skip_test('authorize auth prompt', () {
      return gapi.auth.authorize(CLIENT_ID, [GapiAuth.SCOPE_EMAIL], approvalPrompt: GapiAuth.APPROVAL_PROMPT_FORCE);
    });
    */
    
    
  });
}