import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/service/widgets/service_widget.dart';

class DynamicShelfView extends StatefulWidget {
  final ShelfModel shelf;
  final bool isFood;
  final bool isShop;
  final double? height;
  const DynamicShelfView({super.key, required this.shelf, required this.isFood, required this.isShop, this.height});

  @override
  State<DynamicShelfView> createState() => _DynamicShelfViewState();
}

class _DynamicShelfViewState extends State<DynamicShelfView> {
  Timer? _pauseTimer;
  bool _isCarouselPaused = false;
  
  final ScrollController _scrollController = ScrollController();
  Timer? _listAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    if (widget.shelf.autoPlay != true) {
       _startListAutoScroll();
    }
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _listAutoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startListAutoScroll() {
    _listAutoScrollTimer?.cancel();
    _listAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isCarouselPaused && _scrollController.hasClients && ((widget.shelf.items?.length ?? 0) > 1 || (widget.shelf.services?.length ?? 0) > 1)) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = (widget.shelf.itemCardWidth?.toDouble() ?? 180) + Dimensions.paddingSizeExtraSmall;

        if (currentScroll >= maxScroll) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        } else {
          _scrollController.animateTo(currentScroll + delta, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        }
      }
    });
  }

  void _pauseAutoScroll() {
    setState(() {
      _isCarouselPaused = true;
    });

    _pauseTimer?.cancel();
    _pauseTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _isCarouselPaused = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ShelfModel shelf = widget.shelf;
    double? height = widget.height;
    return ((shelf.items != null && shelf.items!.isNotEmpty) || (shelf.services != null && shelf.services!.isNotEmpty)) ? Column(children: [

      Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: shelf.backgroundType == 'solid' && shelf.backColor != null ? HexColor(shelf.backColor!) : null,
          gradient: shelf.backgroundType == 'gradient' ? LinearGradient(
            colors: [
              shelf.backColor != null ? HexColor(shelf.backColor!) : Colors.green.withOpacity(0.1),
              shelf.backColor2 != null ? HexColor(shelf.backColor2!) : (shelf.backColor != null ? HexColor(shelf.backColor!).withOpacity(0.1) : Colors.green.withOpacity(0.01)),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ) : (shelf.backgroundType == 'solid' || shelf.backgroundType == 'image' ? null : LinearGradient(
            colors: [
              shelf.backColor != null ? HexColor(shelf.backColor!) : Colors.green.withOpacity(0.1),
              shelf.backColor != null ? HexColor(shelf.backColor!).withOpacity(0.1) : Colors.green.withOpacity(0.01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          image: shelf.backgroundType == 'image' && shelf.backImage != null ? DecorationImage(
            image: CustomImage.targetProvider(shelf.backImage!),
            fit: BoxFit.cover,
          ) : null,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(children: [
          Container(
            height: shelf.headerHeight?.toDouble(),
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeExtraSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (shelf.hideTitle != true)
                  Text(
                    shelf.name ?? '',
                    style: robotoBold.copyWith(
                      fontSize: shelf.titleFontSize?.toDouble() ?? 20,
                      color: shelf.titleColor != null ? HexColor(shelf.titleColor!) : Colors.black87,
                    ),
                  ),
                if (shelf.hideTitle == true) const Spacer(),

                Visibility(
                  visible: shelf.hideViewAll != true,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: () => Get.toNamed(RouteHelper.getDynamicShelfItemsRoute(shelf.id)),
                    child: Text(
                      'view_all'.tr,
                      style: robotoBold.copyWith(
                        color: shelf.viewAllColor != null ? HexColor(shelf.viewAllColor!) : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: height != null ? (height - 20) : (shelf.height != null) ? (shelf.height! - 20).toDouble() : 380,
            child: GestureDetector(
              onPanDown: (_) => _pauseAutoScroll(),
              child: shelf.autoPlay == true
                  ? CarouselSlider.builder(
                      itemCount: (((shelf.items?.length ?? 0) > 0 ? (shelf.items?.length ?? 0) : (shelf.services?.length ?? 0)) / (shelf.rowCount ?? 1)).ceil(),
                      options: CarouselOptions(
                        autoPlay: !_isCarouselPaused,
                        autoPlayInterval: const Duration(seconds: 3),
                        enlargeCenterPage: false,
                        viewportFraction: (shelf.itemCardWidth != null && shelf.itemCardWidth! > 0)
                            ? (shelf.itemCardWidth! + 20) / Get.width
                            : 0.4,
                        padEnds: false,
                        aspectRatio: 1,
                        disableCenter: true,
                      ),
                      itemBuilder: (context, columnIndex, realIndex) {
                        return _buildItemsColumn(context, columnIndex);
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      itemCount: (((shelf.items?.length ?? 0) > 0 ? (shelf.items?.length ?? 0) : (shelf.services?.length ?? 0)) / (shelf.rowCount ?? 1)).ceil(),
                      itemBuilder: (context, columnIndex) {
                        return _buildItemsColumn(context, columnIndex);
                      },
                    ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ]),
      ),

      const SizedBox(height: Dimensions.paddingSizeDefault),

    ]) : const SizedBox();
  }

  Widget _buildItemsColumn(BuildContext context, int columnIndex) {
    ShelfModel shelf = widget.shelf;
    bool isFood = widget.isFood;
    bool isShop = widget.isShop;
    int rows = shelf.rowCount ?? 1;
    return Column(
      children: List.generate(rows, (rowIndex) {
        int index = (columnIndex * rows) + rowIndex;
        int maxLen = (shelf.items?.length ?? 0) > 0 ? (shelf.items?.length ?? 0) : (shelf.services?.length ?? 0);
        if (index >= maxLen) {
          return const Expanded(child: SizedBox());
        }

        if (shelf.services != null && shelf.services!.isNotEmpty) {
           return Expanded(
             child: Padding(
               padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeExtraSmall),
               child: SizedBox(
                 width: shelf.itemCardWidth?.toDouble() ?? 250,
                 child: ServiceWidget(
                   service: shelf.services![index],
                   index: index,
                 ),
               ),
             ),
           );
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeExtraSmall),
            child: ItemCard(
              item: shelf.items![index],
              isPopularItem: false,
              isFood: isFood,
              isShop: isShop,
              index: index,
              width: shelf.itemCardWidth?.toDouble() ?? 180,
            ),
          ),
        );
      }),
    );
  }
}


class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
