import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SortWidget extends StatefulWidget {
  final bool isStore;
  const SortWidget({super.key, required this.isStore});

  @override
  State<SortWidget> createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  bool _isAscending = true;
  int _criteriaIndex = 0; // 0: Name, 1: Price, 2: Rating, 3: Discount, 4: Date

  @override
  void initState() {
    super.initState();
    final searchController = Get.find<search.SearchController>();
    int currentIndex = widget.isStore ? searchController.storeSortIndex : searchController.sortIndex;
    
    if(currentIndex == -1) {
      _criteriaIndex = 0;
      _isAscending = true;
    } else if(currentIndex == 0 || currentIndex == 1) {
      _criteriaIndex = 0;
      _isAscending = currentIndex == 0;
    } else if(currentIndex == 2 || currentIndex == 3) {
      _criteriaIndex = 1;
      _isAscending = currentIndex == 2;
    } else if(currentIndex == 4) {
      _criteriaIndex = 2;
      _isAscending = false;
    } else if(currentIndex == 5) {
      _criteriaIndex = 3;
      _isAscending = false;
    } else if(currentIndex == 6) {
      _criteriaIndex = 4;
      _isAscending = false;
    }
  }

  void _applySort() {
    final searchController = Get.find<search.SearchController>();
    int finalIndex = -1;
    
    if(_criteriaIndex == 0) {
      finalIndex = _isAscending ? 0 : 1;
    } else if(_criteriaIndex == 1) finalIndex = _isAscending ? 2 : 3;
    else if(_criteriaIndex == 2) finalIndex = 4;
    else if(_criteriaIndex == 3) finalIndex = 5;
    else if(_criteriaIndex == 4) finalIndex = 6;

    if(widget.isStore) {
      searchController.setStoreSortIndex(finalIndex);
      searchController.sortStoreSearchList();
    } else {
      searchController.setSortIndex(finalIndex);
      searchController.sortItemSearchList();
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Container(
              height: 5, width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAscending = true;
                    _criteriaIndex = 0;
                  });
                },
                child: Text('reset'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
              ),
              Text('sort'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor, size: 25),
              ),
            ]),
          ]),
        ),
        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            Text('sort_by'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(children: [
              Expanded(child: _buildToggleButton('ascending'.tr, _isAscending, () => setState(() => _isAscending = true))),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(child: _buildToggleButton('descending'.tr, !_isAscending, () => setState(() => _isAscending = false))),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            const Divider(),

            Text('filter_by'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            _buildRadioOption('price'.tr, 1),
            _buildRadioOption('rating'.tr, 2),
            _buildRadioOption('discount'.tr, 3),
            _buildRadioOption('date'.tr, 4),
            _buildRadioOption('name'.tr, 0),

            const SizedBox(height: Dimensions.paddingSizeLarge),
            
            ElevatedButton(
              onPressed: _applySort,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text('apply_sort'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
            ),

          ]),
        ),

      ]),
    );
  }

  Widget _buildToggleButton(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Text(title, style: robotoMedium.copyWith(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
      ),
    );
  }

  Widget _buildRadioOption(String title, int index) {
    return InkWell(
      onTap: () => setState(() => _criteriaIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: _criteriaIndex == index ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
          Radio<int>(
            value: index,
            groupValue: _criteriaIndex,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) => setState(() => _criteriaIndex = val!),
          ),
        ]),
      ),
    );
  }
}
