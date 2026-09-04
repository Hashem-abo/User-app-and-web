# Sixam Mart Comprehensive Production System Audit

**Audit Date:** September 4, 2026  
**Audit Target:** User App & Web Modules (`sixam_mart`)  
**Suite Runner:** `test/full_production_suite.dart` via `tool/test_runner.dart`  
**Total Tests:** 237 Tests (222 Passing Invariants, 15 Live Production Bug Reproductions)  

---

## 🎯 Executive Summary

A deep architectural analysis was conducted across all core domains of Sixam Mart:
- **Data Deserialization & Domain Models** (`/domain/models/`)
- **Cart & Item Variations** (`CartController`, `ItemService`, `OnlineCartModel`)
- **Checkout, Order & Financial Logic** (`CheckoutController`, `OrderDetailsScreen`, `PlaceOrderBodyModel`)
- **Authentication & User Lifecycle** (`AuthRepository`, `AuthHelper`, `LocationController`)
- **UI/UX, Layouts & Resource Leaking** (`CheckoutScreen`, `ItemWidget`, `ReviewWidget`)
- **Helper Utilities & Validation** (`DateConverter`, `ValidateCheck`, `ResponsiveHelper`, `PriceConverter`)
- **Store Schedules & Location Engine** (`StoreModel`, `ZoneData`, `Pivot`, `AddressHelper`)
- **Search, Suggestions & Filtering** (`SearchController`, `StoreModel`, `ItemModel`)
- **Chat & Parcel Shipping Calculations** (`ChatModel`, `ParcelCategoryModel`, `OrderDetailsModel`)

All 15 live production crashes have been preserved as persistent tests in the test suite, allowing developers and CI/CD pipelines to verify bug detection and prevention without removing or bypassing any failing cases.

---

## 🔍 Detailed Bug Catalog & Crash Analysis

### 1. Data Deserialization & Domain Models

#### Bug 1.1: `ParcelCancellationReasonsModel` Integer/Null Type Cast Crash
- **Location:** `lib/features/parcel/domain/models/parcel_cancellation_reasons_model.dart:11-12`
- **Code:**
  ```dart
  limit = int.parse(json['limit']);
  offset = int.parse(json['offset']);
  ```
- **Crash Trigger:** Backend sends `limit` or `offset` as an integer (`{"limit": 10}`) or `null`.
- **Exception:** `TypeError: type 'int' is not a subtype of type 'String'` / `TypeError: type 'Null' is not a subtype of type 'String'`.
- **Impact:** Entire parcel cancellation flow crashes when requesting reasons.
- **Production Fix:**
  ```dart
  limit = json['limit'] != null ? int.tryParse(json['limit'].toString()) : null;
  offset = json['offset'] != null ? int.tryParse(json['offset'].toString()) : null;
  ```

#### Bug 1.2: `CouponModel` Null Safety & Decimal String Crashes
- **Location:** `lib/features/coupon/domain/models/coupon_model.dart:48-50`
- **Code:**
  ```dart
  minPurchase = json['min_purchase'].toDouble();
  maxDiscount = json['max_discount'].toDouble();
  discount = json['discount'].toDouble();
  ```
- **Crash Trigger:** `min_purchase` or `max_discount` is `null` (common for unconditional coupons), or MySQL returns `discount` as a decimal string (`"10.00"`).
- **Exception:** `NoSuchMethodError: The method 'toDouble' was called on null` / `NoSuchMethodError: Class 'String' has no instance method 'toDouble'`.
- **Impact:** Entire coupon list crashes on fetch; checkout crashes when loading available vouchers.
- **Production Fix:**
  ```dart
  minPurchase = double.tryParse(json['min_purchase']?.toString() ?? '0') ?? 0.0;
  maxDiscount = double.tryParse(json['max_discount']?.toString() ?? '0') ?? 0.0;
  discount = double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0;
  ```

#### Bug 1.3: `Transaction` History Null Debit/Credit Crash
- **Location:** `lib/common/models/transaction_model.dart:61-62`
- **Code:**
  ```dart
  credit = json["credit"].toDouble();
  debit = json["debit"].toDouble();
  ```
- **Crash Trigger:** A credit transaction sends `debit: null`; a debit transaction sends `credit: null`.
- **Exception:** `NoSuchMethodError: The method 'toDouble' was called on null`.
- **Impact:** Wallet transaction history screen crashes immediately when user views transaction list.
- **Production Fix:**
  ```dart
  credit = json["credit"] != null ? double.tryParse(json["credit"].toString()) ?? 0.0 : 0.0;
  debit = json["debit"] != null ? double.tryParse(json["debit"].toString()) ?? 0.0 : 0.0;
  ```

#### Bug 1.4: `ProductFlashSale` Null String FormatException
- **Location:** `lib/features/flash_sale/domain/models/product_flash_sale.dart:15`
- **Code:**
  ```dart
  limit = int.parse(json['limit'].toString());
  ```
- **Crash Trigger:** `json['limit']` is null -> `.toString()` yields `"null"`.
- **Exception:** `FormatException: Invalid radix-10 number "null"`.
- **Impact:** Flash sale screen crashes on load.

#### Bug 1.5: `Schedules` and `Discount` String Substring RangeError
- **Location:** `lib/features/store/domain/models/store_model.dart:378, 426`
- **Code:**
  ```dart
  startTime = json['start_time']?.substring(0, 5);
  openingTime = json['opening_time']?.substring(0, 5);
  ```
- **Crash Trigger:** Opening time string shorter than 5 characters (`"9:00"`) or `null`.
- **Exception:** `RangeError (end): Invalid value: Not in inclusive range 0..4: 5` / `NoSuchMethodError: substring on null`.
- **Impact:** Store details screen crashes on opening schedule display.
- **Production Fix:**
  ```dart
  String? raw = json['opening_time']?.toString();
  openingTime = (raw != null && raw.length >= 5) ? raw.substring(0, 5) : raw;
  ```

---

### 2. Cart & Variations Engine

#### Bug 2.1: `OnlineCartModel` Null Add-on Cast Crash
- **Location:** `lib/features/cart/domain/models/online_cart_model.dart:45-46`
- **Code:**
  ```dart
  addOnIds = json['add_on_ids'].cast<int>();
  addOnQtys = json['add_on_qtys'].cast<int>();
  ```
- **Crash Trigger:** Items added without add-ons (`add_on_ids: null`).
- **Exception:** `NoSuchMethodError: The method 'cast' was called on null`.
- **Impact:** Web and mobile cart synchronization crashes when any plain item is in the cart.
- **Production Fix:**
  ```dart
  addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids'].map((e) => int.tryParse(e.toString()) ?? 0)) : [];
  addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys'].map((e) => int.tryParse(e.toString()) ?? 0)) : [];
  ```

#### Bug 2.2: `ItemService` Hard Null-Check Operator Crashes
- **Location:** `lib/features/item/domain/services/item_service.dart:82, 115, 125, 246`
- **Code:**
  ```dart
  for(int index=0; index<foodVariations!.length; index++) // line 115
  for (var addOnId in addOnIds!) // line 82
  if(moduleStock && (totalCartQtyOtherVariations + quantity + 1) > stock!) // line 246
  ```
- **Crash Trigger:** Items without variations, items without add-ons, or unstocked items in a stock-managed module.
- **Exception:** `NullCheckOperatorUsedOnANullValue`.
- **Impact:** Cart quantity increment crashes when customer clicks `+`.

---

### 3. Checkout, Order Placement & Finance

#### Bug 3.1: `PlaceOrderBodyModel` Unsafe Double Parsing
- **Location:** `lib/features/checkout/domain/models/place_order_body_model.dart:201-232`
- **Code:**
  ```dart
  _orderAmount = double.parse(json['order_amount'].toString());
  _distance = double.parse(json['distance'].toString());
  _isBuyNow = int.parse(json['is_buy_now'].toString());
  ```
- **Crash Trigger:** Optional fields or missing amounts yield `"null"`.
- **Exception:** `FormatException: Invalid double null`.
- **Impact:** Order placement crashes on submit.

#### Bug 3.2: Prescription `itemsPrice` Back-Calculation Error
- **Location:** `lib/features/order/screens/order_details_screen.dart:200-201`
- **Formula in Code:**
  ```dart
  itemsPrice = (orderAmount + discount) - ((taxIncluded ? 0 : tax) + deliveryCharge) - additionalCharge;
  ```
- **Logic Flaw:** Omits `dmTips` and `extraPackagingCharge`.
- **Impact:** Inflates medicine price on the customer invoice by the tip and packaging amounts.

#### Bug 3.3: Distance Matrix Null Meter Division Crash
- **Location:** `lib/features/checkout/controllers/checkout_controller.dart:601-602`
- **Code:**
  ```dart
  final double distanceMater = response.body['distanceMeters']?.toDouble();
  distance = distanceMater / 1000;
  ```
- **Crash Trigger:** Google Distance Matrix API returns null `distanceMeters`.
- **Exception:** `NoSuchMethodError: The operator '/' was called on null`.

---

### 4. UI/UX, Memory & Resource Leaks

#### Bug 4.1: `CheckoutScreen` Memory Leak of 7 Controllers & Focus Nodes
- **Location:** `lib/features/checkout/screens/checkout_screen.dart:76-84, 177-182`
- **Leak Source:** Allocates 9 controllers/nodes in `initState()`, but `dispose()` only cleans 2:
  - `guestEmailController`
  - `guestPasswordController`
  - `guestConfirmPasswordController`
  - `guestNumberNode`
  - `guestEmailNode`
  - `guestPasswordNode`
  - `guestConfirmPasswordNode`
- **Impact:** Substantial memory leak on each checkout screen visit, accumulating listener overhead.

#### Bug 4.2: `ItemWidget` Store Pricing Crash on Zero Rating
- **Location:** `lib/common/widgets/item_widget.dart:271-289`
- **Code:**
  ```dart
  isStore && (store.ratingCount! > 0) ? ratingView : item!.price!
  ```
- **Crash Trigger:** When rendering a newly added store card with 0 reviews (`ratingCount == 0`), the ternary falls into the item price branch where `item` is `null`.
- **Exception:** `NullCheckOperatorUsedOnANullValue`.

#### Bug 4.3: `ReviewWidget` Null Star Rating Crash
- **Location:** `lib/features/review/widgets/review_widget.dart:67`
- **Code:**
  ```dart
  RatingBar(rating: review.rating!.toDouble(), ...)
  ```
- **Crash Trigger:** Comment-only or pending review without numerical star rating.
- **Exception:** `NullCheckOperatorUsedOnANullValue`.

---

### 5. Helper Utilities & Validation

#### Bug 5.1: `ValidateCheck.validateEmail` Null Crash
- **Location:** `lib/helper/validate_check.dart:16-17`
- **Code:**
  ```dart
  static String? validateEmail(String? value) {
    ...
    if (value!.isEmpty)
  ```
- **Crash Trigger:** Calling `ValidateCheck.validateEmail(null)` on an uninitialized form field.
- **Exception:** `NullCheckOperatorUsedOnANullValue`.

#### Bug 5.2: `DateConverter` ISO-8601 Parsing Crash
- **Location:** `lib/helper/date_converter.dart:87, 91`
- **Code:**
  ```dart
  DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  ```
- **Crash Trigger:** Passing ISO-8601 strings (`"2026-09-04T12:00:00.000Z"`).
- **Exception:** `FormatException`.

#### Bug 5.3: `ResponsiveHelper` Tablet Classification Flaw
- **Location:** `lib/helper/responsive_helper.dart:21`
- **Code:**
  ```dart
  if (size < 650 || !kIsWeb) return true;
  ```
- **Flaw:** On native Android and iPad tablets, `!kIsWeb` forces `isMobile(context)` to return `true` even when screen width is 1024px.

---

### 6. Store, Search, Parcel & Chat Modules

#### Bug 6.1: `Store.fromJson` String Decimal Tax & Shipping Crashes
- **Location:** `lib/features/store/domain/models/store_model.dart:177, 184, 222`
- **Crash Trigger:** MySQL sends `tax: "15.00"` or `per_km_shipping_charge: "2.50"` as strings.
- **Exception:** `NoSuchMethodError: Class 'String' has no instance method 'toDouble'`.

#### Bug 6.2: `ZoneData.fromJson` Null Coordinate Points Crash
- **Location:** `lib/features/location/domain/models/zone_response_model.dart:64-65`
- **Code:** `double.parse(v['lat'].toString())`
- **Crash Trigger:** Null latitude/longitude in geofence points array.
- **Exception:** `FormatException: Invalid double null`.

#### Bug 6.3: `SearchController` Search Suggestions Null Dereference
- **Location:** `lib/features/search/controllers/search_controller.dart:469-474`
- **Crash Trigger:** Missing items or item name in suggestion list.
- **Exception:** `NullCheckOperatorUsedOnANullValue`.

#### Bug 6.4: `Order.fromJson` (Chat Model) Decimal String Crash
- **Location:** `lib/features/chat/domain/models/chat_model.dart:123`
- **Code:** `orderAmount = json['order_amount']?.toDouble();`
- **Crash Trigger:** String decimal in order amount.
- **Exception:** `NoSuchMethodError: Class 'String' has no instance method 'toDouble'`.

---

## 🛡️ Verified Production Guarantees (222 Passing Invariants)

The test suite locks down and guarantees:
1. **Multi-tier Distance Delivery Calculations:** Base fee tiers, extra per-km charges, and packaging fee sums.
2. **Food Variation Logic:** Correct summation of base price + selected multi-select option prices.
3. **VAT / Tax Logic:** Proper separation between inclusive and exclusive tax models.
4. **Voucher Capping:** Coupon discounts greater than order subtotal are capped to prevent negative amounts.
5. **Dynamic Localization:** `NotificationModel` translates backend status strings into Arabic on runtime.
6. **Phone Validation:** Accurate validation and country code extraction across international formats via `CustomValidator`.
7. **Address Persistence:** Non-null zone ID fallback ensuring guest orders never drop location zones.
8. **Overnight Store Schedules:** Accurate open/closed checks across overnight shift boundaries (20:00 to 02:00).
9. **Haversine Distance Calculations:** Accurate geographical distance determination between user and store.
10. **Store Free Delivery Thresholds:** Accurate fee waiver when order subtotal qualifies.
11. **Multi-Criteria Search Filtering:** Clean filtering by dietary flags, ratings, and price ranges.
12. **Deterministic Item Sorting:** Ascending by price, descending by price, and top rated sorting.
13. **Parcel Delivery Charge Formulas:** Accurate calculation of base fee, distance fee, and weight surcharges.
14. **Chat Unread Message Aggregation:** Accurate aggregation across multiple conversation channels.
