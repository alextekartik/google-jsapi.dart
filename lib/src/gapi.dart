part of '../google_jsapi.dart';

// bool _googleJsClientLoaded;

class Gapi {
  JsObject? jsObject;
  Gapi(this.jsObject);

  JsObject? get jsGapi => jsObject;

  GapiAuth? _auth;
  GapiClient? _client;

  // use load auth
  @Deprecated('User load.auth')
  GapiAuth? get auth {
    _auth ??= GapiAuth(jsObject!['auth'] as JsObject?);
    return _auth;
  }

  dynamic operator [](String key) => jsObject![key];

  // use load client
  GapiClient? get client {
    _client ??= GapiClient(jsObject!['client'] as JsObject?);
    return _client;
  }

  Future load(String api) {
    final completer = Completer<dynamic>();
    void onLoaded([jsData]) {
      completer.complete();
    }

    var jsOptions = JsObject.jsify({'callback': onLoaded});
    final args = [api, jsOptions];
    jsObject!.callMethod('load', args);

    return completer.future;
  }
}

class GapiException implements Exception {
  /// A message describing the format error.
  final String message;

  /// Creates a new FormatException with an optional error [message].
  const GapiException([this.message = '']);
  @override
  String toString() => 'GapiException: $message';
}

Exception? gapiResponseParseException(JsObject jsData) {
  var jsError = jsData['error'];
  if (jsError != null) {
    if ((jsError is JsObject) && (jsError is! JsArray)) {
      final code = jsError['code'] as int?;
      final message = jsError['message'] as String?;
      return GapiException('$code - $message');
    } else {
      return const GapiException('error');
    }
  }
  return null;
}
