import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/size_info_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:uuid/uuid.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class EditSizeScreen extends StatefulWidget {
  final SizeInfo? sizeInfo;
  const EditSizeScreen({super.key, this.sizeInfo});

  @override
  State<EditSizeScreen> createState() => _EditSizeScreenState();
}

class _EditSizeScreenState extends State<EditSizeScreen> {
  final TextEditingController labelController = TextEditingController();
  double weight = 60.0;
  double bust = 90.0;
  double waist = 80.0;
  double hips = 90.0;
  String fitPreference = 'Average';
  double footLength = 25.0;
  String shoeSize = 'Nike / US / 9';

  @override
  void initState() {
    super.initState();
    if (widget.sizeInfo != null) {
      labelController.text = widget.sizeInfo!.label;
      weight = widget.sizeInfo!.weight;
      bust = widget.sizeInfo!.bust;
      waist = widget.sizeInfo!.waist;
      hips = widget.sizeInfo!.hips;
      fitPreference = widget.sizeInfo!.fitPreference;
      footLength = widget.sizeInfo!.footLength;
      shoeSize = widget.sizeInfo!.shoeSize;
    } else {
      labelController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.sizeInfo != null ? 'edit_my_size'.tr : 'my_size'.tr,
          style: robotoBold.copyWith(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label input (Who is this size for)
            Text('profile_for_whom'.tr, style: robotoBold.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                hintText: 'enter_name_relation'.tr,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ruler: Weight
            rulerSlider('weight', weight, 30.0, 150.0, 'kg', (val) {
              setState(() {
                weight = val;
              });
            }),

            const SizedBox(height: 20),

            // Ruler: Bust
            rulerSlider('bust', bust, 50.0, 150.0, 'cm', (val) {
              setState(() {
                bust = val;
              });
            }),

            const SizedBox(height: 20),

            // Ruler: Waist
            rulerSlider('waist', waist, 40.0, 130.0, 'cm', (val) {
              setState(() {
                waist = val;
              });
            }),

            const SizedBox(height: 20),

            // Ruler: Hips
            rulerSlider('hips', hips, 50.0, 150.0, 'cm', (val) {
              setState(() {
                hips = val;
              });
            }),

            const SizedBox(height: 40),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              ),
              onPressed: () async {
                if (labelController.text.trim().isEmpty) {
                  showCustomSnackBar('please_enter_profile_label'.tr);
                  return;
                }
                final size = SizeInfo(
                  id: widget.sizeInfo?.id ?? const Uuid().v4(),
                  label: labelController.text.trim(),
                  weight: weight,
                  bust: bust,
                  waist: waist,
                  hips: hips,
                  fitPreference: fitPreference,
                  footLength: footLength,
                  shoeSize: shoeSize,
                );
                await profileController.saveSizeInfo(size);
                Get.back();
                showCustomSnackBar('size_profile_saved_successfully'.tr, isError: false);
              },
              child: Text(
                'save'.tr,
                style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rulerSlider(String title, double currentValue, double min, double max, String unit, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.tr, style: robotoBold.copyWith(color: Colors.black, fontSize: 14)),
            Text('${currentValue.toStringAsFixed(1)} $unit', style: robotoBold.copyWith(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.grey[200],
            thumbColor: Colors.black,
            trackHeight: 2.0,
            overlayColor: Colors.black.withOpacity(0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        // Visual indicator ticks matching Shein app
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final tickVal = min + ((max - min) / 4) * index;
              return Text(
                tickVal.toStringAsFixed(0),
                style: robotoRegular.copyWith(color: Colors.grey[400], fontSize: 11),
              );
            }),
          ),
        ),
      ],
    );
  }
}
