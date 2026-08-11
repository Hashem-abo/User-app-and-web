// =============================================================================
// PRODUCTION CRASH TEST SUITE - ALL SUITES RUNNER
// =============================================================================
//
// This file imports and runs every test in the real_crash_tests/ directory.
// Run with:  flutter test test/unit/all_production_crash_tests.dart
//
// WHAT THESE TESTS DO:
//   - Each "CRASH" labeled test calls current BUGGY code and expects it to throw.
//   - Each "BUG" labeled test calls current code and asserts the wrong behavior.
//   - Each "OK" labeled test verifies the happy path still works.
//   - Each "EDGE" test verifies boundary conditions.
//
// INTERPRETING RESULTS:
//   - CRASH/BUG tests PASS → bug is confirmed, code needs fixing.
//   - CRASH/BUG tests FAIL → bug was already fixed somewhere.
//   - OK/EDGE tests PASS → happy path is intact.
//   - OK/EDGE tests FAIL → regression introduced.
//
// =============================================================================

import 'real_crash_tests/order_model_null_crash_test.dart' as order_tests;
import 'real_crash_tests/address_model_null_string_test.dart' as address_tests;
import 'real_crash_tests/cart_model_crash_test.dart' as cart_tests;
import 'real_crash_tests/date_converter_crash_test.dart' as date_tests;
import 'real_crash_tests/responsive_helper_and_item_crash_test.dart' as responsive_tests;
import 'real_crash_tests/price_converter_crash_test.dart' as price_tests;

void main() {
  order_tests.main();
  address_tests.main();
  cart_tests.main();
  date_tests.main();
  responsive_tests.main();
  price_tests.main();
}
