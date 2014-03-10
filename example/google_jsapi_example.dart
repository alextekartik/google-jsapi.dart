library google_jsapi_example;

import 'dart:html';
import 'package:tekartik_google_jsapi/google_jsapi.dart';

Gapi gapi;
Storage storage = window.localStorage;

String _STORAGE_KEY_PREF = 'com.tekartik.google_jsapi_example';
dynamic storageGet(String key) {
  return storage['$_STORAGE_KEY_PREF.$key'];
}
void storageSet(String key, String value) {
  if (value == null) {
    storage.remove(key);
  } else {
    storage['$_STORAGE_KEY_PREF.$key'] = value;
  }
}

String GAPI_AUTOLOAD = 'gapi_autoload'; // boolean
String AUTH_APPROVIAL_PROMPT = 'auth_approval_prompt'; // boolean
String CLIEND_ID_KEY = 'client_id';
String SCOPES_KEY = 'scopes';

void authMain() {
  Element authForm = querySelector('form.app-auth');
  authForm.classes.remove('hidden');
  Element authorizeButton = authForm.querySelector('button.app-authorize');
  InputElement clientIdInput = authForm.querySelector('input#appInputClientId');
  InputElement scopesInput = authForm.querySelector('input#appInputScopes');
  Element authorizeResult = authForm.querySelector('.app-result');
  CheckboxInputElement approvalPromptCheckbox = authForm.querySelector(
      '.app-approval-prompt');

  clientIdInput.value = storageGet(CLIEND_ID_KEY);
  scopesInput.value = storageGet(SCOPES_KEY);

  String approvalPrompt = storageGet(AUTH_APPROVIAL_PROMPT);

  approvalPromptCheckbox.checked = (approvalPrompt ==
      GapiAuth.APPROVAL_PROMPT_FORCE);

  authorizeButton.onClick.listen((Event event) {
    event.preventDefault();
    String clientId = clientIdInput.value;
    if (clientId.length < 1) {
      authorizeResult.innerHtml = 'Missing CLIENT ID';
      return;
    }
    storageSet(CLIEND_ID_KEY, clientId);

    String scopesString = scopesInput.value;
    storageSet(SCOPES_KEY, scopesString);
    List<String> scopes = scopesString.split(',');

    gapi.auth.authorize(clientId, scopes, approvalPrompt: approvalPrompt).then(
        (String oauthToken) {
      authorizeResult.innerHtml =
          "client id '$clientId' authorized for '$scopes'";
    });
  });

  approvalPromptCheckbox.onChange.listen((_) {
    approvalPrompt = approvalPromptCheckbox.checked ?
        GapiAuth.APPROVAL_PROMPT_FORCE : null;
    storageSet(AUTH_APPROVIAL_PROMPT, approvalPrompt);
  });
}

Element loadGapiResult;

void _loadGapi() {
  loadGapiResult.innerHtml = 'loading...';
  loadGapi().then((Gapi gapi_) {
    gapi = gapi_;
    loadGapiResult.innerHtml = 'Gapi loaded';
    authMain();
  }, onError: (e, st) {
    loadGapiResult.innerHtml = 'load failed $e';
  });
}

void main() {
  Element loadGapiForm = querySelector('form.app-gapi');
  Element loadGapiButton = loadGapiForm.querySelector('button.app-load');
  loadGapiResult = loadGapiForm.querySelector('.app-result');
  CheckboxInputElement autoLoadCheckbox = loadGapiForm.querySelector(
      '.app-autoload');

  bool autoload = storageGet(GAPI_AUTOLOAD) == true.toString();

  autoLoadCheckbox.checked = autoload;
  if (autoload) {
    _loadGapi();
  }

  loadGapiButton.onClick.listen((Event event) {
    event.preventDefault();
    _loadGapi();
  });

  autoLoadCheckbox.onChange.listen((_) {
    storageSet(GAPI_AUTOLOAD, autoLoadCheckbox.checked.toString());
  });

  if (autoload) {
    _loadGapi();
  }
}
