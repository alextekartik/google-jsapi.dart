import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

Future main() async {
  var shell = Shell();

  stdout.writeln('http://localhost:8081/gapi_auth2_example.html');
  stdout.writeln('http://localhost:8081/google_jsapi_example.html');
  await shell.run('''
  
  dart pub global run webdev serve example:8081 --auto=refresh --hostname 0.0.0.0
  
  ''');
}
