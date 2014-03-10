part of google_jsapi;

bool _googleJsClientLoaded;


class Gapi {
  JsObject jsObject;
  Gapi(this.jsObject);
  
  JsObject get jsGapi => jsObject; 
  
  GapiAuth _auth;
  GapiClient _client;
  
  GapiAuth get auth {
    if (_auth == null) {
      _auth = new GapiAuth(jsObject['auth']);
    }
    return _auth;
  }
  
  GapiClient get client {
    if (_client == null) {
      _client = new GapiClient(jsObject['client']);
    }
    return _client;
  }
  
  
  Future load(String api) {
    Completer completer = new Completer();
    void _onLoaded([jsData]) {
      completer.complete();
    }
    var jsOptions = new JsObject.jsify({'callback': _onLoaded});
    List args = [ api, jsOptions ];
    jsObject.callMethod('load', args);
    
    return completer.future;
  }
  
}



class GapiException implements Exception {
    /**
     * A message describing the format error.
     */
    final String message;

    /**
     * Creates a new FormatException with an optional error [message].
     */
    const GapiException([this.message = ""]);
    String toString() => "GapiException: $message";
}

Exception gapiResponseParseException(JsObject jsData) {
  if (jsData != null) {
    var jsError = jsData['error'];
    if (jsError != null) {
      if ((jsError is JsObject) && (!(jsError is JsArray))) {
        int code = jsError['code'];
        String message = jsError['message'];
        return new GapiException("$code - $message");
      } else {
        return new GapiException('error');
      }
    }
  }
  return null;
}

