import 'dart:async';

import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  print('http://localhost:8081/gapi_auth2_example.html');
  await shell.run('''
  
  dart pub global run webdev serve example:8081 --auto=refresh --hostname 0.0.0.0
  
  ''');
}
