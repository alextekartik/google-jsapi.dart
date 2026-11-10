// ignore_for_file: deprecated_member_use_from_same_package

library;

import 'package:tekartik_browser_utils/storage_utils.dart';
import 'package:tekartik_google_jsapi/gapi.dart';
import 'package:tekartik_google_jsapi/gapi_auth.dart';
import 'package:web/web.dart' as web;

import 'test_setup.dart';

Gapi? gapi;
late GapiAuth gapiAuth;

String storageKeyPref = 'com.tekartik.google_jsapi_example';
String _storageKey(String key) => '$storageKeyPref.$key';
String? storageGet(String key) => webLocalStorageGet(_storageKey(key));

void storageSet(String key, String? value) {
  if (value == null) {
    webLocalStorageRemove(_storageKey(key));
  } else {
    webLocalStorageSet(_storageKey(key), value);
  }
}

String gapiAutoLoadKey = 'gapi_autoload'; // boolean
String gapiAutoSignInKey = 'gapi_autosignin'; // boolean
String gapiAutoSignInUserKey = 'gapi_autosignin_user'; // boolean
String authApprovalPromptKey = 'auth_approval_prompt'; // boolean
String clientIdKey = 'client_id';
String scopesKey = 'scopes';

Future<void> authMain() async {
  final authForm = web.document.querySelector('form.app-auth')!;
  authForm.classList.remove('hidden');
  final authorizeButton = authForm.querySelector('button.app-authorize')!;
  var clientIdInput =
      authForm.querySelector('input#appInputClientId') as web.HTMLInputElement;
  final scopesInput =
      authForm.querySelector('input#appInputScopes') as web.HTMLInputElement;
  final authorizeResult = authForm.querySelector('.app-result');
  final autoSignInCheckbox =
      authForm.querySelector('.app-autosignin') as web.HTMLInputElement;
  final approvalPromptCheckbox =
      authForm.querySelector('.app-approval-prompt') as web.HTMLInputElement;

  var appOptions = await setup();
  clientIdInput.value = storageGet(clientIdKey) ?? appOptions?.clientId ?? '';
  scopesInput.value = storageGet(scopesKey) ?? '';

  var approvalPrompt = storageGet(authApprovalPromptKey);

  approvalPromptCheckbox.checked =
      (approvalPrompt == GapiAuth.approvalPromptForce);

  final autoSignIn = storageGet(gapiAutoSignInKey) == true.toString();
  autoSignInCheckbox.checked = autoSignIn;

  void signIn() {
    final clientId = clientIdInput.value;
    if (clientId.isEmpty) {
      authorizeResult!.textContent = 'Missing CLIENT ID';
      return;
    }
    storageSet(clientIdKey, clientId);

    final scopesString = scopesInput.value;
    storageSet(scopesKey, scopesString);
    final scopes = scopesString.split(',');

    gapiAuth.authorize(clientId, scopes, approvalPrompt: approvalPrompt).then((
      String oauthToken,
    ) {
      authorizeResult!.textContent =
          "client id '$clientId' authorized for '$scopes'";
    });
  }

  authorizeButton.onClick.listen((web.Event event) {
    event.preventDefault();
    signIn();
  });

  approvalPromptCheckbox.onChange.listen((_) {
    approvalPrompt = approvalPromptCheckbox.checked
        ? GapiAuth.approvalPromptForce
        : null;
    storageSet(authApprovalPromptKey, approvalPrompt);
  });

  autoSignInCheckbox.onChange.listen((_) {
    storageSet(gapiAutoSignInKey, autoSignInCheckbox.checked.toString());
  });

  if (autoSignIn) {
    signIn();
  }
}

web.Element? loadGapiResult;

Future _loadGapi() async {
  loadGapiResult!.textContent = 'loading...';
  final gapi = await loadGapi().then(
    (gapi) {
      loadGapiResult!.textContent = 'Gapi loaded';
      return gapi;
    },
    onError: (Object e, st) {
      loadGapiResult!.textContent = 'load failed $e';
      // ignore: only_throw_errors
      throw e;
    },
  );
  gapiAuth = await loadGapiAuth(gapi);
  await authMain();
}

void main() {
  final loadGapiForm = web.document.querySelector('form.app-gapi')!;
  final loadGapiButton = loadGapiForm.querySelector('button.app-load')!;
  loadGapiResult = loadGapiForm.querySelector('.app-result');
  final autoLoadCheckbox =
      loadGapiForm.querySelector('.app-autoload') as web.HTMLInputElement;

  final autoload = storageGet(gapiAutoLoadKey) == true.toString();

  autoLoadCheckbox.checked = autoload;

  loadGapiButton.onClick.listen((web.Event event) {
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
