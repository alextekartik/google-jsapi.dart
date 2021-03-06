library tekartik_google_jsapi.gapi_auth;

import 'dart:async';
import 'dart:js';

import 'gapi.dart';

class GapiAuth {
  JsObject? jsObject;

  GapiAuth._(this.jsObject);

  static const scopeEmail = 'email';
  static const approvalPromptForce = 'force';
  @deprecated
  // ignore: constant_identifier_names
  static const SCOPE_EMAIL = scopeEmail;
  @deprecated
  // ignore: constant_identifier_names
  static const APPROVAL_PROMPT_FORCE = approvalPromptForce;

  String? getAccessToken() {
    var jsToken = jsObject!.callMethod('getToken') as JsObject;
    return jsToken['access_token'] as String?;
  }

  /// approvalPrompt can be 'force'
  ///
  /// @return token
  Future<String> authorize(String clientId, List<String> scopes,
      {String? approvalPrompt}) {
    final completer = Completer<String>();
    var options = {
      'client_id': clientId,
      'scope': scopes,
      'immediate': false,
      'approval_prompt': approvalPrompt
    };
    var jsOptions = JsObject.jsify(options);
    void _onResult(JsObject? authResult) {
      if (authResult != null) {
        //print(jsObjectAsCollection(authResult));
        final e = gapiResponseParseException(authResult);
        if (e != null) {
          completer.completeError(e);
          return;
        }
        final oauthToken = authResult['access_token'] as String?;
        print('authed $oauthToken');
        completer.complete(oauthToken);
      } else {
        completer.completeError('no auth token');
      }
    }

    jsObject!.callMethod('authorize', [jsOptions, _onResult]);

    return completer.future;
  }
}

Future<GapiAuth> loadGapiAuth([Gapi? gapi]) async {
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['auth'] == null) {
    await gapi.load('auth');
  }
  return GapiAuth._(gapi['auth'] as JsObject?);
}
