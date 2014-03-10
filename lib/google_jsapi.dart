library google_jsapi;

import 'dart:async';
import 'dart:js';

import 'js_utils.dart';

part 'src/auth.dart';
part 'src/client.dart';
part 'src/gapi.dart';


Gapi _gapi;

Future<Gapi> loadGapi() {
  Future _checkGapiLoad() {
    // print('trying');
    if (context.hasProperty('gapi')) {
      JsObject jsGapi = context['gapi'];
      // We wait for client and auth to be loaded
      // not sure that is sufficient however they are sometimes no set on load
      if (jsGapi.hasProperty('client') && jsGapi.hasProperty('auth')) {
        print('got it');
        _googleJsClientLoaded = true;
        _gapi = new Gapi(jsGapi);
        return new Future.value(_gapi);
      }
    }
    return new Future.delayed(new Duration(milliseconds: 1)).then((_) {
      return _checkGapiLoad();
    });

  }
  if (_gapi == null) {
    return loadJavascriptScript('https://apis.google.com/js/client.js').then((_)
        {
      return _checkGapiLoad();
    });
  }
  return new Future.sync(() => _gapi);
}
