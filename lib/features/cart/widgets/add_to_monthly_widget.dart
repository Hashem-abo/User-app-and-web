import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MonthlyReorderSection  –  premium banner card shown in the cart / checkout
// ─────────────────────────────────────────────────────────────────────────────
class MonthlyReorderSection extends StatelessWidget {
  const MonthlyReorderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (controller) {
      final bool isChecked = controller.monthlySubscribe;
      final bool isDark = Theme.of(context).brightness == Brightness.dark;

      // Accent colours – works in both light and dark mode
      final Color primaryColor = Theme.of(context).primaryColor;
      final Color accentSoft = primaryColor.withValues(alpha: isDark ? 0.18 : 0.10);
      final Color borderColor = primaryColor.withValues(alpha: isChecked ? 0.55 : 0.20);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: accentSoft,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: InkWell(
            onTap: controller.toggleMonthlySubscribe,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: 14,
              ),
              child: Row(children: [
                // ── Calendar icon badge ──────────────────────────────────
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.70)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.autorenew_rounded, color: Colors.white, size: 22),
                ),

                const SizedBox(width: 12),

                // ── Title + subtitle + info link ─────────────────────────
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'add_to_monthly_order'.tr,
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    GestureDetector(
                      onTap: () => _showMonthlyPolicySheet(context, controller),
                      child: Text(
                        'see_policy'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor: primaryColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(width: 10),

                // ── Animated toggle switch ───────────────────────────────
                _AnimatedToggle(
                  value: isChecked,
                  activeColor: primaryColor,
                  onChanged: (_) => controller.toggleMonthlySubscribe(),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated iOS-style toggle
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedToggle extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggle({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color trackOff = Theme.of(context).disabledColor.withValues(alpha: 0.35);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? activeColor : trackOff,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Policy bottom-sheet
// ─────────────────────────────────────────────────────────────────────────────
void _showMonthlyPolicySheet(BuildContext context, CheckoutController controller) {
  final List<String> policyKeys = controller.getMonthlyReorderPolicy();
  final Color primaryColor = Theme.of(context).primaryColor;

  Get.bottomSheet(
    _PolicySheet(policyKeys: policyKeys, primaryColor: primaryColor),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _PolicySheet extends StatelessWidget {
  final List<String> policyKeys;
  final Color primaryColor;

  const _PolicySheet({required this.policyKeys, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final Color subtleBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : primaryColor.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── Drag handle ─────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header with gradient ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'monthly_reorder_policy'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'monthly_reorder_subtitle'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                      height: 1.4,
                    ),
                  ),
                ]),
              ),
              InkWell(
                onTap: () => Get.back(),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded, color: Theme.of(context).hintColor, size: 20),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Policy steps card ───────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: subtleBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < policyKeys.length; i++) ...[
                      _PolicyStep(
                        stepNumber: i + 1,
                        text: policyKeys[i].tr,
                        primaryColor: primaryColor,
                      ),
                      if (i < policyKeys.length - 1)
                        Divider(
                          height: 20,
                          thickness: 0.5,
                          color: primaryColor.withValues(alpha: 0.12),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── "Got it" button ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'got_it'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single policy step row
// ─────────────────────────────────────────────────────────────────────────────
class _PolicyStep extends StatelessWidget {
  final int stepNumber;
  final String text;
  final Color primaryColor;

  const _PolicyStep({
    required this.stepNumber,
    required this.text,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Numbered badge
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: textColor,
            height: 1.5,
          ),
        ),
      ),
    ]);
  }
}
