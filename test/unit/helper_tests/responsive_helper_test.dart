import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

void main() {
  group('ResponsiveHelper - Core Logic', () {
    test('isWeb returns false in standard VM unit test environment', () {
      expect(ResponsiveHelper.isWeb(), isFalse);
    });

    test('isMobilePhone returns true when not web', () {
      expect(ResponsiveHelper.isMobilePhone(), isTrue);
    });
  });

  group('ResponsiveHelper - Null Context Safety (Fixed)', () {
    test('isMobile handles null context safely', () {
      expect(() => ResponsiveHelper.isMobile(null), returnsNormally);
      expect(ResponsiveHelper.isMobile(null), isTrue);
    });

    test('isTab handles null context safely', () {
      expect(() => ResponsiveHelper.isTab(null), returnsNormally);
      expect(ResponsiveHelper.isTab(null), isFalse);
    });

    test('isDesktop handles null context safely', () {
      expect(() => ResponsiveHelper.isDesktop(null), returnsNormally);
      expect(ResponsiveHelper.isDesktop(null), isFalse);
    });
  });
}
