import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/version_helper.dart';

void main() {
  group('VersionHelper Semantic Versioning Tests', () {
    test('Correctly compares identical versions', () {
      expect(VersionHelper.compare('1.0.0', '1.0.0'), 0);
      expect(VersionHelper.compare('3.5', '3.5.0'), 0);
      expect(VersionHelper.compare('2.1.0+10', '2.1.0+20'), 0);
    });

    test('Correctly identifies higher versions across multi-digit patch / minor', () {
      // 1.10.0 must be GREATER than 1.2.0 (which fails with double parsing)
      expect(VersionHelper.compare('1.10.0', '1.2.0'), 1);
      expect(VersionHelper.isVersionLower('1.2.0', '1.10.0'), true);
      expect(VersionHelper.isVersionLower('1.10.0', '1.2.0'), false);

      // 3.5.1 must be GREATER than 3.5
      expect(VersionHelper.isVersionLower('3.5', '3.5.1'), true);
      expect(VersionHelper.isVersionLower('3.5.1', '3.5'), false);

      // 4.0.0 must be GREATER than 3.99.99
      expect(VersionHelper.compare('4.0.0', '3.99.99'), 1);
      expect(VersionHelper.isVersionLower('3.99.99', '4.0.0'), true);
    });

    test('Handles numbers and doubles gracefully', () {
      expect(VersionHelper.compare(3.5, '3.5.0'), 0);
      expect(VersionHelper.isVersionLower(3.5, 3.6), true);
      expect(VersionHelper.isVersionLower(3.6, 3.5), false);
    });

    test('Handles null and empty values safely', () {
      expect(VersionHelper.isVersionLower('1.0.0', null), false);
      expect(VersionHelper.isVersionGreaterOrEqual('1.0.0', null), true);
    });
  });
}
