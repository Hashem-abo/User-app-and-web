import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteContentView extends StatefulWidget {
  const FavouriteContentView({super.key});

  @override
  State<FavouriteContentView> createState() => _FavouriteContentViewState();
}

class _FavouriteContentViewState extends State<FavouriteContentView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';
  String _searchType = 'items';

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      WebScreenTitleWidget(title: 'favourite'.tr),

      SizedBox(
        width: Dimensions.webMaxWidth,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    isDense: true,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor, size: 24),
                    suffixIcon: _searchText.isNotEmpty ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 24),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = '';
                        });
                        FocusScope.of(context).unfocus();
                      },
                    ) : null,
                  ),
                  onChanged: (String query) {
                    setState(() {
                      _searchText = query;
                    });
                  },
                ),
              ),
                Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                ),
                child: DropdownButton<String>(
                  value: _searchType,
                  items: [
                    DropdownMenuItem(value: 'items', child: Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meals'.tr : 'items'.tr)),
                    DropdownMenuItem(value: 'stores', child: Text(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                    });
                  },
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).disabledColor),
                ),
              ),
            ]),
          ),
        ),
      ),

      Expanded(child: _searchType == 'items' 
          ? FavItemViewWidget(isStore: false, searchText: _searchText)
          : FavItemViewWidget(isStore: true, searchText: _searchText)
      ),

    ]);
  }
}
