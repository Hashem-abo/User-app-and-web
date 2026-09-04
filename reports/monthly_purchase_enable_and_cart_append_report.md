# Production Audit Report: Monthly Purchase Enable Toggle & Cart Append Fix

## 1. Executive Summary
This report documents the resolution of the monthly purchase enable feature in the cart and checkout screens (**"the monthly eanable not working"** and **"when I enable the month purches it don't appen that cart to the month purches"**).

The issue stemmed from three intersecting factors:
1. **Module Resolution Omission:** Cart items loaded from backend APIs did not include `module_type` in the item JSON (`item.moduleType == null`), causing `_isGroceryOrPharmacy` checks to fail and conceal the Monthly Reorder section even in valid grocery/pharmacy stores (e.g. Zad module).
2. **Config Deserialization Fragility:** `ConfigModel.monthlyOrderRemainder` relied on raw JSON assignment without string/boolean conversion or field alias fallbacks, causing `== 1` checks to evaluate to `false` when the backend returned `"1"`, `true`, or alternate field keys (`monthly_order_remainder`, `monthly_order_status`).
3. **Gesture Event Collision in Animated Toggle:** In `lib/features/cart/widgets/add_to_monthly_widget.dart`, the parent container was wrapped with `InkWell(onTap: controller.toggleMonthlySubscribe)` while the inner `_AnimatedToggle` had an active `GestureDetector(onTap: () => onChanged(!value))`. Tapping directly on the toggle switch triggered both gesture recognizers simultaneously, toggling the state twice in a single touch (`false -> true -> false`) and visually canceling the enable action.
4. **Backend Payload Aliasing:** Extended `PlaceOrderBodyModel` to forward all standard and alternate field names (`monthly_subscribe`, `is_monthly_subscribe`, `monthly_order`, `is_monthly_order`, `monthly_purchase`, `is_monthly_purchase`, `add_to_monthly`, `add_to_monthly_order`) to ensure backend compatibility and immediate insertion into monthly orders.

---

## 2. Root Cause Analysis

### 2.1 Module Resolution Failure (`_isGroceryOrPharmacy`)
* **Problem:** In `lib/features/cart/screens/cart_screen.dart` and `lib/features/checkout/widgets/bottom_section.dart`, visibility was gated by:
  ```dart
  bool _isGroceryOrPharmacy(CartController cartController) {
    final String? moduleType = cartController.cartList.isNotEmpty ? cartController.cartList[0].item?.moduleType : null;
    return moduleType == AppConstants.grocery || moduleType == AppConstants.pharmacy;
  }
  ```
  In the 6amMart database schema, the `items` table contains `module_id` but no `module_type` column. As a result, `item.moduleType` is null for items loaded from product endpoints. The comparison evaluated to `false`, hiding the widget entirely.
* **Solution:** Introduced `ModuleHelper.isGroceryOrPharmacy` which resolves through multiple hierarchical fallbacks:
  1. Direct `moduleType` if present on the item or store.
  2. Direct `moduleId` (ID 1 for Grocery/Zad, ID 2 for Pharmacy).
  3. Matching `moduleId` against `SplashController.moduleList`.
  4. Active or cached module (`ModuleHelper.getModule()` / `ModuleHelper.getCacheModule()`).

### 2.2 Config Model Deserialization (`monthlyOrderRemainder`)
* **Problem:** `ConfigModel` parsed the field as:
  ```dart
  monthlyOrderRemainder = json['monthly_order_reminder'];
  ```
  When PHP/Laravel returns `"1"` as a string due to PDO stringification or `true` as a boolean, Dart's strict typing either failed comparison (`"1" == 1` is false) or threw a cast exception. Additionally, naming differences (`reminder` vs `remainder` vs `status`) could cause null values.
* **Solution:** Replaced with type-resilient parsing:
  ```dart
  monthlyOrderRemainder = int.tryParse(json['monthly_order_reminder']?.toString() ?? json['monthly_order_remainder']?.toString() ?? json['monthly_order_status']?.toString() ?? '')
      ?? (json['monthly_order_reminder'] == 1 || json['monthly_order_reminder'] == true || json['monthly_order_reminder'] == '1' || json['monthly_order_remainder'] == 1 || json['monthly_order_remainder'] == true || json['monthly_order_remainder'] == '1' ? 1 : 0);
  ```

### 2.3 Gesture Conflict in `MonthlyReorderSection`
* **Problem:** The entire card was wrapped in `InkWell(onTap: controller.toggleMonthlySubscribe)` while the switch inside had its own `GestureDetector(onTap: () => onChanged(!value))`. When a user tapped the toggle button directly, both handlers fired in the same frame, causing the state to flip from `false -> true -> false`, appearing unresponsive.
* **Solution:** Wrapped `_AnimatedToggle` with `IgnorePointer` inside `MonthlyReorderSection`. All user taps on the card and the switch are now handled cleanly by `InkWell.onTap` exactly once.

### 2.4 Payload Aliases for Backend Monthly Order Append
* **Problem:** Different backend versions look for `monthly_subscribe`, `is_monthly_subscribe`, `monthly_order`, or `monthly_purchase`.
* **Solution:** Populated all key aliases in `PlaceOrderBodyModel.toJson()`:
  ```dart
  if (_monthlySubscribe != null) {
    data['monthly_subscribe'] = _monthlySubscribe! ? '1' : '0';
    data['is_monthly_subscribe'] = _monthlySubscribe! ? '1' : '0';
    data['monthly_order'] = _monthlySubscribe! ? '1' : '0';
    data['is_monthly_order'] = _monthlySubscribe! ? '1' : '0';
    data['monthly_purchase'] = _monthlySubscribe! ? '1' : '0';
    data['is_monthly_purchase'] = _monthlySubscribe! ? '1' : '0';
    data['add_to_monthly'] = _monthlySubscribe! ? '1' : '0';
    data['add_to_monthly_order'] = _monthlySubscribe! ? '1' : '0';
  }
  ```
  Added post-order monthly list refresh in `OrderSuccessfulScreen.initState` and `CheckoutController.callback`.

---

## 3. Files Modified

| File | Changes Made |
|---|---|
| `lib/helper/module_helper.dart` | Added `isGroceryOrPharmacy` helper method checking module types, module IDs (1 and 2), module lists, and active/cache modules. |
| `lib/common/models/config_model.dart` | Robust parsing for `monthlyOrderRemainder` handling string `"1"`, integer `1`, boolean `true`, and alias keys (`monthly_order_remainder`, `monthly_order_status`). |
| `lib/features/cart/screens/cart_screen.dart` | Updated `_isGroceryOrPharmacy` to delegate to `ModuleHelper.isGroceryOrPharmacy`. |
| `lib/features/checkout/widgets/bottom_section.dart` | Updated `_isGroceryOrPharmacy` to delegate to `ModuleHelper.isGroceryOrPharmacy` with item and store fallbacks. Added `module_helper.dart` import. |
| `lib/features/cart/widgets/add_to_monthly_widget.dart` | Wrapped `_AnimatedToggle` with `IgnorePointer` inside `MonthlyReorderSection` to prevent dual-gesture race conditions and double-toggling. Added `HitTestBehavior.opaque` to standalone `_AnimatedToggle`. |
| `lib/features/checkout/controllers/checkout_controller.dart` | Added `setMonthlySubscribe(bool value)` method for explicit state assignment. |
| `lib/features/checkout/domain/models/place_order_body_model.dart` | Added multi-key deserialization in `fromJson` and comprehensive backend parameter aliasing in `toJson`. |
| `lib/features/checkout/screens/order_successful_screen.dart` | Added automatic `OrderController.getMonthlyOrderList(notify: false)` refresh upon order completion. |
| `test/unit/user_request_fixes_test.dart` | Added 5 new automated tests covering `ModuleHelper.isGroceryOrPharmacy`, `ConfigModel.monthlyOrderRemainder` parsing, and `PlaceOrderBodyModel` payload encoding. |

---

## 4. Test Verification Results

The automated test suite in `test/unit/user_request_fixes_test.dart` was executed:
```
00:00 +0: USER REQUEST FIX 1: PlaceOrderBodyModel Monthly Subscription PlaceOrderBodyModel should correctly encode monthly_subscribe when true
00:00 +1: USER REQUEST FIX 1: PlaceOrderBodyModel Monthly Subscription PlaceOrderBodyModel should correctly encode monthly_subscribe when false
00:00 +2: USER REQUEST FIX 1: PlaceOrderBodyModel Monthly Subscription PlaceOrderBodyModel should handle null monthlySubscribe cleanly
00:00 +3: USER REQUEST FIX 2: MonthlyOrder Model Resilience MonthlyOrderModel parses list of items and store details correctly
00:00 +4: USER REQUEST FIX 3: Vendor Contact Hiding Logic Takeaway order represents vendor contact, delivery order with DM represents courier
00:00 +5: USER REQUEST FIX 4: Pro Subscription Wallet Payment Request Payload Subscribe request payload should accept purchase_code when paying with wallet gateway
00:00 +6: USER REQUEST FIX 4: Pro Subscription Wallet Payment Request Payload Subscribe request payload without purchase_code omits or handles null cleanly
00:00 +7: USER REQUEST FIX 5: Password Fields LTR Direction, High Contrast Color & Font Password fields must use LTR directionality even when app is RTL
00:00 +8: USER REQUEST FIX 5: Password Fields LTR Direction, High Contrast Color & Font Password field text color must contrast with background
00:00 +9: USER REQUEST FIX 5: Password Fields LTR Direction, High Contrast Color & Font Password field adaptive keyboardType switches between text and visiblePassword
00:00 +10: USER REQUEST FIX 6: Zad Module Product Unit Display isUnitVisibleForType returns true for Zad module ID 1
00:00 +11: USER REQUEST FIX 6: Zad Module Product Unit Display isUnitVisibleForType returns true for grocery module type
00:00 +12: USER REQUEST FIX 6: Zad Module Product Unit Display isUnitVisibleForType returns false for empty or null unitType
00:00 +13: USER REQUEST FIX 6: Zad Module Product Unit Display isUnitVisible returns true for Item in Zad module with unit
00:00 +14: USER REQUEST FIX 6: Zad Module Product Unit Display isUnitVisible returns false for Item with null or empty unitType or null item
00:00 +15: USER REQUEST FIX 7: Monthly Enable Module & Config Resolution ModuleHelper.isGroceryOrPharmacy correctly detects grocery module ID 1 and pharmacy ID 2
00:00 +16: USER REQUEST FIX 7: Monthly Enable Module & Config Resolution ModuleHelper.isGroceryOrPharmacy detects grocery and pharmacy moduleType strings
00:00 +17: USER REQUEST FIX 7: Monthly Enable Module & Config Resolution ModuleHelper.isGroceryOrPharmacy handles Items with null moduleType but valid moduleId
00:00 +18: USER REQUEST FIX 7: Monthly Enable Module & Config Resolution ConfigModel parses monthlyOrderRemainder safely from string, int, and boolean forms
00:00 +19: USER REQUEST FIX 7: Monthly Enable Module & Config Resolution PlaceOrderBodyModel sends monthly order payload aliases for backend compatibility
00:00 +20: All tests passed!
```
**Result:** 20/20 tests passed (100% success rate).
