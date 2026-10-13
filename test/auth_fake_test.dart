// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'package:tekartik_google_jsapi/google_jsapi.dart' as legacy;
import 'package:test/test.dart';

/// Fake js objects only, no Google script is loaded.
void main() {
  test('GoogleAuthResponse.token reads id_token', () {
    var jsAuthResponse = JsObject.jsify({'id_token': 'my_id_token'});
    var jsUser = JsObject.jsify({});
    jsUser['getAuthResponse'] = () => jsAuthResponse;
    var jsCurrentUser = JsObject.jsify({});
    jsCurrentUser['get'] = () => jsUser;
    var jsAuthInstance = JsObject.jsify({'currentUser': jsCurrentUser});
    var jsAuth2 = JsObject.jsify({});
    jsAuth2['getAuthInstance'] = () => jsAuthInstance;
    context['gapi'] = JsObject.jsify({'auth2': jsAuth2});
    try {
      var user = GoogleAuth().getCurrentUser()!;
      expect(user.getAuthResponse().token, 'my_id_token');
    } finally {
      context.deleteProperty('gapi');
    }
  });

  test('legacy authorize without access_token completes with an error', () {
    var jsAuth = JsObject.jsify({});
    jsAuth['authorize'] = (Object? options, Object? callback) {
      // Google calls back asynchronously
      Timer.run(() {
        var jsResult = JsObject.jsify({});
        if (callback is JsFunction) {
          callback.apply([jsResult]);
        } else {
          (callback as Function)(jsResult);
        }
      });
    };
    expect(
      legacy.GapiAuth(jsAuth)
          .authorize('client_id', [legacy.GapiAuth.scopeEmail])
          .timeout(const Duration(seconds: 5)),
      throwsA(isNot(isA<TimeoutException>())),
    );
  });
}
