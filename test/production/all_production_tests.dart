// =============================================================================
// PRODUCTION TEST SUITE: MASTER ALL-TESTS RUNNER
// =============================================================================
//
// Imports and runs all 9 production test suites:
// 1. Business Logic & Financial Calculations
// 2. Data Parsing, Models & Null Safety
// 3. Auth, Session Lifecycle & Location
// 4. UI/UX, Layout Overflows & Resource Leaks
// 5. Helper Classes, DateConverter & Validation Bugs
// 6. Cart & Item Variation Crash Reproductions & Invariants
// 7. Store, Location & Zone Crash Reproductions & Invariants
// 8. Search, Suggestions & Filtering Crashes & Invariants
// 9. Chat, Parcel & Order Details Crashes & Invariants
//
// Run: flutter test test/production/all_production_tests.dart
// =============================================================================

import 'business_logic_production_test.dart' as business_logic;
import 'data_parsing_safety_test.dart' as data_parsing;
import 'auth_lifecycle_production_test.dart' as auth_lifecycle;
import 'ui_ux_and_resource_leaks_test.dart' as ui_ux;
import 'helpers_and_validation_bugs_test.dart' as helpers_validation;
import 'cart_and_item_variation_bugs_test.dart' as cart_variations;
import 'store_and_location_bugs_test.dart' as store_location;
import 'search_and_filter_bugs_test.dart' as search_filter;
import 'chat_and_parcel_bugs_test.dart' as chat_parcel;

void main() {
  business_logic.main();
  data_parsing.main();
  auth_lifecycle.main();
  ui_ux.main();
  helpers_validation.main();
  cart_variations.main();
  store_location.main();
  search_filter.main();
  chat_parcel.main();
}
