import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// A JS string, number or boolean as its Dart value, any other value as is.
Object? _resultValue(JSAny? value) {
  if (value == null) {
    return null;
  }
  if (value.isA<JSString>() ||
      value.isA<JSNumber>() ||
      value.isA<JSBoolean>()) {
    return value.dartify();
  }
  return value;
}

/// A JS promise or thenable (an object with a `then` method, as gapi
/// returns).
class Promise {
  final JSObject? _jsObject;

  /// Wraps the JS promise or thenable.
  Promise(this._jsObject);

  /// Completes with the value (a string, number or boolean as its Dart
  /// value, an object as a `JSAny`), or with the rejection reason.
  Future get asFuture {
    final completer = Completer<dynamic>();
    _jsObject!.callMethod<JSAny?>(
      'then'.toJS,
      // onFulfilled
      (JSAny? value) {
        if (!completer.isCompleted) {
          completer.complete(_resultValue(value));
        }
      }.toJS,
      // onRejected
      (JSAny? reason) {
        if (!completer.isCompleted) {
          completer.completeError(_resultValue(reason) ?? 'rejected');
        }
      }.toJS,
    );
    return completer.future;
  }
}
