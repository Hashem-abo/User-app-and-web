import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class DynamicMotherShelfView extends StatefulWidget {
  final ShelfModel shelf;
  final bool isFood;
  final bool isShop;
  final double? height;
  const DynamicMotherShelfView({super.key, required this.shelf, required this.isFood, required this.isShop, this.height});

  @override
  State<DynamicMotherShelfView> createState() => _DynamicMotherShelfViewState();
}

class _DynamicMotherShelfViewState extends State<DynamicMotherShelfView> {
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
      if (!_isCarouselPaused && _scrollController.hasClients && (widget.shelf.children?.length ?? 0) > 1) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = (widget.shelf.itemCardWidth?.toDouble() ?? 110) + Dimensions.paddingSizeExtraSmall;

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
    return (shelf.children != null && shelf.children!.isNotEmpty) ? Column(children: [
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
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
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              SizedBox(
                height: height ?? (shelf.height?.toDouble() ?? 130),
                child: GestureDetector(
              onPanDown: (_) => _pauseAutoScroll(),
              child: shelf.autoPlay == true
                  ? CarouselSlider.builder(
                      itemCount: (shelf.children!.length / (shelf.rowCount ?? 1)).ceil(),
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
                        return _buildItemsColumn(columnIndex);
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      itemCount: (shelf.children!.length / (shelf.rowCount ?? 1)).ceil(),
                      itemBuilder: (context, columnIndex) {
                        return _buildItemsColumn(columnIndex);
                      },
                    ),
            ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),
    ]) : const SizedBox();
  }

  Widget _buildItemsColumn(int columnIndex) {
    ShelfModel shelf = widget.shelf;
    int rows = shelf.rowCount ?? 1;
    return Column(
      children: List.generate(rows, (rowIndex) {
        int index = (columnIndex * rows) + rowIndex;
        if (index >= shelf.children!.length) {
          return const Expanded(child: SizedBox());
        }

        ShelfModel child = shelf.children![index];
        double width = shelf.itemCardWidth?.toDouble() ?? 110;
        double imageHeight = shelf.height?.toDouble() ?? 130;
        
        return Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(RouteHelper.getDynamicShelfItemsRoute(child.id)),
            child: Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImage(
                  image: child.image ?? '',
                  height: double.infinity, width: width,
                  fit: BoxFit.cover,
                ),
              ),
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
