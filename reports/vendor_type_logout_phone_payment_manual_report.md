# Comprehensive Manual Engineering & Bug Resolution Report: Vendor Types, Logout Fix, Phone Alignment, & Multi-Step Payment Onboarding

## 1. Executive Metadata
- **Date & Time (Local):** `2026-09-04 01:20:00`
- **Component Area:** Store Presentation, Authentication Dialogs, Internationalization Form Fields, Checkout & Digital Payment Gateways
- **Suite Target:** `test/production/vendor_logout_phone_payment_bug_test.dart`
- **Total Tests Executed:** `7`
- **Passed:** `7 (100%)`
- **Failed:** `0 (0%)`
- **Execution Status:** **Production Ready (All Invariants Verified)**

---

## 2. Executive Summary & Objective

This engineering cycle addressed four core functional and UI/UX issues requested by the user:
1. **Vendor Type on All Vendor Cards & Details Screen:** The application failed to display the vendor type (food, grocery, pharmacy, ecommerce, etc.) across cards and the vendor details header. Furthermore, the `Store` model lacked module resolution and contained an unhandled crash bug on null `featured` values.
2. **Instant Logout Confirmation Dialog Bug:** Clicking "Log Out" displayed a confirmation dialog that immediately logged out without waiting for confirmation or allowing cancellation.
3. **Phone Number & Country Code RTL Inversion:** In RTL locales (such as Arabic), phone inputs placed the country code prefix on the right and digits on the left, violating universal international telephone standards (+[Code] [Number]).
4. **Interactive Multi-Step Payment Onboarding Flow:** Mobile users were unable to tap the payment container in checkout, and selecting wallet/digital payment gateways lacked a guided payment experience with barcode/QR code, merchant wallet copying, purchase code entry, verification animation, and final confirmation.

---

## 3. Bug Catalog & Root-Cause Analysis Table

| Bug ID | Production File | Method / Location | Crash / Defect Mechanism | Severity | Status |
|---|---|---|---|---|---|
| **BUG-01** | `lib/features/store/domain/models/store_model.dart` | `Store.fromJson` (Line 181) | `int.parse(json['featured'].toString())` crashes with `FormatException: Invalid radix-10 number: null` when `featured` is null. `module_type` and `module` were completely dropped. | **Critical (Crash & Data Loss)** | **FIXED** |
| **BUG-02** | `lib/common/widgets/confirmation_dialog.dart` | `ConfirmationDialog.build` (Lines 49–70) | Inverted callbacks on `isLogOut: true`: secondary button executed logout, primary button executed cancel. In RTL mode this placed logout on the right. Zero touch debounce allowed pointer bleed-through to trigger immediate logout upon mounting. | **Critical (Destructive UX)** | **FIXED** |
| **BUG-03** | `lib/common/widgets/custom_text_field.dart` | `CustomTextField.build` (Lines 125, 195) | Flutter `prefixIcon` aligns to the start edge (right side in RTL). Country code picker and divider were placed on the right, and numbers entered on the left. | **Major (UI/UX Flaw)** | **FIXED** |
| **BUG-04** | `lib/features/checkout/widgets/payment_section.dart` | `PaymentSection.build` (Lines 79–88) | `onTap` on the payment method container was guarded with `if(ResponsiveHelper.isDesktop(context))`. Mobile users suffered dead clicks. | **Major (Functional Block)** | **FIXED** |
| **BUG-05** | `lib/features/checkout/widgets/payment_method_bottom_sheet.dart` | `PaymentMethodBottomSheet.build` (Lines 191–240) | Digital/wallet payment gateways (Floosak, Easy Wallet, offline) lacked a guided payment workflow, showing raw inline inputs and abruptly closing on click. | **Major (UX Deficiency)** | **FIXED** |

---

## 4. Deep-Dive Details: Problem, Old Code vs. New Code, & Rationale

### Domain 1: Store Model Crash & Universal Vendor Type Presentation

#### Problem & Root Cause:
1. `Store.fromJson` attempted to parse `featured` with `int.parse(json['featured'].toString())`. When the backend sent `null`, `toString()` evaluated to `"null"`, throwing a fatal `FormatException`.
2. The JSON parser discarded `module_type` and `module` objects sent by backend APIs.
3. Vendor cards (`StoreCard`, `StoreCardWithDistance`, `PopularStoreCard`, `VisitAgainCard`, `ItemWidget`, `StoreCardWidget`) and the Vendor Details header (`StoreScreen`, `StoreDescriptionViewWidget`) had no mechanism to query or display the store's vendor type.

#### Code Changes:

##### File: `lib/features/store/domain/models/store_model.dart`
**Old Code:**
```dart
// CRASH POINT: Throws FormatException on null
featured = int.parse(json['featured'].toString());
zoneId = json['zone_id'];
deliveryTime = json['delivery_time'];
veg = json['veg'];
nonVeg = json['non_veg'];
moduleId = json['module_id'];
// module_type and module fields omitted
```

**New Code:**
```dart
featured = json['featured'] != null ? int.tryParse(json['featured'].toString()) : 0;
zoneId = json['zone_id'];
deliveryTime = json['delivery_time'];
veg = json['veg'];
nonVeg = json['non_veg'];
moduleId = json['module_id'];
moduleType = json['module_type']?.toString();
if (json['module'] != null && json['module'] is Map<String, dynamic>) {
  module = ModuleModel.fromJson(json['module']);
}

// Universal vendor type resolver:
String get vendorType {
  if (module?.moduleName != null && module!.moduleName!.trim().isNotEmpty) {
    return module!.moduleName!;
  }
  if (moduleType != null && moduleType!.trim().isNotEmpty) {
    return moduleType!.tr;
  }
  if (moduleId != null && Get.isRegistered<SplashController>()) {
    final splash = Get.find<SplashController>();
    if (splash.moduleList != null) {
      for (final m in splash.moduleList!) {
        if (m.id == moduleId) {
          return m.moduleName ?? (m.moduleType != null ? m.moduleType!.tr : '');
        }
      }
    }
    if (splash.module != null && splash.module!.id == moduleId) {
      return splash.module!.moduleName ?? (splash.module!.moduleType != null ? splash.module!.moduleType!.tr : '');
    }
  }
  if (storeBusinessModel != null && storeBusinessModel!.trim().isNotEmpty) {
    return storeBusinessModel!.tr;
  }
  if (Get.isRegistered<SplashController>() && Get.find<SplashController>().module != null) {
    final m = Get.find<SplashController>().module!;
    return m.moduleName ?? (m.moduleType != null ? m.moduleType!.tr : '');
  }
  return '';
}
```
**Why:**
- Null-safe integer parsing prevents crashes on null or malformed featured values.
- Dynamic fallback checks direct module models, module type strings, `SplashController.moduleList` by ID, active app modules, and store business models, ensuring a localized vendor type label is always resolved.

##### File: `lib/common/widgets/vendor_type_badge_widget.dart` [NEW]
Created a reusable, theme-integrated pill badge widget:
```dart
class VendorTypeBadgeWidget extends StatelessWidget {
  final Store? store;
  final String? vendorType;
  ...
  @override
  Widget build(BuildContext context) {
    final String type = (vendorType != null && vendorType!.isNotEmpty)
        ? vendorType!
        : (store != null ? store!.vendorType : '');
    if (type.isEmpty) return const SizedBox();

    final Color primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.storefront_outlined, size: 12, color: primaryColor),
            const SizedBox(width: 3),
          ],
          Text(type, style: robotoMedium.copyWith(fontSize: 10, color: primaryColor)),
        ],
      ),
    );
  }
}
```

##### Integrated in all Vendor Cards & Details Screens:
- `lib/common/widgets/card_design/store_card.dart`
- `lib/common/widgets/card_design/store_card_with_distance.dart`
- `lib/common/widgets/card_design/visit_again_card.dart`
- `lib/features/home/widgets/components/popular_store_card_widget.dart`
- `lib/features/home/widgets/web/widgets/store_card_widget.dart`
- `lib/common/widgets/item_widget.dart` (store card mode)
- `lib/features/store/screens/store_screen.dart` (header summary card)
- `lib/features/store/widgets/store_description_view_widget.dart` (desktop & mobile overview)

---

### Domain 2: Confirmation Dialog Accidental Instant-Logout Fix

#### Problem & Root Cause:
1. When `isLogOut: true`, the dialog buttons reversed their semantic meanings:
   - `TextButton` (left): `onPressed: () => isLogOut ? onYesPressed() : ...` (invoked logout!).
   - `CustomButton` (right): `onPressed: () => isLogOut ? Get.back() : onYesPressed()` (invoked cancel!).
2. In RTL mode (Arabic), Flutter mirrors row children, positioning the destructive logout button on the right side where users instinctively expect to confirm or cancel.
3. Pointer events were unguarded: tapping "Log Out" in `MenuScreen` or `MenuDrawer` generated a pointer-up event that bled through to the newly mounted dialog button underneath, triggering instantaneous logout.
4. Wrapping dialog actions with `GetBuilder<OrderController>` coupled unrelated screens to order state changes.

#### Code Changes:

##### File: `lib/common/widgets/confirmation_dialog.dart`
**Old Code:**
```dart
GetBuilder<OrderController>(builder: (orderController) {
  return !orderController.isLoading ? Row(children: [
    Expanded(child: TextButton(
      onPressed: () => isLogOut ? onYesPressed() : onNoPressed != null ? onNoPressed!() : Get.back(),
      child: Text(isLogOut ? 'yes'.tr : 'no'.tr),
    )),
    const SizedBox(width: Dimensions.paddingSizeLarge),
    Expanded(child: CustomButton(
      buttonText: isLogOut ? 'no'.tr : 'yes'.tr,
      onPressed: () => isLogOut ? Get.back() : onYesPressed(),
    )),
  ]) : const Center(child: CircularProgressIndicator());
})
```

**New Code:**
```dart
class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _canInteract = false;

  @override
  void initState() {
    super.initState();
    // 250ms tap guard prevents pointer bleed-through from preceding tap event
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _canInteract = true);
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(children: [
      // CANCEL / NO BUTTON (Neutral secondary style)
      Expanded(
        child: TextButton(
          onPressed: !_canInteract ? null : () {
            if (widget.onNoPressed != null) widget.onNoPressed!(); else Get.back();
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            minimumSize: const Size(Dimensions.webMaxWidth, 50),
          ),
          child: Text('cancel'.tr, style: robotoBold),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeLarge),

      // CONFIRM / YES BUTTON (Primary or Destructive Error style)
      Expanded(
        child: CustomButton(
          buttonText: widget.isLogOut ? 'logout'.tr : 'yes'.tr,
          color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: !_canInteract ? null : () => widget.onYesPressed(),
          radius: Dimensions.radiusSmall,
          height: 50,
        ),
      ),
    ]);
  }
}
```
**Why:**
- Strict separation of Cancel (`Get.back()`) and Confirm (`onYesPressed()`) eliminates inverted logic in both LTR and RTL.
- The 250ms `_canInteract` guard completely absorbs any touch pass-through.
- Destructive red styling clearly signals the logout action.
- Only orders-related flows observe `OrderController`.

---

### Domain 3: Phone Number Country Code Left Alignment (RTL/LTR)

#### Problem & Root Cause:
- In `custom_text_field.dart`, country dial codes were housed inside `InputDecoration.prefixIcon`.
- In RTL layout, Flutter renders `prefixIcon` at the `TextDirection` start (the **right** side).
- Consequently, in Arabic, phone numbers appeared with the dial code on the right and digits on the left. International phone numbers must strictly read left-to-right (`+[CountryCode] [Digits]`).

#### Code Changes:

##### File: `lib/common/widgets/custom_text_field.dart`
**Old Code:**
```dart
child: TextFormField(
  textAlign: widget.textAlign,
  ...
  decoration: InputDecoration(
    prefixIcon: (widget.isPhone || widget.countryDialCode != null)
        ? SizedBox(width: 95, child: Row(...)) // Positioned on right in RTL!
        : null,
  ),
)
```

**New Code:**
```dart
child: Directionality(
  textDirection: (widget.isPhone || widget.countryDialCode != null)
      ? TextDirection.ltr
      : Directionality.of(context),
  child: TextFormField(
    textAlign: (widget.isPhone || widget.countryDialCode != null)
        ? TextAlign.left
        : widget.textAlign,
    ...
  ),
)
```

##### File: `lib/features/checkout/widgets/guest_delivery_address.dart`
**Old Code:**
```dart
Widget addressInfo(String key, String value) {
  return Text(value, style: robotoRegular); // Flipped in BiDi
}
```

**New Code:**
```dart
Widget addressInfo(String key, String value) {
  return Text(
    value,
    style: robotoRegular,
    textDirection: (key.toLowerCase().contains('phone') || value.startsWith('+'))
        ? TextDirection.ltr
        : null,
  );
}
```
**Why:**
- Locking the input field and text representation to `TextDirection.ltr` ensures the country code is always pinned to the left, with digits formatted and entered left-to-right.
- Ambient layout of the surrounding form and titles remains in native RTL.

---

### Domain 4: Checkout Payment Mobile Clickability & Multi-Step Onboarding Flow

#### Problem & Root Cause:
1. `PaymentSection` locked container taps behind `if (ResponsiveHelper.isDesktop(context))`. On mobile devices, tapping the container did nothing.
2. In `PaymentMethodBottomSheet`, selecting digital wallets (Floosak, Easy Wallet) displayed an unprompted small text field without merchant account numbers, barcode/QR codes, or payment instructions.
3. Clicking "Select" closed the bottom sheet without payment verification or confirmation.

#### Code Changes:

##### File: `lib/features/checkout/widgets/payment_section.dart`
**Old Code:**
```dart
onTap: () {
  if (ResponsiveHelper.isDesktop(context) && checkoutController.paymentMethodIndex == -1) {
    // Only opened on desktop if no payment method was selected!
    Get.dialog(Dialog(child: PaymentMethodBottomSheet(...)));
  }
}
```

**New Code:**
```dart
onTap: () {
  if (isCashOnDeliveryActive || isDigitalPaymentActive || isWalletActive || isOfflinePaymentActive) {
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(
        backgroundColor: Colors.transparent,
        child: PaymentMethodBottomSheet(...),
      ));
    } else {
      Get.bottomSheet(
        PaymentMethodBottomSheet(...),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    }
  } else {
    showCustomSnackBar('no_payment_method_found'.tr);
  }
}
```

##### File: `lib/features/checkout/widgets/payment_method_bottom_sheet.dart`
**Old Code:**
```dart
child: CustomButton(
  buttonText: 'select'.tr,
  onPressed: () => Get.back(),
)
```

**New Code:**
```dart
child: CustomButton(
  buttonText: 'continue'.tr,
  onPressed: () {
    final bool isWalletGateway = checkoutController.paymentMethodIndex == 2 &&
        (checkoutController.digitalPaymentName == 'easy_wallet' || checkoutController.digitalPaymentName == 'floosak');
    if (isWalletGateway) {
      final digitalGateways = Get.find<SplashController>().configModel?.activePaymentMethodList;
      final selectedGateway = digitalGateways?.firstWhereOrNull((g) => g.getWay == checkoutController.digitalPaymentName);

      Get.back(); // close selection sheet
      Get.dialog(
        PaymentOnboardingDialog(
          paymentMethodName: checkoutController.digitalPaymentName ?? '',
          paymentTitle: selectedGateway?.getWayTitle ?? (checkoutController.digitalPaymentName == 'easy_wallet' ? 'Easy Wallet' : 'Floosak'),
          paymentImage: selectedGateway?.getWayImageFullUrl,
          totalPrice: widget.totalPrice,
        ),
      );
    } else {
      Get.back();
    }
  },
)
```

##### File: `lib/features/checkout/widgets/payment_onboarding_dialog.dart` [NEW]
Created an onboarding dialog with 4 distinct phases:
- **Phase 1 (Wallet Info & Barcode/QR):**
  - Crisp vector QR & Barcode painter (`_QrBarcodePainter`) rendering merchant payment codes.
  - Merchant Wallet Number card with 1-tap "Copy" button, animated checkmark, and clipboard notification toast.
  - Numbered 3-step payment guide (Open wallet -> Transfer exact amount/scan QR -> Copy purchase code).
- **Phase 2 (Enter Purchase Code):**
  - Formatted input with quick paste action and real-time validation.
  - Direct connection to `CheckoutController.purchaseCodeController`.
- **Phase 3 (Animated Verification Loading Screen):**
  - Smooth pulsating radar/shield animation with themed glowing rings.
  - Progressive live status indicators:
    - *"Connecting to payment gateway..."*
    - *"Verifying purchase code with wallet provider..."*
    - *"Confirming order placement..."*
- **Phase 4 (Final Confirmation):**
  - **Success State:** Green celebratory checkmark animation, Order ID, amount paid, and "Done / Track Order" actions.
  - **Failure State:** Error badge with explanation, "Re-enter Code", and "Change Payment Method" actions.

---

## 5. Verification & Test Execution Logs

All automated regression and production feature tests were executed via the Flutter test runner:

```powershell
flutter test test/production/vendor_logout_phone_payment_bug_test.dart
```

### Execution Output:
```
00:00 +0: FEATURE & BUG TEST 1: Store Model Robustness & Vendor Type Exposure Store.fromJson MUST parse safely when backend sends null featured without crashing
00:00 +1: FEATURE & BUG TEST 1: Store Model Robustness & Vendor Type Exposure Store MUST parse module_type and expose non-empty vendorType
00:00 +2: FEATURE & BUG TEST 1: Store Model Robustness & Vendor Type Exposure Store.vendorType MUST resolve fallback correctly from module_id or store_business_model if module_type omitted
00:00 +3: FEATURE & BUG TEST 2: ConfirmationDialog Logout Semantics & Button Placement ConfirmationDialog action buttons MUST maintain consistent Cancel and Confirm semantics
00:00 +4: FEATURE & BUG TEST 3: Phone Number Country Code Left Alignment (LTR) Phone layout MUST force TextDirection.ltr so Country Code is pinned on the Left in all languages
00:00 +5: FEATURE & BUG TEST 4: Payment Section Mobile Clickability & Multi-Step Workflow PaymentSection container MUST allow mobile users to tap and open payment selection
00:00 +6: FEATURE & BUG TEST 4: Payment Section Mobile Clickability & Multi-Step Workflow Multi-Step Payment Onboarding MUST support 4 distinct phases
00:00 +7: All tests passed!
```

### Static Analysis:
```powershell
flutter analyze
```
Result: **0 errors** across all modified files.
