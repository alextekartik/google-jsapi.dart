part of tekartik_google_jsapi;

class GapiClient {
  JsObject jsObject;
  GapiClient(this.jsObject);

  Future load(String api, String version) {
    Completer completer = Completer();
    void _onLoaded([jsData]) {
      if (jsData != null) {
        Exception e = gapiResponseParseException(jsData as JsObject);
        if (e != null) {
          completer.completeError(e);
          return;
        }
      }
      completer.complete();
    }

    List args = [api, version, _onLoaded];
    jsObject.callMethod('load', args);

    return completer.future;
  }
}
