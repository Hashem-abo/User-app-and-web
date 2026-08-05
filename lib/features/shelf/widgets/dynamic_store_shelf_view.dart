import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/service/widgets/service_provider_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card.dart';

class DynamicStoreShelfView extends StatefulWidget {
  final ShelfModel shelf;
  final double? height;
  const DynamicStoreShelfView({super.key, required this.shelf, this.height});

  @override
  State<DynamicStoreShelfView> createState() => _DynamicStoreShelfViewState();
}

class _DynamicStoreShelfViewState extends State<DynamicStoreShelfView> {
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
      if (!_isCarouselPaused && _scrollController.hasClients && ((widget.shelf.stores?.length ?? 0) > 1 || (widget.shelf.serviceProviders?.length ?? 0) > 1)) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = (widget.shelf.itemCardWidth?.toDouble() ?? 120) + Dimensions.paddingSizeExtraSmall;

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
    return ((shelf.stores != null && shelf.stores!.isNotEmpty) || (shelf.serviceProviders != null && shelf.serviceProviders!.isNotEmpty)) ? Column(children: [

      Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: shelf.backgroundType == 'solid' && shelf.backColor != null ? HexColor(shelf.backColor!) : null,
          gradient: shelf.backgroundType == 'gradient' ? LinearGradient(
            colors: [
              shelf.backColor != null ? HexColor(shelf.backColor!) : Colors.blue.withOpacity(0.1),
              shelf.backColor2 != null ? HexColor(shelf.backColor2!) : (shelf.backColor != null ? HexColor(shelf.backColor!).withOpacity(0.1) : Colors.blue.withOpacity(0.01)),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ) : (shelf.backgroundType == 'solid' || shelf.backgroundType == 'image' ? null : LinearGradient(
            colors: [
              shelf.backColor != null ? HexColor(shelf.backColor!) : Colors.blue.withOpacity(0.1),
              shelf.backColor != null ? HexColor(shelf.backColor!).withOpacity(0.1) : Colors.blue.withOpacity(0.01),
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
            height: height != null ? (height - 60) : (shelf.height != null) ? (shelf.height! - 60).toDouble() : (shelf.imageType == 'circle' ? 160 : 240),
            child: GestureDetector(
              onPanDown: (_) => _pauseAutoScroll(),
              child: shelf.autoPlay == true
                  ? CarouselSlider.builder(
                      itemCount: (((shelf.stores?.length ?? 0) > 0 ? (shelf.stores?.length ?? 0) : (shelf.serviceProviders?.length ?? 0)) / (shelf.rowCount ?? 1)).ceil(),
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
                      itemCount: (((shelf.stores?.length ?? 0) > 0 ? (shelf.stores?.length ?? 0) : (shelf.serviceProviders?.length ?? 0)) / (shelf.rowCount ?? 1)).ceil(),
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
    int rows = shelf.rowCount ?? 1;
    return Column(
      children: List.generate(rows, (rowIndex) {
        int index = (columnIndex * rows) + rowIndex;
        int maxLen = (shelf.stores?.length ?? 0) > 0 ? (shelf.stores?.length ?? 0) : (shelf.serviceProviders?.length ?? 0);
        if (index >= maxLen) {
          return const Expanded(child: SizedBox());
        }

        if (shelf.serviceProviders != null && shelf.serviceProviders!.isNotEmpty) {
          if (shelf.imageType == 'circle') {
            double size = shelf.itemCardWidth?.toDouble() ?? 100;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                child: InkWell(
                  onTap: () => Get.toNamed(
                    RouteHelper.getServiceProviderRoute(shelf.serviceProviders![index]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(
                      height: size, width: size,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CustomImage(
                          image: '${shelf.serviceProviders![index].logoFullUrl}',
                          height: size, width: size,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      width: size + 20,
                      child: Text(
                        shelf.serviceProviders![index].companyName ?? '',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }
           return Expanded(
             child: Padding(
               padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeExtraSmall),
               child: ServiceProviderWidget(
                 provider: shelf.serviceProviders![index],
               ),
             ),
           );
        }

        if (shelf.imageType == 'circle') {
          double size = shelf.itemCardWidth?.toDouble() ?? 100;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
              child: InkWell(
                onTap: () => Get.toNamed(
                  RouteHelper.getStoreRoute(id: shelf.stores![index].id, page: 'store'),
                  arguments: StoreScreen(store: shelf.stores![index], fromModule: false),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Container(
                    height: size, width: size,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CustomImage(
                        image: '${shelf.stores![index].logoFullUrl}',
                        height: size, width: size,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  SizedBox(
                    width: size + 20,
                    child: Text(
                      shelf.stores![index].name ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
              ),
            ),
          );
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeExtraSmall),
            child: StoreCard(
              store: shelf.stores![index],
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
