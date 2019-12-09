library tekartik_google_jsapi.promise;

import 'dart:async';
import 'dart:js';

class Promise {
  final JsObject _jsObject;
  Promise(this._jsObject);

  Future get asFuture {
    final completer = Completer();
    _jsObject.callMethod('then', [
      // onFullfilled
      (value) {
        print('onFullfilled');
        completer.complete(value);
      },
      // onRejected
      (reason) {
        print('reason');
        completer.completeError(reason);
      }
    ]);
    return completer.future;
  }
}
