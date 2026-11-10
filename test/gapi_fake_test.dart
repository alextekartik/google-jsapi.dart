@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:test/test.dart';

/// Installs a fake `window.gapi` (no Google script) whose
/// `load(api, options)` calls [onLoad] with the options it gets.
void setFakeGapi(void Function(String api, JSObject options) onLoad) {
  var gapi = JSObject();
  gapi['load'] = (JSString api, JSObject options) {
    onLoad(api.toDart, options);
  }.toJS;
  globalContext['gapi'] = gapi;
}

/// Calls the JS function `options[name]` later, as Google does, when given.
void callOption(JSObject options, String name) {
  Timer.run(() {
    (options[name] as JSFunction?)?.callAsFunction();
  });
}

void main() {
  const timeout = Timeout(Duration(seconds: 30));
  tearDown(() {
    globalContext.delete('gapi'.toJS);
  });

  group('gapi.load', () {
    test('callback', () async {
      setFakeGapi((api, options) => callOption(options, 'callback'));
      var gapi = await loadGapiPlatform();
      await gapi.load('picker').timeout(const Duration(seconds: 5));
    }, timeout: timeout);

    test('onerror completes with a GapiException', () async {
      setFakeGapi((api, options) => callOption(options, 'onerror'));
      var gapi = await loadGapiPlatform();
      // Used to never complete (only a callback was given to gapi)
      await expectLater(
        gapi.load('picker').timeout(const Duration(seconds: 5)),
        throwsA(isA<GapiException>()),
      );
    }, timeout: timeout);

    test('ontimeout completes with a TimeoutException', () async {
      setFakeGapi((api, options) => callOption(options, 'ontimeout'));
      var gapi = await loadGapiPlatform();
      await expectLater(
        gapi.load('picker').timeout(const Duration(seconds: 5)),
        throwsA(
          isA<TimeoutException>().having(
            (e) => e.message,
            'message',
            contains('gapi.load(picker)'),
          ),
        ),
      );
    }, timeout: timeout);

    test('timeout given to gapi', () async {
      var timeouts = <Object?>[];
      setFakeGapi((api, options) {
        timeouts.add(options['timeout'].dartify());
        callOption(options, 'callback');
      });
      var gapi = await loadGapiPlatform();
      await gapi.load('picker');
      await gapi.load('auth2', timeout: const Duration(seconds: 2));
      expect(timeouts, [30000, 2000]);
    }, timeout: timeout);
  });
}
