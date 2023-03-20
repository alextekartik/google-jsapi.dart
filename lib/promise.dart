library tekartik_google_jsapi.promise;

import 'dart:async';
import 'dart:js';

class Promise {
  final JsObject? _jsObject;
  Promise(this._jsObject);

  Future get asFuture {
    final completer = Completer<dynamic>();
    _jsObject!.callMethod('then', [
      // onFullfilled
      (dynamic value) {
        print('onFullfilled');
        completer.complete(value);
      },
      // onRejected
      (Object reason) {
        print('reason');
        completer.completeError(reason);
      }
    ]);
    return completer.future;
  }
}
