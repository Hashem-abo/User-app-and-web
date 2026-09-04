# Sixam Mart Production Bug Resolution & System Stabilization Report

**Resolution Date:** September 4, 2026  
**Target Codebase:** Sixam Mart (`sixam_mart` User App & Web Modules)  
**Execution Suite:** `test/full_production_suite.dart`  
**Report Status:** ✅ **100% RESOLUTION VERIFIED (237/237 PASSED)**  

---

## 🎯 Executive Summary

Following an exhaustive system audit that exposed 15+ live production bugs, crashes, and memory leaks across the codebase, a comprehensive stabilization effort was executed directly on the production source code.

All issues were systematically identified, patched with defensive engineering patterns, and verified against the automated test suite:

| Metric | Before Fixes | After Fixes | Status |
|---|---|---|---|
| **Total Tests** | 237 | 237 | Verified |
| **Passing Tests** | 222 | **237** | **+15 (+100.0%)** |
| **Failed Tests** | 15 | **0** | **0 Regressions** |
| **Pass Rate** | 93.7% | **100.0%** | **Optimal** |
| **Execution Duration** | 51.71s | 55.28s | Streaming JSON |

---

## 🛠️ Complete Directory of Fixed Files & Bugs

### 1. `lib/features/item/domain/services/item_service.dart`
- **Root Cause:**
  - Multiple methods dereferenced nullable arguments with hard `!` operators:
    - `collapseVariation(List<FoodVariation>? foodVariations)` crashed on `foodVariations!.length`.
    - `initializeCartVariationIndexes` crashed on `variation!.isNotEmpty` and `choiceOptions!`.
    - `initializeCartAddonActiveList` crashed on `addOnIds!` and `addOns!`.
    - `initializeCartAddonsQtyList` crashed on `addOnIds!` and `addOns!`.
    - `initializeCollapseVariation`, `initializeVariationIndexes`, `initializeAddonActiveList`, `initializeAddonQtyList` crashed on null lists.
    - `setQuantity` crashed on `stock!` when stock was null in stock-managed modules.
- **Fix Applied:**
  - Added null guards defaulting to empty collections (`[]`).
  - Added safe index checking before accessing options: `varIndex < variationTypes.length`.
  - Replaced `stock!` in stock bounds verification with safe `(stock != null && (...) > stock)`.
- **Result:** Cart quantity increments, variation dialogs, and addon initializations operate without crashes even for items without variations or stock.

---

### 2. `lib/features/store/domain/models/store_model.dart`
- **Root Cause:**
  - `Store.fromJson` invoked `.toDouble()` directly on MySQL decimal strings (`tax`, `minimumShippingCharge`, `maximumShippingCharge`, `perKmShippingCharge`, `perKmShippingChargeGroup`, `minimumShippingChargeGroup`, `extraPackagingAmount`, `distance`), throwing `NoSuchMethodError`.
  - `categoryIds` used `json['category_ids'].cast<int>()`, throwing `TypeError` when backend returned string ID arrays like `["1", "2"]`.
- **Fix Applied:**
  - Replaced all raw `.toDouble()` calls with `double.tryParse(json['...'].toString())`.
  - Replaced lazy `.cast<int>()` with safe conversion:
    ```dart
    categoryIds = json['category_ids'] != null 
        ? List<int>.from(json['category_ids'].map((e) => int.tryParse(e.toString()) ?? 0)) 
        : [];
    ```
- **Result:** Stores with string decimal tax, packaging fees, distance values, or string category IDs deserialize cleanly.

---

### 3. `lib/features/location/domain/models/zone_response_model.dart`
- **Root Cause:**
  - `ZoneData.fromJson` called `double.parse(v['lat'].toString())` on coordinate points. When any boundary point was null, `double.parse("null")` threw `FormatException`.
  - `Pivot.fromJson` called `.toDouble()` directly on `per_km_shipping_charge`, `minimum_shipping_charge`, `maximum_shipping_charge`, `maximum_cod_order_amount`, `per_km_shipping_charge_group`, `minimum_shipping_charge_group`, and `minimum_delivery_charge`, crashing on MySQL string decimals.
- **Fix Applied:**
  - Guarded coordinate points:
    ```dart
    if (v != null && v['lat'] != null && v['lng'] != null) {
      final lat = double.tryParse(v['lat'].toString());
      final lng = double.tryParse(v['lng'].toString());
      if (lat != null && lng != null) formatedCoordinates!.add(LatLng(lat, lng));
    }
    ```
  - Replaced `.toDouble()` in `Pivot.fromJson` with `double.tryParse(json['...'].toString())`.
- **Result:** Malformed geofence coordinates and string shipping fees no longer crash the splash/location screen.

---

### 4. `lib/features/search/controllers/search_controller.dart`
- **Root Cause:**
  - `searchByAiData` used `query!.isNotEmpty` without null checking.
  - Search responses directly called `.stores!` and `.items!` on `StoreModel` / `ItemModel`, throwing `NullCheckOperator` on empty search responses.
  - `getSearchSuggestions` iterated over `_searchSuggestionModel!.items!` and `_searchSuggestionModel!.stores!` and forced `item.name!`, crashing if any item or store had a null name or null list.
- **Fix Applied:**
  - Added null check `if (query != null && query.isNotEmpty ...)` in `searchByAiData`.
  - Stored model stores/items in local variables and checked for null before `.addAll()`.
  - Added null checks on items/stores collections and checked `item.name != null` before adding to suggestions.
- **Result:** Search and AI search gracefully handle null queries, empty responses, and incomplete suggestion payloads.

---

### 5. `lib/features/chat/domain/models/chat_model.dart`
- **Root Cause:**
  - `Order.fromJson` in `chat_model.dart` called `orderAmount = json['order_amount']?.toDouble()`, which threw `NoSuchMethodError` when backend sent a string decimal.
- **Fix Applied:**
  - Changed to `orderAmount = json['order_amount'] != null ? double.tryParse(json['order_amount'].toString()) : null;`.
- **Result:** Chat screen loads orders with string decimal amounts cleanly.

---

### 6. `lib/features/parcel/domain/models/parcel_category_model.dart`
- **Root Cause:**
  - `parcelPerKmShippingCharge` and `parcelMinimumShippingCharge` called `.toDouble()` directly without checking for String type.
- **Fix Applied:**
  - Replaced with `double.tryParse(json['...'].toString()) ?? 0`.
- **Result:** Parcel category selection screen no longer crashes when receiving string charges.

---

### 7. `lib/features/order/domain/models/order_details_model.dart`
- **Root Cause:**
  - `price = (json['price'] as num?)?.toDouble() ?? 0` threw `TypeError` when price was sent as String `"45.00"`.
  - `discountOnItem`, `taxAmount`, and `totalAddOnPrice` threw `TypeError` on string cast.
  - `AddOn.fromJson` threw `TypeError` on string price and `FormatException` on null quantity.
- **Fix Applied:**
  - Replaced `as num?` with `double.tryParse(json['...'].toString())`.
  - Replaced `int.parse` in `AddOn.fromJson` with `int.tryParse`.
- **Result:** Order details screen safely displays orders regardless of MySQL stringification settings.

---

### 8. `lib/features/checkout/screens/checkout_screen.dart`
- **Root Cause:**
  - `initState()` initialized 9 controllers and focus nodes for guest checkout (`guestContactPersonNameController`, `guestContactPersonNumberController`, `guestEmailController`, `guestPasswordController`, `guestConfirmPasswordController`, `guestNumberNode`, `guestEmailNode`, `guestPasswordNode`, `guestConfirmPasswordNode`).
  - `dispose()` only cleaned 2 of them, permanently leaking 7 text controllers and focus nodes on every checkout visit.
- **Fix Applied:**
  - Disposed all 7 leaked controllers and focus nodes inside `dispose()` before calling `super.dispose()`.
- **Result:** Fixed memory leak and accumulated listener overhead during checkout navigation.

---

### 9. `lib/common/widgets/item_widget.dart`
- **Root Cause:**
  - Line 276 used: `isStore && (store != null && store!.ratingCount! > 0) ? ratingView : Row(children: [PriceConverter.convertPrice(item!.price), ...])`.
  - When rendering a newly added store with 0 ratings (`ratingCount == 0`), the ternary evaluated the `else` branch, dereferencing `item!.price!` where `item` was `null`.
  - Line 318 rendered `CartCountView(item: item!)` unconditionally inside the column.
- **Fix Applied:**
  - Structured the ternary to check `isStore` first, rendering a store rating view or `SizedBox()`, and only evaluating item pricing if `!isStore && item != null`.
  - Guarded `CartCountView` with `!isStore && item != null`.
- **Result:** Store listing cards with 0 reviews render correctly without crashing.

---

### 10. `lib/features/review/widgets/review_widget.dart` & `user_review_widget.dart`
- **Root Cause:**
  - Direct call `review.rating!.toDouble()` threw `NullCheckOperator` when a review had a null rating.
  - `DateConverter.containTAndZToUTCFormat(review.createdAt!)` threw `NullCheckOperator` on null `createdAt`.
- **Fix Applied:**
  - Defaulted null rating to 0: `(review.rating ?? 0).toDouble()`.
  - Fallback on `review.createdAt ?? ''`.
- **Result:** User reviews with pending or missing ratings display cleanly.

---

### 11. `lib/helper/validate_check.dart`
- **Root Cause:**
  - `ValidateCheck.validateEmail(String? value)` crashed on `if (value!.isEmpty)` when called with `null`.
  - `ValidateCheck.loyaltyCheck` crashed with `FormatException` when passed non-numeric input (`'abc'`).
- **Fix Applied:**
  - Added null check: `if (value == null || value.trim().isEmpty) return 'email_field_is_required'.tr;`.
  - Replaced `int.parse(value)` with `int.tryParse(value.trim())` and added appropriate validation feedback.
- **Result:** Email and loyalty point form fields handle uninitialized state and invalid user input safely.

---

### 12. `lib/helper/date_converter.dart`
- **Root Cause:**
  - `dateTimeStringToDateOnly` and `dateTimeStringToDate` threw `FormatException` when receiving ISO-8601 strings containing `'T'` and `'Z'`.
  - `convertTimeToTime` threw `FormatException` on empty strings or strings with seconds (`'09:30:00'`).
- **Fix Applied:**
  - Added multi-format try-catch fallbacks with `DateTime.parse(dateTime).toLocal()`.
  - Added empty string check and multiple format parsing in `convertTimeToTime`.
- **Result:** Universal compatibility with both MySQL timestamps and standard ISO-8601 API responses.

---

### 13. `lib/helper/price_converter.dart`
- **Root Cause:**
  - `PriceConverter.convertPrice` and `convertAnimationPrice` dereferenced `price!` directly, throwing `NullCheckOperator` when `price` was `null`.
- **Fix Applied:**
  - Defaulted null price at the entry of both methods: `price ??= 0.0;` and removed `price!`.
- **Result:** Null item prices safely render as formatted zero amounts (`$0.00`) instead of crashing the UI.

---

### 14. `lib/helper/responsive_helper.dart`
- **Root Cause:**
  - Line 21 had: `if (size < 650 || !kIsWeb) return true;`.
  - On native Android tablets and iPads, `!kIsWeb` forced `isMobile()` to return `true` regardless of screen width (e.g. 1024px), suppressing the tablet layout.
- **Fix Applied:**
  - Removed `|| !kIsWeb` so that device classification is strictly driven by screen dimensions: `if (size < 650) return true;`.
- **Result:** Native tablets correctly receive tablet responsive layouts.

---

### 15. `lib/helper/route_helper.dart`
- **Root Cause:**
  - Multiple routes called `int.parse(...)` and `double.parse(...)` with `!` directly on URL parameters:
    - `/payment` route (`id`, `user`, `amount`).
    - `/item-details` route (`id`).
    - `/offline-payment` route (`zone_id`, `total`, `max_cod_amount`).
    - `/flash-sale-details` route (`id`).
    - `/brands-item-screen` route (`brandId`).
  - On Web, any malformed deep link or direct URL navigation with missing query parameters caused an unhandled exception that crashed the router.
- **Fix Applied:**
  - Replaced all forced parses with `int.tryParse(Get.parameters['...'] ?? '') ?? 0` and `double.tryParse(...)`.
- **Result:** Deep link routing on web and mobile is robust against missing or malformed query parameters.

---

### 16. `lib/features/auth/domain/reposotories/auth_repository.dart`
- **Root Cause:**
  - `updateToken`, `clearSharedData`, and `setNotificationActive` called `AddressHelper.getUserAddressFromSharedPref()!.zoneId`.
  - If a user was logged out, on a fresh install, or had no saved address, this threw `NullCheckOperatorUsedOnANullValue`.
- **Fix Applied:**
  - Safely checked `final userAddress = AddressHelper.getUserAddressFromSharedPref();` and guarded topic unsubscription with `if (userAddress?.zoneId != null)`.
- **Result:** User logout, guest authentication, and notification toggling never crash due to absent saved addresses.

---

### 17. `lib/features/order/screens/order_details_screen.dart`
- **Root Cause:**
  - Prescription medicine `itemsPrice` back-calculation formula was:
    `itemsPrice = (orderAmount + discount) - ((taxIncluded ? 0 : tax) + deliveryCharge) - additionalCharge;`
  - This omitted `dmTips` and `extraPackagingCharge`, causing the displayed medicine cost to be inflated by the tip and packaging fees.
- **Fix Applied:**
  - Corrected formula:
    `itemsPrice = (orderAmount + discount + couponDiscount + referrerBonusAmount) - ((taxIncluded ? 0 : tax) + deliveryCharge + dmTips + additionalCharge + extraPackagingCharge);`
- **Result:** Customer invoices and order details show mathematically accurate medicine totals.

---

### 18. `lib/features/checkout/controllers/checkout_controller.dart`
- **Root Cause:**
  - Lines 604 & 630 performed `distanceMater / 1000` where `distanceMater = response.body['distanceMeters']?.toDouble()`.
  - When the Distance Matrix API returned null `distanceMeters`, it threw `NoSuchMethodError: The operator '/' was called on null`.
- **Fix Applied:**
  - Added null check on `response.body['distanceMeters']` and used `double.tryParse` with fallback to `Geolocator.distanceBetween()`.
- **Result:** Distance and delivery charge calculations never crash on unexpected Distance Matrix responses.

---

## 🔒 Verification & Compliance Summary

1. **Automated Verification:**
   - Unified suite executed via `dart run tool/test_runner.dart --suite test/full_production_suite.dart --all --export reports/production_audit_report.md`.
   - **237 / 237 Tests Passed (100.0%)**.
   - Zero test failures, zero regressions.
2. **Git Commit Discipline:**
   - Only production source code files modified to fix bugs (`lib/`).
   - Reporting files updated in `/reports`.
   - Zero temporary code or extraneous packages committed.
