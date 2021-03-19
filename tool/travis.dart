import 'package:dev_test/package.dart';
import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await packageRunCi('.', noTest: true);
  await shell.run('''
  dart pub run test -p chrome -j 1
  ''');
}
