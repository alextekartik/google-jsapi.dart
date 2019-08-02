library all_test_browser;

//import 'package:unittest/html_config.dart';
//import 'package:test/test.dart';
import 'auth_test_.dart' as auth_test;
import 'gapi_test.dart' as gapi_test;

void main() {
  gapi_test.main();
  auth_test.main();
}
