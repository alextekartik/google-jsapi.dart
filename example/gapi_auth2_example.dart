// ignore_for_file: deprecated_member_use_from_same_package

library;

import 'package:tekartik_browser_utils/storage_utils.dart';
import 'package:tekartik_google_jsapi/gapi_auth2.dart';
import 'package:web/web.dart' as web;

import 'test_setup.dart';

late GapiAuth2 gapiAuth2;

String storageKeyPref = 'com.tekartik.gapi_auth2_example';
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
String gapiAutoInitKey = 'gapi_autoinit'; // boolean
String gapiAutoSignInKey = 'gapi_autosignin'; // boolean
String authApprovalPromptKey = 'auth_approval_prompt'; // boolean
String clientIdKey = 'client_id';
String userIdKey = 'user_id';
String scopesKey = 'scopes';

class App {
  void loginMain() {
    final signInForm = web.document.querySelector('div.app-sign')!;
    signInForm.classList.remove('hidden');
    final signResult = signInForm.querySelector('.app-sign-result')!;

    var autoSignInCheckbox =
        signInForm.querySelector('.app-autosignin') as web.HTMLInputElement;

    final autoSignIn = storageGet(gapiAutoSignInKey) == true.toString();
    autoSignInCheckbox.checked = autoSignIn;

    void insertLine(String line) {
      final sb = StringBuffer();
      sb.writeln(line);
      sb.write(signResult.textContent);
      signResult.textContent = sb.toString();
    }

    Future signIn() async {
      await gapiAuth2.getAuthInstance().signIn();
      insertLine('Signed in');
      _showAuthInfo();
    }

    if (autoSignIn) {
      signIn();
    }
    signInForm.querySelector('button.app-signin')!.onClick.listen((
      web.Event event,
    ) {
      event.preventDefault();
      signIn();
    });
    signInForm.querySelector('button.app-signin-select')!.onClick.listen((
      web.Event event,
    ) async {
      event.preventDefault();
      await gapiAuth2.getAuthInstance().signIn(
        GapiAuth2SignInParams()..prompt = 'select_account',
      );
      insertLine('Signed in');
      _showAuthInfo();
    });

    signInForm.querySelector('button.app-signout')!.onClick.listen((
      web.Event event,
    ) async {
      event.preventDefault();
      await gapiAuth2.getAuthInstance().signOut();
      insertLine('Signed out');
      _showAuthInfo();
    });

    signInForm.querySelector('button.app-disconnect')!.onClick.listen((
      web.Event event,
    ) async {
      event.preventDefault();
      gapiAuth2.getAuthInstance().disconnect();
      insertLine('Disconnected');
      _showAuthInfo();
    });

    signInForm.querySelector('button.app-user-disconnect')!.onClick.listen((
      web.Event event,
    ) async {
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
      storageSet(gapiAutoSignInKey, (autoSignInCheckbox.checked).toString());
    });
  }

  late web.Element authorizeResult;

  void _showAuthInfo() {
    final sb = StringBuffer();
    final auth = gapiAuth2.getAuthInstance();
    sb.writeln('auth.isSignedIn: ${auth.getIsSignedIn()}');
    final user = auth.getCurrentUser()!;
    sb.writeln('user: $user');

    if (user.isSignedIn!) {
      sb.writeln('email: ${user.basicProfile.email}');
    }

    authorizeResult.textContent = sb.toString();
  }

  Future<void> authMain() async {
    var defaultOptions = await setup();
    final authForm = web.document.querySelector('form.app-auth')!;
    authForm.classList.remove('hidden');
    final authorizeButton = authForm.querySelector('button.app-authorize')!;
    final clientIdInput =
        authForm.querySelector('input#appInputClientId')
            as web.HTMLInputElement;
    final userIdInput =
        authForm.querySelector('input#appUserId') as web.HTMLInputElement;
    final scopesInput =
        authForm.querySelector('input#appInputScopes') as web.HTMLInputElement;
    authorizeResult = authForm.querySelector('.app-result')!;
    final autoInitCheckbox =
        authForm.querySelector('.app-autoinit') as web.HTMLInputElement;

    var clientId = storageGet(clientIdKey) ?? defaultOptions?.clientId;

    var userId = storageGet(userIdKey);
    clientIdInput.value = clientId ?? '';
    userIdInput.value = userId ?? '';
    scopesInput.value = storageGet(scopesKey) ?? '';

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
        authorizeResult.textContent = 'Missing CLIENT ID';
        return;
      }
      storageSet(clientIdKey, clientId);

      final scopesString = scopesInput.value;
      storageSet(scopesKey, scopesString);
      final scopes = scopesString.split(',');

      final params = GapiAuth2InitParams()
        ..clientId = clientId
        ..scopes = scopes;
      print('gapi.auth2.init($params');
      final auth = gapiAuth2.init(params);
      print('auth: $auth');
      assert(
        auth.getIsSignedIn() == gapiAuth2.getAuthInstance().getIsSignedIn(),
      );

      _showAuthInfo();
      auth.onSignedIn.listen((val) {
        print('onSignedIn: $val');
      });

      app.loginMain();
    }

    authorizeButton.onClick.listen((web.Event event) {
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
      storageSet(gapiAutoInitKey, (autoInitCheckbox.checked).toString());
    });

    if (autoInit) {
      init();
    }
  }

  web.Element? loadGapiResult;

  Future main() async {
    final loadGapiElement = web.document.querySelector('.app-gapi')!;
    loadGapiResult = loadGapiElement.querySelector('.app-result');
    loadGapiResult!.textContent = 'loading GapiAuth2...';
    try {
      gapiAuth2 = await loadGapiAuth2();
      loadGapiResult!.textContent = 'GapiAuth2 loaded';
    } catch (e) {
      loadGapiResult!.textContent = 'load failed $e';
      rethrow;
    }

    await authMain();
  }
}

App app = App();

void main() {
  app.main();
}
