import 'package:flutter_test/flutter_test.dart';

import 'package:diagnosticable/diagnosticable.dart';

final logger = Diagnosticable(
  debugLevel: DebugLevel.debug,
);
void main() {
  test('prints', () {
    logger.printStart();
    logger.printDebug('debug');
    logger.printWarning('warning');
    logger.printError('error');
    logger.printInfo('info');
  });
}
