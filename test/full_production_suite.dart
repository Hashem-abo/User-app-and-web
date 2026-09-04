// =============================================================================
// COMPLETE SIXAM MART PRODUCTION REGRESSION & STABILITY TEST SUITE
// =============================================================================
//
// Unifies:
// 1. All Real Crash Tests (Unit & Model Deserialization, Null Conversions)
// 2. Business Logic & Financial Calculations
// 3. Data Parsing & Model Safety
// 4. Authentication, Session Lifecycle & Location Safety
// 5. UI/UX Layout Overflows & Resource Leak Guards
//
// Run with automated reporting:
//   dart run tool/test_runner.dart --suite test/full_production_suite.dart --summary
//   dart run tool/test_runner.dart --suite test/full_production_suite.dart --passed
//   dart run tool/test_runner.dart --suite test/full_production_suite.dart --errors
//   dart run tool/test_runner.dart --suite test/full_production_suite.dart --export full_audit_report.md
// =============================================================================

import 'unit/all_production_crash_tests.dart' as unit_crash_tests;
import 'production/all_production_tests.dart' as production_feature_tests;

void main() {
  unit_crash_tests.main();
  production_feature_tests.main();
}
