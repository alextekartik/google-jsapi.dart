library google_jsapi_example;

import 'dart:html';
import 'package:tekartik_google_jsapi/gapi_auth2.dart';

GapiAuth2 gapiAuth2;

Storage storage = window.localStorage;

String storageKeyPref = 'com.tekartik.gapi_auth2_example';
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
String authApprovalPromptKey = 'auth_approval_prompt'; // boolean
String clientIdKey = 'client_id';
String scopesKey = 'scopes';

class App {
  void loginMain() {
    Element signInForm = querySelector('div.app-sign');
    signInForm.classes.remove('hidden');
    Element signResult = signInForm.querySelector('.app-sign-result');

    _insertLine(String line) {
      StringBuffer sb = new StringBuffer();
      sb.writeln(line);
      sb.write(signResult.text);
      signResult.text = sb.toString();
    }
    _signIn() async {
      await gapiAuth2.getAuthInstance().signIn();
      _insertLine("Signed in");
      _showAuthInfo();
    }

    signInForm.querySelector('button.app-signin').onClick.listen((Event event) {
      event.preventDefault();
      _signIn();
    });
    signInForm
        .querySelector('button.app-signin-select')
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      await gapiAuth2
          .getAuthInstance()
          .signIn(new GapiAuth2SignInParams()..prompt = "select_account");
      _insertLine("Signed in");
      _showAuthInfo();
    });

    signInForm
        .querySelector('button.app-signout')
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      await gapiAuth2.getAuthInstance().signOut();
      _insertLine("Signed out");
      _showAuthInfo();
    });

    signInForm
        .querySelector('button.app-disconnect')
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      gapiAuth2.getAuthInstance().disconnect();
      _insertLine("Disconnected");
      _showAuthInfo();
    });

    signInForm
    .querySelector('button.app-user-disconnect')
    .onClick
    .listen((Event event) async {
      event.preventDefault();
      GoogleUser user = gapiAuth2.getAuthInstance().getCurrentUser();
      if (user != null) {
        user.disconnect();
      }
      await gapiAuth2.getAuthInstance().signOut();
      _insertLine("User disconnected");
      _showAuthInfo();
    });
  }

  Element authorizeResult;

  _showAuthInfo() {
    StringBuffer sb = new StringBuffer();
    GoogleAuth auth = gapiAuth2.getAuthInstance();
    sb.writeln("auth.isSignedIn: ${auth.getIsSignedIn()}");
    GoogleUser user = auth.getCurrentUser();
    sb.writeln("user: ${user}");

    if (user.isSignedIn) {
      sb.writeln("email: ${user.basicProfile.email}");
    }

    authorizeResult.text = sb.toString();
  }

  void authMain() {
    Element authForm = querySelector('form.app-auth');
    authForm.classes.remove('hidden');
    Element authorizeButton = authForm.querySelector('button.app-authorize');
    InputElement clientIdInput =
        authForm.querySelector('input#appInputClientId');
    InputElement scopesInput = authForm.querySelector('input#appInputScopes');
    authorizeResult = authForm.querySelector('.app-result');
    CheckboxInputElement autoSignInCheckbox =
        authForm.querySelector('.app-autosignin');

    String clientId = storageGet(clientIdKey);
    if (clientId == null) {
      clientId = '124267391961.apps.googleusercontent.com';
    }
    clientIdInput.value = clientId;
    scopesInput.value = storageGet(scopesKey);

    /*
  String approvalPrompt = storageGet(authApprovalPromptKey);

  approvalPromptCheckbox.checked =
      (approvalPrompt == GapiAuth.APPROVAL_PROMPT_FORCE);
  */

    bool autoInit = storageGet(gapiAutoSignInKey) == true.toString();
    autoSignInCheckbox.checked = autoInit;

    _init() {
      clientId = clientIdInput.value;
      if (clientId.length < 1) {
        authorizeResult.innerHtml = 'Missing CLIENT ID';
        return;
      }
      storageSet(clientIdKey, clientId);

      String scopesString = scopesInput.value;
      storageSet(scopesKey, scopesString);
      List<String> scopes = scopesString.split(',');

      GapiAuth2InitParams params = new GapiAuth2InitParams()
        ..clientId = clientId
        ..scopes = scopes;
      GoogleAuth auth = gapiAuth2.init(params);
      assert(
          auth.getIsSignedIn() == gapiAuth2.getAuthInstance().getIsSignedIn());

      _showAuthInfo();
      app.loginMain();
    }

    authorizeButton.onClick.listen((Event event) {
      event.preventDefault();
      _init();
    });

    /*
    approvalPromptCheckbox.onChange.listen((_) {
      approvalPrompt = approvalPromptCheckbox.checked
          ? GapiAuth.APPROVAL_PROMPT_FORCE
          : null;
      storageSet(authApprovalPromptKey, approvalPrompt);
    });

    autoSignInCheckbox.onChange.listen((_) {
      storageSet(
          gapiAutoSignInKey, (autoSignInCheckbox.checked == true).toString());
    });
  */
    if (autoInit) {
      _init();
    }
  }

  Element loadGapiResult;

  main() async {
    Element loadGapiElement = querySelector('.app-gapi');
    loadGapiResult = loadGapiElement.querySelector('.app-result');
    loadGapiResult.innerHtml = 'loading GapiAuth2...';
    try {
      gapiAuth2 = await loadGapiAuth2();
      loadGapiResult.innerHtml = 'GapiAuth2 loaded';
    } catch (e) {
      loadGapiResult.innerHtml = 'load failed $e';
      rethrow;
    }

    authMain();
  }
}

App app = new App();

main() {
  app.main();
}
