library tekartik_google_jsapi.gapi_auth;

import 'dart:js';
import 'dart:async';
import 'gapi.dart';
import 'promise.dart';

class GapiAuth {
  JsObject jsObject;
  GapiAuth._(this.jsObject);

  static const SCOPE_EMAIL = 'email';
  static const APPROVAL_PROMPT_FORCE = 'force';

  String getAccessToken() {
    var jsToken = jsObject.callMethod('getToken');
    return jsToken['access_token'];
  }

  /**
   * approvalPrompt can be 'force'
   *
   * @return token
   */
  Future<String> authorize(String clientId, List<String> scopes, {String approvalPrompt}) {
    Completer completer = new Completer();
    if (clientId == null) {
      throw new ArgumentError("missing CLIENT_ID");
    }
    var options = {
      'client_id': clientId,
      'scope': scopes,
      'immediate': false,
      'approval_prompt': approvalPrompt
    };
    var jsOptions = new JsObject.jsify(options);
    void _onResult(authResult) {
      if (authResult != null) {
        //print(jsObjectAsCollection(authResult));
        Exception e = gapiResponseParseException(authResult);
        if (e != null) {
          completer.completeError(e);
          return;
        }
        String oauthToken = authResult['access_token'];
        print('authed $oauthToken');
        completer.complete(oauthToken);
      } else {
        completer.completeError('no auth token');
      }
    }
    jsObject.callMethod('authorize', [ jsOptions, _onResult ]);

    return completer.future;
  }
}

Future<GapiAuth> loadGapiAuth([Gapi gapi]) async {
  if (gapi == null) {
    gapi = await loadGapiPlatform();
  }
  // need loaded?
  if (gapi['auth'] == null) {
    await gapi.load('auth');
  }
  return new GapiAuth._(gapi['auth']);

}

