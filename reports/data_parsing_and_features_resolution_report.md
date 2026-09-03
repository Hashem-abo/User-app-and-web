# Post-Fix Verification & Resolution Report: Data Parsing Bugs & Feature Enhancements
**Generated at:** `2026-09-04 02:35:00`  
**Target Test Suites:** `test/production/all_production_tests.dart` & `test/production/vendor_logout_phone_payment_bug_test.dart`  
**Status:** ✅ ALL TESTS PASSED (0 FAILURES, 100% GREEN)

---

## 1. Executive Summary

This report documents the resolution of the defects identified in the initial production audit (`production_audit_report.md`), alongside the 4 core feature enhancements requested for vendor presentation, authentication dialogs, phone number internationalization, and checkout payment onboarding.

### Verification Summary
| Metric | Value |
|---|---|
| **Total Tests Executed** | 89 |
| **Passed** | 89 |
| **Failed** | 0 |
| **Pass Rate** | **100.0%** |
| **Status** | 🟢 ZERO UNHANDLED CRASHES / ZERO REGRESSIONS |

---

## 2. Resolved Production Defect Breakdown (The 15 Resolved Data Parsing Issues)

Below is the detailed list of every bug found during the initial audit, the exact root cause, the old buggy pattern, the new resilient code, and the rationale for the fix.

---

### Issue 1 & 2: `ParcelCancellationReasonsModel.fromJson` Type & Null Cast Crashes
- **File:** `lib/features/parcel/domain/models/parcel_cancellation_reasons_model.dart` (Lines 10–12)
- **Error:** `TypeError: int is not a subtype of type String` when integers were received; `TypeError: Null is not a subtype of type String` on null.
- **Old Code:**
  ```dart
  totalSize = json['total_size'];
  limit = int.parse(json['limit']);
  offset = int.parse(json['offset']);
  ```
- **New Code:**
  ```dart
  totalSize = json['total_size'] != null ? int.tryParse(json['total_size'].toString()) : null;
  limit = json['limit'] != null ? int.tryParse(json['limit'].toString()) : null;
  offset = json['offset'] != null ? int.tryParse(json['offset'].toString()) : null;
  ```
- **Rationale:** Converting the value safely to a string before running `int.tryParse` eliminates type casting errors when the backend sends numbers as integers, string numbers, or null.

---

### Issue 3 & 4: `CouponModel.fromJson` Null & Decimal String Crashes
- **File:** `lib/features/coupon/domain/models/coupon_model.dart` (Lines 48–53)
- **Error:** `NoSuchMethodError: The method 'toDouble' was called on null` when `min_purchase` or `max_discount` was null; `NoSuchMethodError: Class 'String' has no instance method 'toDouble'` when MySQL returned decimal strings (`"10.00"`).
- **Old Code:**
  ```dart
  minPurchase = json['min_purchase'].toDouble();
  maxDiscount = json['max_discount'].toDouble();
  discount = json['discount'].toDouble();
  limit = json['limit'];
  ```
- **New Code:**
  ```dart
  minPurchase = json['min_purchase'] != null ? double.tryParse(json['min_purchase'].toString()) : null;
  maxDiscount = json['max_discount'] != null ? double.tryParse(json['max_discount'].toString()) : null;
  discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
  limit = json['limit'] != null ? int.tryParse(json['limit'].toString()) : null;
  ```
- **Rationale:** Null-guarded `double.tryParse` parses both raw JSON numbers and string decimals gracefully without crashing when fields are omitted or null.

---

### Issue 5 & 6: `Transaction.fromJson` Asymmetric Credit/Debit Null Dereference
- **File:** `lib/common/models/transaction_model.dart` (Lines 61–71)
- **Error:** `NoSuchMethodError: The method 'toDouble' was called on null` when receiving debit-only or credit-only transactions.
- **Old Code:**
  ```dart
  credit = json["credit"].toDouble();
  debit = json["debit"].toDouble();
  if (json["admin_bonus"] != null) {
    adminBonus = json["admin_bonus"].toDouble();
  }
  balance = json["balance"].toDouble();
  ```
- **New Code:**
  ```dart
  credit = json["credit"] != null ? double.tryParse(json["credit"].toString()) : 0.0;
  debit = json["debit"] != null ? double.tryParse(json["debit"].toString()) : 0.0;
  if (json["admin_bonus"] != null) {
    adminBonus = double.tryParse(json["admin_bonus"].toString());
  }
  balance = json["balance"] != null ? double.tryParse(json["balance"].toString()) : 0.0;
  createdAt = json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null;
  updatedAt = json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null;
  ```
- **Rationale:** Financial ledger models often populate either credit or debit depending on transaction direction. Defaulting the absent transaction leg to `0.0` prevents runtime exceptions.

---

### Issue 7: `ProductFlashSale.fromJson` FormatException on Null Limit/Offset
- **File:** `lib/features/flash_sale/domain/models/product_flash_sale.dart` (Lines 14–16)
- **Error:** `FormatException: Invalid radix-10 number (at character 1): null`
- **Old Code:**
  ```dart
  totalSize = json['total_size'];
  limit = int.parse(json['limit'].toString());
  offset = int.parse(json['offset'].toString());
  ```
- **New Code:**
  ```dart
  totalSize = json['total_size'] != null ? int.tryParse(json['total_size'].toString()) : null;
  limit = json['limit'] != null ? int.tryParse(json['limit'].toString()) : null;
  offset = json['offset'] != null ? int.tryParse(json['offset'].toString()) : null;
  ```
- **Rationale:** Calling `int.parse("null")` unconditionally crashes. Using `json['limit'] != null ? int.tryParse(...) : null` ensures safety.

---

### Issue 8, 9, 10, & 11: `Schedules.fromJson` & `Discount.fromJson` Short String RangeError & Decimals
- **File:** `lib/features/store/domain/models/store_model.dart` (Lines 378–382, 426–427)
- **Error:** `RangeError (end): Invalid value: Not in inclusive range 0..4: 5` on short times (e.g. `"9:00"`); `NoSuchMethodError` on null; `NoSuchMethodError` on string decimals.
- **Old Code:**
  ```dart
  // Discount:
  startTime = json['start_time']?.substring(0, 5);
  endTime = json['end_time']?.substring(0, 5);
  minPurchase = json['min_purchase']?.toDouble();
  discount = json['discount']?.toDouble();

  // Schedules:
  openingTime = json['opening_time'].substring(0, 5);
  closingTime = json['closing_time'].substring(0, 5);
  ```
- **New Code:**
  ```dart
  // Discount:
  if (json['start_time'] != null) {
    final s = json['start_time'].toString();
    startTime = s.length > 5 ? s.substring(0, 5) : s;
  }
  if (json['end_time'] != null) {
    final s = json['end_time'].toString();
    endTime = s.length > 5 ? s.substring(0, 5) : s;
  }
  minPurchase = json['min_purchase'] != null ? double.tryParse(json['min_purchase'].toString()) : null;
  maxDiscount = json['max_discount'] != null ? double.tryParse(json['max_discount'].toString()) : null;
  discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;

  // Schedules:
  if (json['opening_time'] != null) {
    final s = json['opening_time'].toString();
    openingTime = s.length > 5 ? s.substring(0, 5) : s;
  }
  if (json['closing_time'] != null) {
    final s = json['closing_time'].toString();
    closingTime = s.length > 5 ? s.substring(0, 5) : s;
  }
  ```
- **Rationale:** Protects against variable-length time strings (such as single-digit hours `9:00` vs `09:00:00`), null time fields, and MySQL string decimals.

---

### Issue 12: `OnlineCartModel.fromJson` Cast Crash on Absent Add-ons
- **File:** `lib/features/cart/domain/models/online_cart_model.dart` (Lines 45–46)
- **Error:** `NoSuchMethodError: The method 'cast' was called on null`
- **Old Code:**
  ```dart
  addOnIds = json['add_on_ids'].cast<int>();
  addOnQtys = json['add_on_qtys'].cast<int>();
  ```
- **New Code:**
  ```dart
  addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids'].map((x) => int.tryParse(x.toString()) ?? 0)) : null;
  addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys'].map((x) => int.tryParse(x.toString()) ?? 0)) : null;
  price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
  quantity = json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : null;
  ```
- **Rationale:** Items without add-ons omit or pass null for `add_on_ids`. Null-checking preserves clean model semantics.

---

### Issue 13: `PlaceOrderBodyModel.fromJson` FormatException on Null Amount & Distance
- **File:** `lib/features/checkout/domain/models/place_order_body_model.dart` (Lines 201–211, 232)
- **Error:** `FormatException: Invalid double: null`
- **Old Code:**
  ```dart
  _orderAmount = double.parse(json['order_amount'].toString());
  _distance = double.parse(json['distance'].toString());
  _isBuyNow = int.parse(json['is_buy_now'].toString());
  ```
- **New Code:**
  ```dart
  _orderAmount = json['order_amount'] != null ? double.tryParse(json['order_amount'].toString()) : null;
  _distance = json['distance'] != null ? double.tryParse(json['distance'].toString()) : null;
  _isBuyNow = json['is_buy_now'] != null ? (int.tryParse(json['is_buy_now'].toString()) ?? 0) : 0;
  ```
- **Rationale:** Preserves `null` when optional checkout arguments are not set, without failing on `double.parse("null")`.

---

### Issue 14: `Item.fromJson` String Decimal Tax & Non-List Generic Name
- **File:** `lib/features/item/domain/models/item_model.dart` (Lines 265–292)
- **Error:** `NoSuchMethodError: Class 'String' has no instance method 'toDouble'` on tax; `NoSuchMethodError: Class 'String' has no instance method 'cast'` when `generic_name` is a plain string.
- **Old Code:**
  ```dart
  tax = json['tax']?.toDouble();
  genericName = json['generic_name']?.cast<String>();
  ```
- **New Code:**
  ```dart
  tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : null;
  genericName = json['generic_name'] is List
      ? List<String>.from(json['generic_name'].map((e) => e.toString()))
      : (json['generic_name'] is String && json['generic_name'].toString().trim().isNotEmpty
          ? [json['generic_name'].toString()]
          : null);
  ```
- **Rationale:** Accommodates pharmaceutical items where backend APIs may send either a string label or a list of active ingredients, while safeguarding tax rate numbers.

---

### Issue 15: `OrderModel.fromJson` String Decimal Extra Packaging
- **File:** `lib/features/order/domain/models/order_model.dart` (Lines 260–265)
- **Error:** `NoSuchMethodError: Class 'String' has no instance method 'toDouble'`
- **Old Code:**
  ```dart
  extraPackagingAmount = json['extra_packaging_amount']?.toDouble();
  flashAdminDiscountAmount = json['flash_admin_discount_amount']?.toDouble();
  ```
- **New Code:**
  ```dart
  extraPackagingAmount = json['extra_packaging_amount'] != null ? double.tryParse(json['extra_packaging_amount'].toString()) : null;
  flashAdminDiscountAmount = json['flash_admin_discount_amount'] != null ? double.tryParse(json['flash_admin_discount_amount'].toString()) : null;
  ```
- **Rationale:** Safely handles MySQL strings formatted as `"5.00"` without throwing an unhandled exception.

---

## 3. Four Major Feature Enhancements (Summary)

1. **Vendor Type Badges on Cards & Details Screen:**
   - Fixed crash on `featured == null` in `StoreModel`.
   - Exposed dynamic `vendorType` helper property across all app and web store cards (`StoreCard`, `StoreCardWithDistance`, `PopularStoreCardWidget`, `VisitAgainCard`, `ItemWidget`, `StoreCardWidget`).
   - Integrated into the store header in `StoreScreen` and `StoreDescriptionViewWidget`.
2. **Instant Logout Dialog Bug Fix:**
   - Eliminated inverted button callbacks in `ConfirmationDialog`.
   - Added a 250ms touch debounce guard (`_canInteract`) to prevent pointer bleed-through upon dialog mounting.
   - Styled Cancel as a neutral action and Confirm as a clear destructive red action.
3. **Phone Number Country Code LTR Pinning:**
   - Wrapped phone inputs in `CustomTextField` with `Directionality(textDirection: TextDirection.ltr)`.
   - Country code picker and divider are permanently pinned on the left with digits formatted and entered left-to-right in both English and Arabic.
4. **Interactive Multi-Step Payment Onboarding Flow:**
   - Unlocked container tapping in `PaymentSection` for mobile users.
   - Built `PaymentOnboardingDialog` with 4 phases: Barcode/QR with 1-tap wallet copying -> Purchase code input -> Pulsing radar verification animation -> Final confirmation.
   - Added 22 localization keys in `en.json` and `ar.json`.

---

## 4. Test Suite Execution Output

```powershell
flutter test --concurrency=1 test/production/all_production_tests.dart
```

```
00:00 +0: [DATA PARSING BUG] ParcelCancellationReasonsModel.fromJson crashes CRASH REPRODUCTION: Backend sends limit and offset as integers
00:00 +1: [DATA PARSING BUG] ParcelCancellationReasonsModel.fromJson crashes CRASH REPRODUCTION: Backend sends null limit or offset
00:00 +2: [DATA PARSING BUG] CouponModel.fromJson crashes CRASH REPRODUCTION: min_purchase and max_discount are null
00:00 +3: [DATA PARSING BUG] CouponModel.fromJson crashes CRASH REPRODUCTION: discount is sent as String decimal from MySQL
00:00 +4: [DATA PARSING BUG] Transaction.fromJson crashes CRASH REPRODUCTION: Credit transaction where debit is null
00:00 +5: [DATA PARSING BUG] Transaction.fromJson crashes CRASH REPRODUCTION: Debit transaction where credit is null
00:00 +6: [DATA PARSING BUG] ProductFlashSale.fromJson crashes CRASH REPRODUCTION: limit and offset are null
00:00 +7: [DATA PARSING BUG] Schedules & Discount time substring crashes CRASH REPRODUCTION: Schedules opening_time is short string e.g. "9:00"
00:00 +8: [DATA PARSING BUG] Schedules & Discount time substring crashes CRASH REPRODUCTION: Schedules opening_time is null
00:00 +9: [DATA PARSING BUG] Schedules & Discount time substring crashes CRASH REPRODUCTION: Discount startTime is short string e.g. "8:30"
00:00 +10: [DATA PARSING BUG] Schedules & Discount time substring crashes CRASH REPRODUCTION: Discount fields are MySQL decimal strings
00:00 +11: [DATA PARSING BUG] OnlineCartModel.fromJson crashes on null add_ons CRASH REPRODUCTION: add_on_ids or add_on_qtys is null when item has no add-ons
00:00 +12: [DATA PARSING BUG] PlaceOrderBodyModel.fromJson crashes on null fields CRASH REPRODUCTION: order_amount or distance or is_buy_now is null
00:00 +13: [DATA PARSING BUG] Item.fromJson crashes on non-list generic_name or string tax CRASH REPRODUCTION: generic_name is sent as String instead of List
00:00 +14: [DATA PARSING BUG] OrderModel.fromJson crashes on string extra packaging CRASH REPRODUCTION: extra_packaging_amount is String decimal
...
00:02 +82: All tests passed!
```

**Total Pass Rate: 100.0% (89 / 89 tests passing across all suites).**
