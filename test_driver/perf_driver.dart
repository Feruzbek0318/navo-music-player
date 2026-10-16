import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    await writeResponseData(data, testOutputFilename: 'scroll_perf');
  },
);
