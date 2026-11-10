# Changelog

## 0.3.0

- `dart:js_interop` and `package:web` instead of `dart:js` / `dart:html`:
  dart2js and dart2wasm (breaking: `JSObject` instead of `JsObject`,
  `operator []` returns `JSAny?`).
- One implementation instead of the two legacy copies.
- A module load error or timeout is reported (loads slower than 30 s time
  out); the endless 1 ms poll is a bounded wait.
- No more prints; one sign-in listener per `GoogleAuth`.
- `gapi.auth` and `gapi.auth2` still load and work; the README points to
  Google Identity Services, their replacement.
