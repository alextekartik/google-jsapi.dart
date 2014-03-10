google-jsapi.dart
========================

Google jsapi loader for Dart

### Description

Dart library to use for Google jsapi / Client-side flow

### Usage/Installation

Go to [Google APIs Console](https://code.google.com/apis/console/) and create a new Project
Create a new `Client ID` for web applications in "API Access"
Set JavaScript origins to your server or for example `http://127.0.0.1:3030/` for local testing in Dartium

Add this dependency to your pubspec.yaml

```
  dependencies:
     tekartik_google_jsapi:
       git: https://github.com/alextekartik/google-jsapi.dart.git
```


### Web applications

Import the library in your dart application

```
  import "package:tekartik_google_jsapi/google_jsapi.dart";
```

Initialize the library with your parameters

### Initialialisation

```
  Gapi gapi;
  ...
  loadGapi().then((Gapi gapi_) {
    gapi = gapi_;
  });
```

### Authorized

```
  gapi.auth.authorize(cliendId, scopes).then(
        (String oauthToken) {
    print("client id '$clientId' authorized for '$scopes'";
  });
```
