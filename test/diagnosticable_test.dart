import 'package:flutter_test/flutter_test.dart';

import 'package:diagnosticable/diagnosticable.dart';

const logger = Diagnosticable(
  debugLevel: DebugLevel.debug,
);

void main() {
  test('prints', () {
    logger.printStart();
    logger.printDebug('debug');
    logger.printInfo('info');
    logger.printWarning('warning');
    logger.printSuccess('success');
    logger.printError('error');
  });
}
