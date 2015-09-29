library tekartik_google_auth;

import 'dart:js';
import 'dart:async';
import 'gapi.dart';

class GapiClient {
  JsObject _jsObject;
  GapiClient() : this._(context['gapi']['client']);

  GapiClient._(this._jsObject);

  Future load(String api, String version) {
    Completer completer = new Completer();
    void _onLoaded([jsData]) {

      if (jsData != null) {
        Exception e = gapiResponseParseException(jsData);
        if (e != null) {
          completer.completeError(e);
          return;
        }
      }
      completer.complete();
    }
    List args = [ api, version, _onLoaded ];
    _jsObject.callMethod('load', args);

    return completer.future;
  }

  // somehow this is not working...
  /*
  Future _load(String api, String version) {
    new Promise(_jsObject.callMethod('load', [ api, version])).asFuture;
  }
  */
}

Future<GapiClient> loadGapiClient([Gapi gapi]) async {
  if (gapi == null) {
    gapi = await loadGapiPlatform();
  }
  // need loaded?
  if (gapi['client'] == null) {
    await gapi.load('client');
  }
  return new GapiClient._(gapi['client']);

}


