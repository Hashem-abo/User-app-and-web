import 'package:sixam_mart/features/home/domain/models/store_corner_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';

class StoreCornerView extends StatefulWidget {
  final StoreCornerModel? storeCorner;
  final bool isShop;
  final bool isFood;
  final bool isGrocery;

  const StoreCornerView({
    super.key,
    this.storeCorner,
    required this.isShop,
    required this.isFood,
    required this.isGrocery,
  });

  @override
  State<StoreCornerView> createState() => _StoreCornerViewState();
}

class _StoreCornerViewState extends State<StoreCornerView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Timer? _pauseTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pauseTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isPaused && _scrollController.hasClients && (widget.storeCorner?.items?.length ?? 0) > 1) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 150 + Dimensions.paddingSizeSmall; // One item width + padding

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
      _isPaused = true;
    });
    
    _pauseTimer?.cancel();
    _pauseTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _isPaused = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storeCorner == null || widget.storeCorner!.store == null) {
      return const SizedBox();
    }

    final store = widget.storeCorner!.store!;
    final items = widget.storeCorner!.items;
    
    // Parse colors
    Color? bgColor1;
    if (widget.storeCorner!.backgroundColor != null && widget.storeCorner!.backgroundColor!.startsWith('#')) {
        try {
            bgColor1 = Color(int.parse(widget.storeCorner!.backgroundColor!.replaceFirst('#', '0xff')));
        } catch (e) {
            bgColor1 = Theme.of(context).primaryColor.withOpacity(0.4);
        }
    } else {
        bgColor1 = Theme.of(context).primaryColor.withOpacity(0.4);
    }

    Color? bgColor2;
    if (widget.storeCorner!.backgroundColor2 != null && widget.storeCorner!.backgroundColor2!.startsWith('#')) {
        try {
            bgColor2 = Color(int.parse(widget.storeCorner!.backgroundColor2!.replaceFirst('#', '0xff')));
        } catch (e) {
            bgColor2 = bgColor1.withOpacity(0.1);
        }
    } else {
        bgColor2 = bgColor1.withOpacity(0.1);
    }

    Color? btnColor;
    if (widget.storeCorner!.viewMoreButtonColor != null && widget.storeCorner!.viewMoreButtonColor!.startsWith('#')) {
        try {
            btnColor = Color(int.parse(widget.storeCorner!.viewMoreButtonColor!.replaceFirst('#', '0xff')));
        } catch (e) {
            btnColor = Theme.of(context).primaryColor;
        }
    } else {
        btnColor = Theme.of(context).primaryColor;
    }

    return Container(
      decoration: widget.storeCorner!.backgroundType == 'image' ? BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        image: DecorationImage(
          image: CustomImage.targetProvider(widget.storeCorner!.coverImageFullUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ) : null,
      child: Column(
        children: [
          // Store Corner Cover Photo (Pinned to top, no margin)
          InkWell(
            onTap: () {
               Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'store'));
            },
            child: AspectRatio(
              aspectRatio: 1400 / 300,
              child: (widget.storeCorner!.backgroundType != 'image') ? ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                child: CustomImage(
                  image: '${widget.storeCorner!.coverImageFullUrl}',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ) : const SizedBox(),
            ),
          ),

          // Content with background below the image
          Container(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
              color: widget.storeCorner!.backgroundType == 'solid' ? bgColor1 : null,
              gradient: widget.storeCorner!.backgroundType == 'gradient' ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor1,
                  bgColor2,
                ],
              ) : (widget.storeCorner!.backgroundType == 'solid' || widget.storeCorner!.backgroundType == 'image' ? null : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor1,
                  bgColor1.withOpacity(0.7),
                  bgColor1.withOpacity(0.4),
                  bgColor1.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
              )),
            ),
            child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Item List
            if (items != null && items.isNotEmpty)
              SizedBox(
                height: widget.isFood ? 230 :350,
                child: GestureDetector(
                  onPanDown: (_) => _pauseAutoScroll(),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ItemCard(
                          item: items[index],
                          store: store,
                          isShop: widget.isShop || widget.isGrocery,
                          isFood: widget.isFood,
                          width: widget.storeCorner?.itemWidth ?? 170,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // View Store Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.storeCorner!.viewMoreButtonWidth == 'full' ? Dimensions.paddingSizeSmall : 0),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'store')),
                child: Container(
                  width: widget.storeCorner!.viewMoreButtonWidth == 'full' ? double.infinity : 200,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.storeCorner!.viewMoreButtonText != null && widget.storeCorner!.viewMoreButtonText!.isNotEmpty ? (widget.storeCorner!.viewMoreButtonText!.tr) : 'view_more'.tr, 
                    style: robotoBold.copyWith(
                      color: btnColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    ),
  );
}
}
