// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_google_jsapi/gapi_auth.dart';
import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'package:tekartik_google_jsapi/google_jsapi.dart' as legacy;
import 'package:test/test.dart';

/// A JS object of the JS functions [functions].
JSObject jsObjectWith(Map<String, JSFunction> functions) {
  var jsObject = JSObject();
  functions.forEach((name, function) {
    jsObject[name] = function;
  });
  return jsObject;
}

/// Installs a fake `gapi.auth2` whose `getAuthInstance()` is [authInstance].
void setFakeAuth2(JSObject authInstance) {
  var auth2 = jsObjectWith({'getAuthInstance': (() => authInstance).toJS});
  globalContext['gapi'] = JSObject()..['auth2'] = auth2;
}

/// The lines printed (Dart `print` in this zone and `console.log`) by
/// [action].
Future<List<String>> capturePrints(Future<void> Function() action) async {
  var lines = <String>[];
  var console = globalContext['console'] as JSObject;
  var log = console['log'];
  console['log'] = (JSAny? message) {
    lines.add(message.dartify().toString());
  }.toJS;
  try {
    await runZoned(
      action,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.add(line),
      ),
    );
  } finally {
    console['log'] = log;
  }
  return lines;
}

/// Fake js objects only, no Google script is loaded.
void main() {
  const timeout = Timeout(Duration(seconds: 30));
  tearDown(() {
    globalContext.delete('gapi'.toJS);
  });

  test('GoogleAuthResponse.token reads id_token', () {
    var jsAuthResponse = {'id_token': 'my_id_token'}.jsify();
    var jsUser = jsObjectWith({'getAuthResponse': (() => jsAuthResponse).toJS});
    var jsCurrentUser = jsObjectWith({'get': (() => jsUser).toJS});
    setFakeAuth2(JSObject()..['currentUser'] = jsCurrentUser);
    var user = GoogleAuth().getCurrentUser()!;
    expect(user.getAuthResponse().token, 'my_id_token');
  }, timeout: timeout);

  test('signOut and signIn print nothing', () async {
    JSPromise<JSAny?> resolved() => Future<JSAny?>.value(null).toJS;
    setFakeAuth2(
      jsObjectWith({
        'signOut': resolved.toJS,
        'signIn': (([JSAny? params]) => resolved()).toJS,
      }),
    );
    // Used to print onFullfilled for each promise
    var lines = await capturePrints(() async {
      await GoogleAuth().signOut();
      await GoogleAuth().signIn(GapiAuth2SignInParams()..prompt = 'consent');
    });
    expect(lines, isEmpty);
  }, timeout: timeout);

  test('signIn rejected completes with an error', () async {
    setFakeAuth2(
      jsObjectWith({
        // Promise.reject('popup_closed_by_user'), as gapi rejects
        'signIn':
            (([JSAny? params]) =>
                    (globalContext['Promise'] as JSObject).callMethod<JSAny?>(
                      'reject'.toJS,
                      'popup_closed_by_user'.toJS,
                    ))
                .toJS,
      }),
    );
    await expectLater(GoogleAuth().signIn(), throwsA('popup_closed_by_user'));
  }, timeout: timeout);

  test('onSignedIn: one JS listener, broadcast', () async {
    var listeners = <JSFunction>[];
    var isSignedIn = jsObjectWith({
      'listen': (JSFunction listener) {
        listeners.add(listener);
      }.toJS,
    });
    setFakeAuth2(JSObject()..['isSignedIn'] = isSignedIn);
    var auth = GoogleAuth();
    var values1 = <bool?>[];
    var values2 = <bool?>[];
    auth.onSignedIn.listen(values1.add);
    auth.onSignedIn.listen(values2.add);
    // Used to add one JS listener per read
    expect(listeners, hasLength(1));
    listeners.single.callAsFunction(null, true.toJS);
    listeners.single.callAsFunction(null, false.toJS);
    await Future<void>.delayed(Duration.zero);
    expect(values1, [true, false]);
    expect(values2, [true, false]);
  }, timeout: timeout);

  test('getAccessToken without token is null', () async {
    var auth = jsObjectWith({'getToken': (() => null).toJS});
    globalContext['gapi'] = JSObject()
      ..['load'] = (() {}).toJS
      ..['auth'] = auth;
    var gapiAuth = await loadGapiAuth();
    // Used to throw a cast error
    expect(gapiAuth.getAccessToken(), isNull);
  }, timeout: timeout);

  test('legacy authorize without access_token completes with an error', () {
    var jsAuth = jsObjectWith({
      'authorize': (JSAny? options, JSFunction callback) {
        // Google calls back asynchronously
        Timer.run(() {
          callback.callAsFunction(null, JSObject());
        });
      }.toJS,
    });
    expect(
      legacy.GapiAuth(jsAuth)
          .authorize('client_id', [legacy.GapiAuth.scopeEmail])
          .timeout(const Duration(seconds: 5)),
      throwsA(isNot(isA<TimeoutException>())),
    );
  }, timeout: timeout);
}
