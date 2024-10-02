library;

import 'dart:html';
import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_auth.dart';

import 'test_setup.dart';

Gapi? gapi;
late GapiAuth gapiAuth;
Storage storage = window.localStorage;

String storageKeyPref = 'com.tekartik.google_jsapi_example';
String? storageGet(String key) {
  return storage['$storageKeyPref.$key'];
}

void storageSet(String key, String? value) {
  if (value == null) {
    storage.remove('$storageKeyPref.$key');
  } else {
    storage['$storageKeyPref.$key'] = value;
  }
}

String gapiAutoLoadKey = 'gapi_autoload'; // boolean
String gapiAutoSignInKey = 'gapi_autosignin'; // boolean
String gapiAutoSignInUserKey = 'gapi_autosignin_user'; // boolean
String authApprovalPromptKey = 'auth_approval_prompt'; // boolean
String clientIdKey = 'client_id';
String scopesKey = 'scopes';

Future<void> authMain() async {
  final authForm = querySelector('form.app-auth')!;
  authForm.classes.remove('hidden');
  final authorizeButton = authForm.querySelector('button.app-authorize')!;
  var clientIdInput =
      authForm.querySelector('input#appInputClientId') as InputElement;
  final scopesInput =
      authForm.querySelector('input#appInputScopes') as InputElement;
  final authorizeResult = authForm.querySelector('.app-result');
  final autoSignInCheckbox =
      authForm.querySelector('.app-autosignin') as CheckboxInputElement;
  final approvalPromptCheckbox =
      authForm.querySelector('.app-approval-prompt') as CheckboxInputElement;

  var appOptions = await setup();
  clientIdInput.value = storageGet(clientIdKey) ?? appOptions?.clientId;
  scopesInput.value = storageGet(scopesKey);

  var approvalPrompt = storageGet(authApprovalPromptKey);

  approvalPromptCheckbox.checked =
      (approvalPrompt == GapiAuth.approvalPromptForce);

  final autoSignIn = storageGet(gapiAutoSignInKey) == true.toString();
  autoSignInCheckbox.checked = autoSignIn;

  void signIn() {
    final clientId = clientIdInput.value!;
    if (clientId.isEmpty) {
      authorizeResult!.innerHtml = 'Missing CLIENT ID';
      return;
    }
    storageSet(clientIdKey, clientId);

    final scopesString = scopesInput.value!;
    storageSet(scopesKey, scopesString);
    final scopes = scopesString.split(',');

    gapiAuth
        .authorize(clientId, scopes, approvalPrompt: approvalPrompt)
        .then((String oauthToken) {
      authorizeResult!.text = "client id '$clientId' authorized for '$scopes'";
    });
  }

  authorizeButton.onClick.listen((Event event) {
    event.preventDefault();
    signIn();
  });

  approvalPromptCheckbox.onChange.listen((_) {
    approvalPrompt =
        approvalPromptCheckbox.checked! ? GapiAuth.approvalPromptForce : null;
    storageSet(authApprovalPromptKey, approvalPrompt);
  });

  autoSignInCheckbox.onChange.listen((_) {
    storageSet(
        gapiAutoSignInKey, (autoSignInCheckbox.checked == true).toString());
  });

  if (autoSignIn) {
    signIn();
  }
}

Element? loadGapiResult;

Future _loadGapi() async {
  loadGapiResult!.innerHtml = 'loading...';
  final gapi = await loadGapi().then((gapi) {
    loadGapiResult!.innerHtml = 'Gapi loaded';
    return gapi;
  }, onError: (Object e, st) {
    loadGapiResult!.innerHtml = 'load failed $e';
    throw e;
  });
  gapiAuth = await loadGapiAuth(gapi);
  await authMain();
}

void main() {
  final loadGapiForm = querySelector('form.app-gapi')!;
  final loadGapiButton = loadGapiForm.querySelector('button.app-load')!;
  loadGapiResult = loadGapiForm.querySelector('.app-result');
  final autoLoadCheckbox =
      loadGapiForm.querySelector('.app-autoload') as CheckboxInputElement;

  final autoload = storageGet(gapiAutoLoadKey) == true.toString();

  autoLoadCheckbox.checked = autoload;

  loadGapiButton.onClick.listen((Event event) {
    event.preventDefault();
    _loadGapi();
  });

  autoLoadCheckbox.onChange.listen((_) {
    storageSet(gapiAutoLoadKey, autoLoadCheckbox.checked.toString());
  });

  if (autoload) {
    _loadGapi();
  }
}
