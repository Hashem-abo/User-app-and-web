import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/item/screens/item_details_screen.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'dart:async';

class ReelsPage extends StatefulWidget {
  final String videoUrl;
  final Item item;

  const ReelsPage({super.key, required this.videoUrl, required this.item});

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late PageController _pageController;
  final List<Item> _videoItems = [];
  int _categoryOffset = 1;
  int _storeOffset = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_scrollListener);
    _videoItems.add(widget.item);

    _loadVideoItems();
  }

  void _scrollListener() {
    if (_pageController.position.pixels >= _pageController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMoreVideoItems();
    }
  }

  void _loadVideoItems() async {
    ItemController itemController = Get.find<ItemController>();
    
    // Initial collection from what's already in memory
    _collectVideoItems(itemController);

    // Try to fetch more if we have few videos
    try {
      // Fetch from the same category
      var res = await itemController.itemServiceInterface.getPopularItemList(
        type: 'all', 
        source: DataSourceEnum.client, 
        offset: 1, 
        categoryIds: [widget.item.categoryId ?? 0], 
        moduleId: widget.item.moduleId ?? 0,
      );

      if (res != null && res.items != null) {
        _addItemsIfHasVideo(res.items!);
      }

      // If still few, fetch from parent category
      if (_videoItems.length < 3) {
        int parentCategoryId = (widget.item.categoryIds != null && widget.item.categoryIds!.isNotEmpty) 
            ? widget.item.categoryIds![0].id! : 0;
        if (parentCategoryId != 0) {
          var resParent = await itemController.itemServiceInterface.getPopularItemList(
            type: 'all', 
            source: DataSourceEnum.client, 
            offset: 1, 
            categoryIds: [parentCategoryId], 
            moduleId: widget.item.moduleId ?? 0,
          );
          if (resParent != null && resParent.items != null) {
            _addItemsIfHasVideo(resParent.items!);
          }
        }
      }

      // If still few, fetch from the same store
      if (_videoItems.length < 4 && widget.item.storeId != null && Get.isRegistered<StoreController>()) {
        try {
          var storeRes = await Get.find<StoreController>().storeServiceInterface.getStoreItemList(
            storeID: widget.item.storeId,
            offset: 1,
            type: 'all',
          );
          if (storeRes != null && storeRes.items != null) {
            _addItemsIfHasVideo(storeRes.items!);
          }
        } catch (e) {
          debugPrint('Reels store fetch error: $e');
        }
      }
    } catch (e) {
      debugPrint('Reels local fetch error: $e');
    }
  }

  void _loadMoreVideoItems() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    try {
      ItemController itemController = Get.find<ItemController>();
      List<Item> newFetchedItems = [];

      // 1. Fetch more from same category
      _categoryOffset++;
      var res = await itemController.itemServiceInterface.getPopularItemList(
        type: 'all', 
        source: DataSourceEnum.client, 
        offset: _categoryOffset, 
        categoryIds: [widget.item.categoryId ?? 0], 
        moduleId: widget.item.moduleId ?? 0,
      );
      if (res != null && res.items != null && res.items!.isNotEmpty) {
        newFetchedItems.addAll(res.items!);
      }

      // 2. Fetch more from same store
      if (widget.item.storeId != null && Get.isRegistered<StoreController>()) {
        _storeOffset++;
        try {
          var storeRes = await Get.find<StoreController>().storeServiceInterface.getStoreItemList(
            storeID: widget.item.storeId,
            offset: _storeOffset,
            type: 'all',
          );
          if (storeRes != null && storeRes.items != null && storeRes.items!.isNotEmpty) {
            newFetchedItems.addAll(storeRes.items!);
          }
        } catch (e) {
          debugPrint('Reels load more store fetch error: $e');
        }
      }

      if (newFetchedItems.isNotEmpty) {
        _addItemsIfHasVideo(newFetchedItems);
      }
    } catch (e) {
      debugPrint('Error loading more reels: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  bool _isEligible(Item item) {
    if (item.videoFullUrl == null || item.videoFullUrl!.isEmpty) {
      return false;
    }
    if (item.id == widget.item.id) {
      return false;
    }

    // A. Same store
    if (item.storeId != null && item.storeId == widget.item.storeId) {
      return true;
    }

    // B. Same category
    if (item.categoryId != null && item.categoryId == widget.item.categoryId) {
      return true;
    }

    // Check parent/nested category IDs
    if (widget.item.categoryIds != null && item.categoryIds != null) {
      for (var cat in item.categoryIds!) {
        if (widget.item.categoryIds!.any((element) => element.id == cat.id)) {
          return true;
        }
      }
    }

    // C. Is similar product (in item_controller lists)
    ItemController itemController = Get.find<ItemController>();
    if (itemController.similarProductList != null && itemController.similarProductList!.any((element) => element.id == item.id)) {
      return true;
    }
    if (itemController.sameTypeProductList != null && itemController.sameTypeProductList!.any((element) => element.id == item.id)) {
      return true;
    }
    if (itemController.similarLocalProductList != null && itemController.similarLocalProductList!.any((element) => element.id == item.id)) {
      return true;
    }

    return false;
  }

  void _addItemsIfHasVideo(List<Item> items) {
    if (mounted) {
      setState(() {
        for (var item in items) {
          if (_isEligible(item)) {
            if (!_videoItems.any((element) => element.id == item.id)) {
              _videoItems.add(item);
            }
          }
        }
      });
    }
  }

  void _collectVideoItems(ItemController itemController) {
    List<Item> allAvailableItems = [];
    if (itemController.similarProductList != null) allAvailableItems.addAll(itemController.similarProductList!);
    if (itemController.sameTypeProductList != null) allAvailableItems.addAll(itemController.sameTypeProductList!);
    if (itemController.similarLocalProductList != null) allAvailableItems.addAll(itemController.similarLocalProductList!);
    if (itemController.popularItemList != null) allAvailableItems.addAll(itemController.popularItemList!);
    if (itemController.nationalAggregatedItemList != null) allAvailableItems.addAll(itemController.nationalAggregatedItemList!);
    if (itemController.reviewedItemList != null) allAvailableItems.addAll(itemController.reviewedItemList!);
    if (itemController.discountedItemList != null) allAvailableItems.addAll(itemController.discountedItemList!);
    if (itemController.storeProductList != null) allAvailableItems.addAll(itemController.storeProductList!);

    bool added = false;
    for (var similarItem in allAvailableItems) {
      if (_isEligible(similarItem)) {
        if (!_videoItems.any((element) => element.id == similarItem.id)) {
          _videoItems.add(similarItem);
          added = true;
        }
      }
    }
    if (added && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoItems.length,
        itemBuilder: (context, index) {
          return VideoPlayerItem(videoUrl: _videoItems[index].videoFullUrl!, item: _videoItems[index]);
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final Item item;

  const VideoPlayerItem({super.key, required this.videoUrl, required this.item});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  bool _initialized = false;
  int _currentStatusIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
      });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentStatusIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (_videoPlayerController.value.isPlaying) {
              _videoPlayerController.pause();
            } else {
              _videoPlayerController.play();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: _initialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),
        
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
        ),

        Positioned(
          bottom: 20,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Builder(
                builder: (context) {
                  List<Map<String, dynamic>> statusList = [];

                  if (widget.item.storeName?.isNotEmpty ?? false) {
                    statusList.add({'text': widget.item.storeName!, 'icon': Icons.store, 'color': Colors.blue});
                  }

                  bool isStoreOpen = DateConverter.isAvailable(widget.item.availableTimeStarts, widget.item.availableTimeEnds);
                  
                  statusList.add({
                    'text': isStoreOpen ? 'open'.tr : 'closed'.tr, 
                    'icon': Icons.circle, 
                    'color': isStoreOpen ? Colors.green : Colors.red
                  });

                  if (widget.item.deliveryTime?.isNotEmpty ?? false) {
                    statusList.add({'text': widget.item.deliveryTime!.replaceAll('min', 'min'.tr), 'icon': Icons.bolt, 'color': Colors.orange});
                  }

                  if (widget.item.discount != null && widget.item.discount! > 0) {
                    statusList.add({
                      'text': widget.item.discountType == 'percent' ? '${widget.item.discount!}% ${'off'.tr}' : '${PriceConverter.convertPrice(widget.item.discount!)} ${'off'.tr}', 
                      'icon': Icons.local_offer, 
                      'color': Colors.pinkAccent
                    });
                    statusList.add({
                      'text': 'special_offer'.tr, 
                      'icon': Icons.stars_rounded, 
                      'color': Colors.amber,
                    });
                  }

                  if(widget.item.orderCount != null && widget.item.orderCount! > 0) {
                    statusList.add({
                      'text': '${widget.item.orderCount} ${'orders'.tr}', 
                      'icon': Icons.shopping_bag_outlined, 
                      'color': Colors.deepPurpleAccent, 
                    });
                  }

                  if(widget.item.itemViewCount != null && widget.item.itemViewCount! > 0) {
                    statusList.add({
                      'text': '${widget.item.itemViewCount} ${'views'.tr}', 
                      'icon': Icons.visibility_outlined, 
                      'color': Colors.teal, 
                    });
                  }

                  if(widget.item.wishlistCount != null && widget.item.wishlistCount! > 0) {
                    statusList.add({
                      'text': '${widget.item.wishlistCount} ${'favorites'.tr}', 
                      'icon': Icons.favorite_border, 
                      'color': Colors.redAccent, 
                    });
                  }

                  if (statusList.isEmpty) return const SizedBox();

                  return Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.8),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentStatusIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (statusList[_currentStatusIndex % statusList.length]['color'] as Color).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (statusList[_currentStatusIndex % statusList.length]['color'] as Color).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusList[_currentStatusIndex % statusList.length]['icon'],
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible( 
                              child: Text(
                                statusList[_currentStatusIndex % statusList.length]['text'],
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE0E0),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill, color: Colors.red, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'watch_videos_to_buy_great_products'.tr,
                            style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.name ?? '',
                                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(widget.item.price, discount: widget.item.discount, discountType: widget.item.discountType),
                                      style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    if (widget.item.discount! > 0)
                                      Text(
                                        PriceConverter.convertPrice(widget.item.price),
                                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                                      ),
                                    const SizedBox(width: 10),
                                    if (widget.item.discount! > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                                        child: Text(
                                          '-${widget.item.discount}${widget.item.discountType == 'percent' ? '%' : ''}',
                                          style: robotoBold.copyWith(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () {
                                    _videoPlayerController.pause();
                                    Get.bottomSheet(
                                      ItemBottomSheet(item: widget.item, isCampaign: false, itemId: widget.item.id!),
                                      backgroundColor: Colors.transparent, isScrollControlled: true,
                                    ).then((_) {
                                      _videoPlayerController.play();
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'add_to_cart'.tr,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImage(
                              image: widget.item.imageFullUrl!,
                              height: 110, width: 110, fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
