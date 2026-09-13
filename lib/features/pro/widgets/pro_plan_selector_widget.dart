import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_button.dart';
import 'package:suliman/features/pro/controllers/pro_controller.dart';
import 'package:suliman/features/pro/domain/models/pro_plan_model.dart';
import 'package:suliman/features/pro/widgets/pro_payment_bottom_sheet_widget.dart';
import 'package:suliman/helper/price_converter.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class ProPlanSelectorWidget extends StatefulWidget {
  final List<PlanItem> plans;
  final int? currentPlanId;
  final bool isRenewal;
  final VoidCallback? onCancel;
  const ProPlanSelectorWidget({super.key,
    required this.plans, this.currentPlanId, this.isRenewal = false, this.onCancel,
  });

  @override
  State<ProPlanSelectorWidget> createState() => _ProPlanSelectorWidgetState();
}

class _ProPlanSelectorWidgetState extends State<ProPlanSelectorWidget> {
  int _selectedPlanIndex = 0;

  /*
  late ScrollController _durationScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  */

  @override
  void initState() {
    super.initState();
    _selectedPlanIndex = _getSelectedPlanIndex(widget.plans);

    /*
    _durationScrollController = ScrollController();
    _durationScrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
    */
  }

  /*
  @override
  void dispose() {
    _durationScrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_durationScrollController.hasClients) return;
    setState(() {
      _canScrollLeft = _durationScrollController.offset > 5;
      _canScrollRight = _durationScrollController.offset < (_durationScrollController.position.maxScrollExtent - 5);
    });
  }

  void _scrollDuration(bool isLeft) {
    const scrollAmount = 100.0;
    final newOffset = isLeft
        ? (_durationScrollController.offset - scrollAmount).clamp(0.0, _durationScrollController.position.maxScrollExtent)
        : (_durationScrollController.offset + scrollAmount).clamp(0.0, _durationScrollController.position.maxScrollExtent);
    _durationScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xffA16BFF);
    final int selectedPlanIndex = _getSelectedPlanIndex(widget.plans);
    final PlanItem? selectedPlan = widget.plans.isNotEmpty ? widget.plans[selectedPlanIndex] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.plans.isNotEmpty) ...[
          Text('choose_your_pro_plan'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildPlanList(context, List.generate(widget.plans.length, (index) => MapEntry(index, widget.plans[index]))),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],

        _buildPriceRow(context, selectedPlan, buttonColor),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.onCancel != null)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: CustomButton(
                    height: 45,
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                    onPressed: widget.onCancel,
                    radius: Dimensions.radiusSmall,
                    buttonText: 'back'.tr,
                    fontSize: Dimensions.fontSizeSmall,
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: _buildSubscribeButton(context, selectedPlan, buttonColor, widget.onCancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanList(BuildContext context, List<MapEntry<int, PlanItem>> plans) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (context, index) {
        final MapEntry<int, PlanItem> entryItem = plans[index];
        final bool isSelected = _selectedPlanIndex == entryItem.key;
        return InkWell(
          onTap: () => setState(() => _selectedPlanIndex = entryItem.key),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: isSelected ? Theme.of(context).primaryColor.withAlpha(200) : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entryItem.value.planName ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                // FIXED: Wrapped right-side details in Flexible to prevent overflow
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          PriceConverter.convertPrice(entryItem.value.price ?? 0),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' / ${entryItem.value.duration ?? 0} ${'days'.tr}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(BuildContext context, PlanItem? plan, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              plan?.planName ?? '',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // FIXED: Wrapped the trailing RichText inside a Flexible wrapper
          Flexible(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: PriceConverter.convertPrice(plan?.price),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  TextSpan(
                    text: ' / ${plan?.duration ?? 0} ${'days'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context, PlanItem? plan, Color? buttonColor, VoidCallback? onCancel) {
    bool isRenew = widget.isRenewal && plan?.id == widget.currentPlanId;
    String buttonText = 'subscribe_now'.tr;
    if (plan?.planType == ProPlanType.freeTrial) {
      buttonText = 'start_free_trial'.tr;
    } else if (isRenew) {
      buttonText = 'renew_subscription'.tr;
    } else if (widget.isRenewal) {
      buttonText = 'shift_plan'.tr;
    }

    return GetBuilder<ProController>(builder: (proController) {
      return SizedBox(
        height: 45,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: proController.isSubscribeLoading || plan == null ? null : () {
            onCancel?.call();
            _onSubscribePressed(context, plan, isRenew);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            elevation: 0,
          ),
          child: proController.isSubscribeLoading ? SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 2),
          ) : Text(
            buttonText,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });
  }

  void _onSubscribePressed(BuildContext context, PlanItem plan, bool isRenew) {
    if ((plan.price ?? 0) <= 0) {
      Get.find<ProController>().subscribePlan(plan, 'free_trial', 'free_trial', isRenew);
      return;
    }
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew)));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew),
      );
    }
  }

  int _getSelectedPlanIndex(List<PlanItem> plans) {
    if (_selectedPlanIndex < plans.length) return _selectedPlanIndex;
    _selectedPlanIndex = 0;
    return _selectedPlanIndex;
  }
}