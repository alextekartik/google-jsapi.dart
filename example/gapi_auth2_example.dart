library google_jsapi_example;

import 'dart:html';
import 'package:tekartik_google_jsapi/gapi_auth2.dart';

late GapiAuth2 gapiAuth2;

Storage storage = window.localStorage;

String storageKeyPref = 'com.tekartik.gapi_auth2_example';
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
String gapiAutoInitKey = 'gapi_autoinit'; // boolean
String gapiAutoSignInKey = 'gapi_autosignin'; // boolean
String authApprovalPromptKey = 'auth_approval_prompt'; // boolean
String clientIdKey = 'client_id';
String userIdKey = 'user_id';
String scopesKey = 'scopes';

class App {
  void loginMain() {
    final signInForm = querySelector('div.app-sign')!;
    signInForm.classes.remove('hidden');
    final signResult = signInForm.querySelector('.app-sign-result');

    var autoSignInCheckbox =
        signInForm.querySelector('.app-autosignin') as CheckboxInputElement;

    final autoSignIn = storageGet(gapiAutoSignInKey) == true.toString();
    autoSignInCheckbox.checked = autoSignIn;

    void insertLine(String line) {
      final sb = StringBuffer();
      sb.writeln(line);
      sb.write(signResult!.text);
      signResult.text = sb.toString();
    }

    Future signIn() async {
      await gapiAuth2.getAuthInstance().signIn();
      insertLine('Signed in');
      _showAuthInfo();
    }

    if (autoSignIn) {
      signIn();
    }
    signInForm
        .querySelector('button.app-signin')!
        .onClick
        .listen((Event event) {
      event.preventDefault();
      signIn();
    });
    signInForm
        .querySelector('button.app-signin-select')!
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      await gapiAuth2
          .getAuthInstance()
          .signIn(GapiAuth2SignInParams()..prompt = 'select_account');
      insertLine('Signed in');
      _showAuthInfo();
    });

    signInForm
        .querySelector('button.app-signout')!
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      await gapiAuth2.getAuthInstance().signOut();
      insertLine('Signed out');
      _showAuthInfo();
    });

    signInForm
        .querySelector('button.app-disconnect')!
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      gapiAuth2.getAuthInstance().disconnect();
      insertLine('Disconnected');
      _showAuthInfo();
    });

    signInForm
        .querySelector('button.app-user-disconnect')!
        .onClick
        .listen((Event event) async {
      event.preventDefault();
      final user = gapiAuth2.getAuthInstance().getCurrentUser();
      if (user != null) {
        user.disconnect();
      }
      await gapiAuth2.getAuthInstance().signOut();
      insertLine('User disconnected');
      _showAuthInfo();
    });

    autoSignInCheckbox.onChange.listen((_) {
      storageSet(
          gapiAutoSignInKey, (autoSignInCheckbox.checked == true).toString());
    });
  }

  Element? authorizeResult;

  void _showAuthInfo() {
    final sb = StringBuffer();
    final auth = gapiAuth2.getAuthInstance();
    sb.writeln('auth.isSignedIn: ${auth.getIsSignedIn()}');
    final user = auth.getCurrentUser()!;
    sb.writeln('user: $user');

    if (user.isSignedIn!) {
      sb.writeln('email: ${user.basicProfile.email}');
    }

    authorizeResult!.text = sb.toString();
  }

  void authMain() {
    final authForm = querySelector('form.app-auth')!;
    authForm.classes.remove('hidden');
    final authorizeButton = authForm.querySelector('button.app-authorize')!;
    final clientIdInput =
        authForm.querySelector('input#appInputClientId') as InputElement;
    final userIdInput =
        authForm.querySelector('input#appUserId') as InputElement;
    final scopesInput =
        authForm.querySelector('input#appInputScopes') as InputElement;
    authorizeResult = authForm.querySelector('.app-result');
    final autoInitCheckbox =
        authForm.querySelector('.app-autoinit') as CheckboxInputElement;

    String? clientId =
        storageGet(clientIdKey) ?? '124267391961.apps.googleusercontent.com';

    var userId = storageGet(userIdKey);
    clientIdInput.value = clientId;
    userIdInput.value = userId;
    scopesInput.value = storageGet(scopesKey);

    /*
  String approvalPrompt = storageGet(authApprovalPromptKey);

  approvalPromptCheckbox.checked =
      (approvalPrompt == GapiAuth.APPROVAL_PROMPT_FORCE);
  */

    var autoInit = storageGet(gapiAutoInitKey) == true.toString();
    autoInitCheckbox.checked = autoInit;

    void init() {
      clientId = clientIdInput.value;
      if (clientId!.isEmpty) {
        authorizeResult!.innerHtml = 'Missing CLIENT ID';
        return;
      }
      storageSet(clientIdKey, clientId);

      final scopesString = scopesInput.value!;
      storageSet(scopesKey, scopesString);
      final scopes = scopesString.split(',');

      final params = GapiAuth2InitParams()
        ..clientId = clientId
        ..scopes = scopes;
      print('gapi.auth2.init($params');
      final auth = gapiAuth2.init(params);
      print('auth: $auth');
      assert(
          auth.getIsSignedIn() == gapiAuth2.getAuthInstance().getIsSignedIn());

      _showAuthInfo();
      auth.onSignedIn.listen((val) {
        print('onSignedIn: $val');
      });

      app.loginMain();
    }

    authorizeButton.onClick.listen((Event event) {
      event.preventDefault();
      init();
    });

    userIdInput.onChange.listen((_) {
      userId = userIdInput.value;
      storageSet(userIdKey, userId);
    });
    /*
    approvalPromptCheckbox.onChange.listen((_) {
      approvalPrompt = approvalPromptCheckbox.checked
          ? GapiAuth.APPROVAL_PROMPT_FORCE
          : null;
      storageSet(authApprovalPromptKey, approvalPrompt);
    });
    */
    autoInitCheckbox.onChange.listen((_) {
      storageSet(
          gapiAutoInitKey, (autoInitCheckbox.checked == true).toString());
    });

    if (autoInit) {
      init();
    }
  }

  Element? loadGapiResult;

  Future main() async {
    final loadGapiElement = querySelector('.app-gapi')!;
    loadGapiResult = loadGapiElement.querySelector('.app-result');
    loadGapiResult!.innerHtml = 'loading GapiAuth2...';
    try {
      gapiAuth2 = await loadGapiAuth2();
      loadGapiResult!.innerHtml = 'GapiAuth2 loaded';
    } catch (e) {
      loadGapiResult!.innerHtml = 'load failed $e';
      rethrow;
    }

    authMain();
  }
}

App app = App();

void main() {
  app.main();
}
