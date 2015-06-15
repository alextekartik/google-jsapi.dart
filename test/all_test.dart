@TestOn("browser")
library all_test;

import 'package:test/test.dart';
import 'gapi_test.dart' as gapi_test;
import 'auth_test.dart' as auth_test;

main() {
  gapi_test.main();
  auth_test.main();
}