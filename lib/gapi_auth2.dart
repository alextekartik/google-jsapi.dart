/// `gapi.auth2`, Google Sign-In for Web: [loadGapiAuth2],
/// [GapiAuth2.init], [GoogleAuth] (sign in and out, current user).
///
/// Deprecated by Google and closed to new client ids: new code signs in
/// with Google Identity Services (`accounts.google.com/gsi/client`).
@Deprecated('gapi.auth2 is deprecated by Google, use Google Identity Services')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_common_utils/bool_utils.dart';

import 'src/gapi_impl.dart';
import 'src/promise_impl.dart';

/// The JS `gapi` global object.
JSObject get _gapi => globalContext['gapi'] as JSObject;

/// The profile of a [GoogleUser].
class BasicProfile {
  final JSObject? _jsObject;

  BasicProfile._(this._jsObject);

  String? _call(String method) =>
      _jsObject!.callMethod<JSString?>(method.toJS)?.toDart;

  /// The full name.
  String? get name => _call('getName');

  /// The Google id.
  String? get id => _call('getId');

  /// The email.
  String? get email => _call('getEmail');

  /// The url of the picture.
  String? get imageUrl => _call('getImageUrl');

  @override
  String toString() {
    return '$id $name $email $imageUrl';
  }
}

/// The auth response of a [GoogleUser].
class GoogleAuthResponse {
  final JSObject? _jsObject;

  GoogleAuthResponse._(this._jsObject);

  /// The id token (`id_token`).
  String? get token => (_jsObject!['id_token'] as JSString?)?.toDart;
}

/// A signed in (or not) Google user.
class GoogleUser {
  final JSObject _jsObject;

  GoogleUser._(this._jsObject);

  /// The Google id.
  String? get id => _jsObject.callMethod<JSString?>('getId'.toJS)?.toDart;

  /// The profile.
  BasicProfile get basicProfile =>
      BasicProfile._(_jsObject.callMethod<JSObject?>('getBasicProfile'.toJS));

  @override
  String toString() {
    return '$id $isSignedIn';
  }

  /// Whether signed in.
  bool? get isSignedIn =>
      _jsObject.callMethod<JSBoolean?>('isSignedIn'.toJS)?.toDart;

  /// The auth response (id token).
  GoogleAuthResponse getAuthResponse() {
    var jsAuthResponse = _jsObject.callMethod<JSObject?>(
      'getAuthResponse'.toJS,
    );
    return GoogleAuthResponse._(jsAuthResponse);
  }

  /// Revokes the scopes granted by the user.
  void disconnect() {
    _jsObject.callMethod<JSAny?>('disconnect'.toJS);
  }
}

/// The parameters of [GoogleAuth.signIn].
///
/// https://openid.net/specs/openid-connect-basic-1_0.html#RequestParameters
class GapiAuth2SignInParams {
  /// `none`, `login`, `consent` or `select_account`.
  String? prompt; // none,login,consent,select_account

  /// The JS options object.
  JSObject jsify() {
    final map = <String, Object?>{};
    map['prompt'] = prompt;
    return map.jsify() as JSObject;
  }
}

/// The `GoogleAuth` instance of `gapi.auth2`.
class GoogleAuth {
  JSObject? _jsObject;

  GoogleAuth._(this._jsObject);

  /// The instance of `gapi.auth2.getAuthInstance()`.
  GoogleAuth() {
    final auth2 = _gapi['auth2'] as JSObject;
    _jsObject = auth2.callMethod<JSObject?>('getAuthInstance'.toJS);
  }

  /// The current user, null when none.
  GoogleUser? getCurrentUser() {
    final jsCurrentUser = (_jsObject!['currentUser'] as JSObject)
        .callMethod<JSObject?>('get'.toJS);
    if (jsCurrentUser != null) {
      return GoogleUser._(jsCurrentUser);
    }
    return null;
  }

  /// Whether a user is signed in.
  bool? getIsSignedIn() {
    return (_jsObject!['isSignedIn'] as JSObject)
        .callMethod<JSBoolean?>('get'.toJS)
        ?.toDart;
  }

  StreamController<bool?>? _onSignedInController;

  /// The signed in changes (a broadcast stream): one JS listener for this
  /// [GoogleAuth], whatever the number of reads and listeners.
  Stream<bool?> get onSignedIn {
    var controller = _onSignedInController;
    if (controller == null) {
      controller = _onSignedInController = StreamController<bool?>.broadcast();
      (_jsObject!['isSignedIn'] as JSObject).callMethod<JSAny?>(
        'listen'.toJS,
        (JSAny? value) {
          controller!.add(parseBool(value?.dartify()));
        }.toJS,
      );
    }
    return controller.stream;
  }

  /// Signs out.
  Future signOut() async {
    await Promise(_jsObject!.callMethod<JSObject?>('signOut'.toJS)).asFuture;
  }

  /// Signs in (a popup), with [params].
  Future signIn([GapiAuth2SignInParams? params]) async {
    var jsParams = params?.jsify();
    await Promise(
      _jsObject!.callMethod<JSObject?>('signIn'.toJS, jsParams),
    ).asFuture;
  }

  /// Revokes the scopes granted by the user.
  void disconnect() {
    _jsObject!.callMethod<JSAny?>('disconnect'.toJS);
  }
}

/// The parameters of [GapiAuth2.init].
class GapiAuth2InitParams {
  /// The OAuth client id.
  String? clientId;

  /// The scopes asked.
  late List<String> scopes;

  // exp
  //String userId;

  /// The JS options object.
  JSObject jsify() {
    return toJson().jsify() as JSObject;
  }

  /// The options as a map (`client_id`, `scope`).
  Map toJson() {
    final map = <String, Object?>{};
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

/// `gapi.auth2`.
class GapiAuth2 {
  JSObject? _jsObject;

  /// The `gapi.auth2` of the page.
  GapiAuth2() {
    _jsObject = _gapi['auth2'] as JSObject?;
  }

  GapiAuth2._(this._jsObject);

  /// Initializes Google Sign-In.
  GoogleAuth init(GapiAuth2InitParams params) {
    return GoogleAuth._(
      _jsObject!.callMethod<JSObject?>('init'.toJS, params.jsify()),
    );
  }

  /// The `GoogleAuth` instance (after [init]).
  GoogleAuth getAuthInstance() {
    return GoogleAuth._(
      _jsObject!.callMethod<JSObject?>('getAuthInstance'.toJS),
    );
  }
}

/// Loads the `auth2` module (in [gapi], the platform one by default).
Future<GapiAuth2> loadGapiAuth2([Gapi? gapi]) async {
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['auth2'] == null) {
    await gapi.load('auth2');
  }
  return GapiAuth2._(gapi['auth2'] as JSObject?);
}
