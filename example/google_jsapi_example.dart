library google_jsapi_example;

import 'dart:html';
import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_auth.dart';

Gapi gapi;
GapiAuth gapiAuth;
Storage storage = window.localStorage;

String storageKeyPref = 'com.tekartik.google_jsapi_example';
dynamic storageGet(String key) {
  return storage['$storageKeyPref.$key'];
}

void storageSet(String key, String value) {
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

void authMain() {
  Element authForm = querySelector('form.app-auth');
  authForm.classes.remove('hidden');
  Element authorizeButton = authForm.querySelector('button.app-authorize');
  InputElement clientIdInput = authForm.querySelector('input#appInputClientId');
  InputElement scopesInput = authForm.querySelector('input#appInputScopes');
  Element authorizeResult = authForm.querySelector('.app-result');
  CheckboxInputElement autoSignInCheckbox =
      authForm.querySelector('.app-autosignin');
  CheckboxInputElement approvalPromptCheckbox =
      authForm.querySelector('.app-approval-prompt');

  clientIdInput.value = storageGet(clientIdKey);
  scopesInput.value = storageGet(scopesKey);

  String approvalPrompt = storageGet(authApprovalPromptKey);

  approvalPromptCheckbox.checked =
      (approvalPrompt == GapiAuth.APPROVAL_PROMPT_FORCE);

  bool autoSignIn = storageGet(gapiAutoSignInKey) == true.toString();
  autoSignInCheckbox.checked = autoSignIn;

  _signIn() {
    String clientId = clientIdInput.value;
    if (clientId.length < 1) {
      authorizeResult.innerHtml = 'Missing CLIENT ID';
      return;
    }
    storageSet(clientIdKey, clientId);

    String scopesString = scopesInput.value;
    storageSet(scopesKey, scopesString);
    List<String> scopes = scopesString.split(',');

    gapiAuth
        .authorize(clientId, scopes, approvalPrompt: approvalPrompt)
        .then((String oauthToken) {
      authorizeResult.text = "client id '$clientId' authorized for '$scopes'";
    });
  }
  authorizeButton.onClick.listen((Event event) {
    event.preventDefault();
    _signIn();
  });

  approvalPromptCheckbox.onChange.listen((_) {
    approvalPrompt =
        approvalPromptCheckbox.checked ? GapiAuth.APPROVAL_PROMPT_FORCE : null;
    storageSet(authApprovalPromptKey, approvalPrompt);
  });

  autoSignInCheckbox.onChange.listen((_) {
    storageSet(
        gapiAutoSignInKey, (autoSignInCheckbox.checked == true).toString());
  });

  if (autoSignIn) {
    _signIn();
  }
}

Element loadGapiResult;

_loadGapi() async {
  loadGapiResult.innerHtml = 'loading...';
  Gapi gapi = await loadGapi().then((_) {
    loadGapiResult.innerHtml = 'Gapi loaded';
  }, onError: (e, st) {
    loadGapiResult.innerHtml = 'load failed $e';
    throw e;
  });
  gapiAuth = await loadGapiAuth(gapi);
  authMain();
}

void main() {
  Element loadGapiForm = querySelector('form.app-gapi');
  Element loadGapiButton = loadGapiForm.querySelector('button.app-load');
  loadGapiResult = loadGapiForm.querySelector('.app-result');
  CheckboxInputElement autoLoadCheckbox =
      loadGapiForm.querySelector('.app-autoload');

  bool autoload = storageGet(gapiAutoLoadKey) == true.toString();

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
