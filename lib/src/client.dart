part of tekartik_google_jsapi;

class GapiClient {
  JsObject? jsObject;
  GapiClient(this.jsObject);

  Future load(String api, String version) {
    final completer = Completer();
    void onLoaded([jsData]) {
      if (jsData != null) {
        final e = gapiResponseParseException(jsData as JsObject);
        if (e != null) {
          completer.completeError(e);
          return;
        }
      }
      completer.complete();
    }

    final args = [api, version, onLoaded];
    jsObject!.callMethod('load', args);

    return completer.future;
  }
}
