part of tekartik_google_jsapi;

class GapiAuth {
  JsObject jsObject;
  GapiAuth(this.jsObject);

  static const scopeEmail = 'email';
  static const approvalPromptForce = 'force';
  @deprecated
  // ignore: constant_identifier_names
  static const SCOPE_EMAIL = scopeEmail;
  @deprecated
  // ignore: constant_identifier_names
  static const APPROVAL_PROMPT_FORCE = approvalPromptForce;

  String getAccessToken() {
    var jsToken = jsObject.callMethod('getToken') as JsObject;
    return jsToken['access_token'] as String;
  }

  /// approvalPrompt can be 'force'
  ///
  /// @return token
  Future<String> authorize(String clientId, List<String> scopes,
      {String approvalPrompt}) {
    final completer = Completer<String>();
    if (clientId == null) {
      throw ArgumentError('missing CLIENT_ID');
    }
    var options = {
      'client_id': clientId,
      'scope': scopes,
      'immediate': false,
      'approval_prompt': approvalPrompt
    };
    var jsOptions = JsObject.jsify(options);
    void _onResult(authResult) {
      if (authResult != null) {
        //print(jsObjectAsCollection(authResult));
        final e = gapiResponseParseException(authResult as JsObject);
        if (e != null) {
          completer.completeError(e);
          return;
        }
        final oauthToken = (authResult as JsObject)['access_token'] as String;
        print('authed $oauthToken');
        completer.complete(oauthToken);
      } else {
        completer.completeError('no auth token');
      }
    }

    jsObject.callMethod('authorize', [jsOptions, _onResult]);

    return completer.future;
  }
}
