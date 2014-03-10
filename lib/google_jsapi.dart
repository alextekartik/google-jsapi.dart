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
    print('trying');
    //print(context['gapi']['client']);
    JsObject jsGapi = context['gapi'];
    
    // test client to validate when loaded
    if ((jsGapi['client'] != null) && (jsGapi['auth'] != null)) {
      _googleJsClientLoaded = true;
      _gapi = new Gapi(jsGapi);
      return new Future.value(_gapi);
    } else {
      return new Future.delayed(new Duration(milliseconds: 1))
      .then((_) {
        return _checkGapiLoad();
      });
    }
  }
  if (_gapi == null) {
    return loadJavascriptScript('https://apis.google.com/js/client.js')
    .then((_) {
      return _checkGapiLoad();
    });
  }
  return new Future.sync(() => _gapi);
}