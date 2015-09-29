library tekartik_google_auth;

import 'dart:js';
import 'dart:async';
import 'gapi.dart';
import 'promise.dart';

class BasicProfile {
  JsObject _jsObject;
  BasicProfile._(this._jsObject);
  String get name => _jsObject.callMethod('getName');
  String get id => _jsObject.callMethod('getId');
  String get email => _jsObject.callMethod('getEmail');
  String get imageUrl => _jsObject.callMethod('getImageUrl');
  toString() {
    return "${id} ${name} ${email} ${imageUrl}";
  }
}

class GoogleUser {
  JsObject _jsObject;
  GoogleUser._(this._jsObject);
  String get id => _jsObject.callMethod('getId');
  BasicProfile get basicProfile =>
      new BasicProfile._(_jsObject.callMethod('getBasicProfile'));
  toString() {
    return "${id} ${isSignedIn}";
  }

  bool get isSignedIn => _jsObject.callMethod('isSignedIn');

  void disconnect() {
    _jsObject.callMethod('disconnect');
  }
}

// https://openid.net/specs/openid-connect-basic-1_0.html#RequestParameters
class GapiAuth2SignInParams {
  String prompt; // none,login,consent,select_account
  JsObject jsify() {
    Map map = {};
    map['prompt'] = prompt;
    return new JsObject.jsify(map);
  }
}

class GoogleAuth {
  JsObject _jsObject;
  GoogleAuth._(this._jsObject);
  GoogleAuth() {
    JsObject auth2 = context['gapi']['auth2'];
    _jsObject = auth2.callMethod('getAuthInstance');
    //print(jsObjectToDebugString(_jsObject));
  }

  GoogleUser getCurrentUser() {
    JsObject jsCurrentUser =
        (_jsObject['currentUser'] as JsObject).callMethod('get');
    if (jsCurrentUser != null) {
      return new GoogleUser._(jsCurrentUser);
    }
    return null;
  }
  bool getIsSignedIn() {
    return (_jsObject['isSignedIn'] as JsObject).callMethod('get');
  }

  Future signOut() async {
    await new Promise(_jsObject.callMethod('signOut')).asFuture;
  }

  Future signIn([GapiAuth2SignInParams params]) async {
    var _params = params == null ? null: params.jsify();
    await new Promise(_jsObject.callMethod('signIn', [_params])).asFuture;
  }

  void disconnect() {
    _jsObject.callMethod('disconnect');
  }
}

class GapiAuth2InitParams {
  String clientId;
  List<String> scopes;

  JsObject jsify() {
    Map map = {};
    map['client_id'] = clientId;
    map['scope'] = scopes.join(' ');
    return new JsObject.jsify(map);
  }
}

class GapiAuth2 {
  JsObject _jsObject;
  GapiAuth2() {
    _jsObject = context['gapi']['auth2'];
  }
  GapiAuth2._(this._jsObject);

  GoogleAuth init(GapiAuth2InitParams params) {
    return new GoogleAuth._(_jsObject.callMethod('init', [params.jsify()]));
  }
  GoogleAuth getAuthInstance() {
    return new GoogleAuth._(_jsObject.callMethod('getAuthInstance'));
  }
}
Future<GapiAuth2> loadGapiAuth2([Gapi gapi]) async {
  if (gapi == null) {
    gapi = await loadGapiPlatform();
  }
  // need loaded?
  if (gapi['auth2'] == null) {
    await gapi.load('auth2');
  }
  return new GapiAuth2._(gapi['auth2']);

}


