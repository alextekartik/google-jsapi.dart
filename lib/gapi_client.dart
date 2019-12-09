library tekartik_google_auth;

import 'dart:async';
import 'dart:js';

import 'gapi.dart';

class GapiClient {
  JsObject _jsObject;

  GapiClient() : this._(context['gapi']['client'] as JsObject);

  GapiClient._(this._jsObject);

  Future load(String api, String version) {
    final completer = Completer();
    void _onLoaded([jsData]) {
      if (jsData != null) {
        final e = gapiResponseParseException(jsData as JsObject);
        if (e != null) {
          completer.completeError(e);
          return;
        }
      }
      completer.complete();
    }

    final args = [api, version, _onLoaded];
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
  gapi ??= await loadGapiPlatform();

  // need loaded?
  if (gapi['client'] == null) {
    await gapi.load('client');
  }
  return GapiClient._(gapi['client'] as JsObject);
}
