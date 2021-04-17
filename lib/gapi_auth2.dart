library tekartik_google_auth;

import 'dart:async';
import 'dart:js';

import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_common_utils/bool_utils.dart';

import 'gapi.dart';
import 'promise.dart';

class BasicProfile {
  final JsObject _jsObject;

  BasicProfile._(this._jsObject);

  String get name => _jsObject.callMethod('getName') as String;

  String get id => _jsObject.callMethod('getId') as String;

  String get email => _jsObject.callMethod('getEmail') as String;

  String get imageUrl => _jsObject.callMethod('getImageUrl') as String;

  @override
  String toString() {
    return '$id $name $email $imageUrl';
  }
}

class GoogleAuthResponse {
  final JsObject _jsObject;

  GoogleAuthResponse._(this._jsObject);

  String get token => _jsObject.callMethod('id_token') as String;
}

class GoogleUser {
  final JsObject _jsObject;

  GoogleUser._(this._jsObject);

  String get id => _jsObject.callMethod('getId') as String;

  BasicProfile get basicProfile =>
      BasicProfile._(_jsObject.callMethod('getBasicProfile') as JsObject);

  @override
  String toString() {
    return '$id $isSignedIn';
  }

  bool get isSignedIn => _jsObject.callMethod('isSignedIn') as bool;

  GoogleAuthResponse getAuthResponse() {
    var _jsAuthResponse = _jsObject.callMethod('getAuthResponse') as JsObject;
    // devPrint(jsObjectKeys(_jsAuthResponse));
    return GoogleAuthResponse._(_jsAuthResponse);
  }

  void disconnect() {
    _jsObject.callMethod('disconnect');
  }
}

// https://openid.net/specs/openid-connect-basic-1_0.html#RequestParameters
class GapiAuth2SignInParams {
  String prompt; // none,login,consent,select_account
  JsObject jsify() {
    final map = {};
    map['prompt'] = prompt;
    return JsObject.jsify(map);
  }
}

class GoogleAuth {
  JsObject _jsObject;

  GoogleAuth._(this._jsObject);

  GoogleAuth() {
    final auth2 = (context['gapi'] as JsObject)['auth2'] as JsObject;
    _jsObject = auth2.callMethod('getAuthInstance') as JsObject;
    //print(jsObjectToDebugString(_jsObject));
  }

  GoogleUser getCurrentUser() {
    final jsCurrentUser =
        (_jsObject['currentUser'] as JsObject).callMethod('get') as JsObject;
    if (jsCurrentUser != null) {
      return GoogleUser._(jsCurrentUser);
    }
    return null;
  }

  bool getIsSignedIn() {
    return (_jsObject['isSignedIn'] as JsObject).callMethod('get') as bool;
  }

  Stream<bool> get onSignedIn {
    final ctlr = StreamController();
    void signInChange(bool val) {
      ctlr.add(bool);
    }

    (_jsObject['isSignedIn'] as JsObject).callMethod('listen', [signInChange]);
    return ctlr.stream.transform(StreamTransformer<dynamic, bool>.fromHandlers(
        handleData: (data, sink) => sink.add(parseBool(data))));
  }

  Future signOut() async {
    await Promise(_jsObject.callMethod('signOut') as JsObject).asFuture;
  }

  Future signIn([GapiAuth2SignInParams params]) async {
    var _params = params == null ? null : params.jsify();
    await Promise(_jsObject.callMethod('signIn', [_params]) as JsObject)
        .asFuture;
  }

  void disconnect() {
    _jsObject.callMethod('disconnect');
  }
}

class GapiAuth2InitParams {
  String clientId;
  List<String> scopes;

  // exp
  //String userId;

  JsObject jsify() {
    return JsObject.jsify(toJson());
  }

  Map toJson() {
    final map = {};
    map['client_id'] = clientId;
    map['scope'] = scopes.join(' ');
    /*
    if (userId != null && userId.length > 0) {
      map['authuser'] = -1;
      map['user_id'] = userId;
    }
    */
    return map;
  }

  @override
  String toString() => '${toJson()}';
}

class GapiAuth2 {
  JsObject _jsObject;

  GapiAuth2() {
    _jsObject = (context['gapi'] as JsObject)['auth2'] as JsObject;
  }

  GapiAuth2._(this._jsObject);

  GoogleAuth init(GapiAuth2InitParams params) {
    return GoogleAuth._(
        _jsObject.callMethod('init', [params.jsify()]) as JsObject);
  }

  GoogleAuth getAuthInstance() {
    return GoogleAuth._(_jsObject.callMethod('getAuthInstance') as JsObject);
  }
}

Future<GapiAuth2> loadGapiAuth2([Gapi gapi]) async {
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['auth2'] == null) {
    await gapi.load('auth2');
  }
  return GapiAuth2._(gapi['auth2'] as JsObject);
}
