import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// integration_test が撮った画面を screenshots/ に書き出すためのドライバ。
/// flutter drive --driver=test_driver/integration_test.dart --target=...
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('screenshots/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
