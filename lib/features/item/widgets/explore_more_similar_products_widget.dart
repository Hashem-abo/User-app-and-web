import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ExploreMoreSimilarProductsWidget extends StatefulWidget {
  final Item item;
  final bool isFood;
  final bool isShop;

  const ExploreMoreSimilarProductsWidget({
    super.key,
    required this.item,
    required this.isFood,
    required this.isShop,
  });

  @override
  State<ExploreMoreSimilarProductsWidget> createState() => _ExploreMoreSimilarProductsWidgetState();
}

class _ExploreMoreSimilarProductsWidgetState extends State<ExploreMoreSimilarProductsWidget> {
  final ScrollController _tabScrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  final List<int> _tabIds = [];
  final List<int> _loadedTabIds = [];
  final Map<int, GlobalKey> _categoryKeys = {};
  bool _isFetchingNextCategory = false;
  bool _isScrollingToCategory = false;

  @override
  void initState() {
    super.initState();
  }

  int _getItemModuleId() {
    if (widget.item.moduleId != null && widget.item.moduleId! > 0) {
      return widget.item.moduleId!;
    }
    if (widget.item.storeDetails != null && widget.item.storeDetails!['module_id'] != null) {
      int? mod = int.tryParse(widget.item.storeDetails!['module_id'].toString());
      if (mod != null && mod > 0) return mod;
    }
    return Get.find<SplashController>().module?.id ?? 0;
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollToTabOnly(int index) {
    if (_tabScrollController.hasClients) {
      double offset = index * 100.0; // Approx width of each tab
      if (offset > _tabScrollController.position.maxScrollExtent) {
        offset = _tabScrollController.position.maxScrollExtent;
      }
      _tabScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onTabSelected(int index, int categoryId, ItemController itemController) async {
    setState(() {
      _selectedCategoryIndex = index;
      _isScrollingToCategory = true;
    });
    
    _scrollToTabOnly(index);

    // Load any unloaded intermediate categories
    if (!_loadedTabIds.contains(categoryId)) {
      for (int i = _loadedTabIds.length; i <= index; i++) {
        int catId = _tabIds[i];
        if (!_loadedTabIds.contains(catId)) {
          setState(() {
            _loadedTabIds.add(catId);
          });
          await itemController.getExploreMoreItems(catId, _getItemModuleId());
        }
      }
    }

    // Scroll to the selected category header
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _categoryKeys[categoryId];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          alignment: 0.0,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isScrollingToCategory = false;
            });
          });
        });
      } else {
        setState(() {
          _isScrollingToCategory = false;
        });
      }
    });
  }

  void _onScrollReachedEnd(ItemController itemController) {
    if (_isFetchingNextCategory) return;

    int nextIndex = _loadedTabIds.length;
    if (nextIndex < _tabIds.length) {
      int nextCategoryId = _tabIds[nextIndex];
      
      setState(() {
        _isFetchingNextCategory = true;
        _loadedTabIds.add(nextCategoryId);
      });

      itemController.getExploreMoreItems(nextCategoryId, _getItemModuleId()).then((_) {
        setState(() {
          _isFetchingNextCategory = false;
        });
      });
    }
  }

  void _trackActiveCategory() {
    if (_isScrollingToCategory) return;
    
    double appBarHeight = 90.0; // height of the sticky tab header
    int activeIndex = -1;

    for (int i = 0; i < _loadedTabIds.length; i++) {
      int categoryId = _loadedTabIds[i];
      final key = _categoryKeys[categoryId];
      if (key == null || key.currentContext == null) continue;
      
      final RenderBox? renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy < appBarHeight + 120 && position.dy > 0) {
          activeIndex = i;
          break;
        }
      }
    }

    if (activeIndex != -1 && activeIndex != _selectedCategoryIndex) {
      setState(() {
        _selectedCategoryIndex = activeIndex;
      });
      _scrollToTabOnly(activeIndex);
    }
  }

  Widget _buildCategoryIcon(int index, int categoryId) {
    IconData icon = index == 1 ? Icons.trending_up 
                    : index == 2 ? Icons.recommend_outlined 
                    : widget.isFood ? Icons.fastfood_outlined : Icons.category_outlined;
                    
    if (index == 0) {
      return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
        ),
        alignment: Alignment.center,
        child: const Text('🔥', style: TextStyle(fontSize: 16)),
      );
    }
    
    // Find category image
    String? categoryImage = Get.find<ItemController>().exploreMoreCategories?.firstWhereOrNull((cat) => cat.id == categoryId)?.imageFullUrl ?? 
        Get.find<ItemController>().exploreMoreCategories?.firstWhereOrNull((cat) => cat.id == categoryId)?.image;
        
    if (categoryImage != null && categoryImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomImage(
          image: categoryImage.startsWith('http') ? categoryImage : '${Get.find<SplashController>().configModel?.baseUrls?.categoryImageUrl}/$categoryImage',
          height: 30, width: 30, fit: BoxFit.cover,
        ),
      );
    }
    
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Theme.of(context).primaryColor, size: 16),
    );
  }

  List<Widget> _buildCategorySlivers(ItemController itemController) {
    List<Widget> slivers = [];
    
    for (int i = 0; i < _loadedTabIds.length; i++) {
      int categoryId = _loadedTabIds[i];
      List<Item>? items = itemController.exploreMoreCache[categoryId];
      
      // 1. Add Category Header separator row
      slivers.add(
        SliverToBoxAdapter(
          child: Container(
            key: _categoryKeys[categoryId] ??= GlobalKey(),
            width: double.infinity,
            margin: const EdgeInsets.only(
              top: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeSmall,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildCategoryIcon(i, categoryId),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    i == 0 
                        ? 'just_for_you'.tr 
                        : (itemController.exploreMoreCategories?.firstWhereOrNull((cat) => cat.id == categoryId)?.name ?? ''),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                Container(
                  height: 4,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 2. Add Category items grid or loading/empty state
      if (items == null) {
        slivers.add(
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (items.isEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(
                  'no_data_found'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                ),
              ),
            ),
          ),
        );
      } else {
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            sliver: SliverGrid.builder(
              key: PageStorageKey<String>('explore_grid_$categoryId'),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: items[index], 
                  isFood: widget.isFood, 
                  isShop: widget.isShop, 
                  isPopularItem: true, 
                  index: index,
                  width: double.infinity,
                );
              },
            ),
          ),
        );
      }
    }

    if (_isFetchingNextCategory) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    } else {
      slivers.add(
        const SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      id: 'explore_more',
      builder: (itemController) {
        List<String> tabNames = ['just_for_you'.tr];
        List<int> currentTabIds = [0];
        List<String?> tabImages = [null];
        
        if (itemController.exploreMoreCategories != null && itemController.exploreMoreCategories!.isNotEmpty) {
          var itemCategory = itemController.exploreMoreCategories!.firstWhereOrNull((cat) => cat.id == widget.item.categoryId);
          if (itemCategory != null) {
            tabNames.add(itemCategory.name ?? '');
            currentTabIds.add(itemCategory.id!);
            tabImages.add(itemCategory.imageFullUrl ?? itemCategory.image);
          }
          for (var cat in itemController.exploreMoreCategories!) {
            if (cat.id != widget.item.categoryId) {
              tabNames.add(cat.name ?? '');
              currentTabIds.add(cat.id!);
              tabImages.add(cat.imageFullUrl ?? cat.image);
            }
          }
        }

        bool tabsChanged = false;
        if (_tabIds.length != currentTabIds.length) {
          tabsChanged = true;
        } else {
          for (int i = 0; i < _tabIds.length; i++) {
            if (_tabIds[i] != currentTabIds[i]) {
              tabsChanged = true;
              break;
            }
          }
        }
        
        if (tabsChanged) {
          _tabIds.clear();
          _tabIds.addAll(currentTabIds);
        }

        if (_tabIds.isNotEmpty && _loadedTabIds.isEmpty) {
          _loadedTabIds.add(_tabIds[0]);
        }
        
        // Initial data fetch if cache is empty
        if (_tabIds.isNotEmpty && (itemController.exploreMoreCache[_tabIds[0]] == null || itemController.exploreMoreCache[_tabIds[0]]!.isEmpty)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (itemController.exploreMoreCache.isEmpty) {
              itemController.getExploreMoreItems(_tabIds[0], _getItemModuleId());
            }
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.axis == Axis.vertical) {
                _trackActiveCategory();
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  _onScrollReachedEnd(itemController);
                }
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Sticky Tab Bar Background
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    height: 90 + (ResponsiveHelper.isDesktop(context) ? 0.0 : 50.0),
                    paddingTop: ResponsiveHelper.isDesktop(context) ? 0.0 : 50.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0.0 : 50.0),
                        Container(
                          height: 90,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('explore_more'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Expanded(
                                child: ListView.builder(
                                  controller: _tabScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tabNames.length,
                                  itemBuilder: (context, index) {
                                    bool isSelected = index == _selectedCategoryIndex;
                                    IconData icon = index == 1 ? Icons.trending_up 
                                                    : index == 2 ? Icons.recommend_outlined 
                                                    : widget.isFood ? Icons.fastfood_outlined : Icons.category_outlined;
                                    return GestureDetector(
                                      onTap: () => _onTabSelected(index, _tabIds[index], itemController),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              index == 0 
                                                  ? Container(
                                                      height: 36,
                                                      width: 36,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        color: Theme.of(context).cardColor,
                                                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: const Text('🔥', style: TextStyle(fontSize: 16)),
                                                    )
                                                  : (tabImages[index] != null && tabImages[index]!.isNotEmpty) 
                                                    ? Container(
                                                        height: 36,
                                                        width: 36,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: Theme.of(context).cardColor,
                                                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 3, spreadRadius: 1)],
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(3),
                                                          child: Transform(
                                                            transform: Matrix4.identity()
                                                              ..setEntry(3, 2, 0.003)
                                                              ..rotateY(0.15)
                                                              ..rotateX(-0.08),
                                                            alignment: Alignment.center,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(8),
                                                                boxShadow: [
                                                                  BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(4, 6)),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(8),
                                                                child: CustomImage(
                                                                  image: tabImages[index]!.startsWith('http') ? tabImages[index]! : '${Get.find<SplashController>().configModel?.baseUrls?.categoryImageUrl}/${tabImages[index]}',
                                                                  height: 28, width: 28, fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    : Container(
                                                        height: 36,
                                                        width: 36,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: Theme.of(context).cardColor,
                                                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color, size: 16),
                                                      ),
                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                              Text(
                                                tabNames[index],
                                                style: robotoBold.copyWith(
                                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_tabIds.isEmpty)
                  const SliverFillRemaining(
                    child: ExploreMoreShimmerGrid(),
                  )
                else
                  ..._buildCategorySlivers(itemController),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final double paddingTop;

  _StickyTabBarDelegate({required this.child, required this.height, required this.paddingTop});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ExploreMoreShimmerGrid extends StatelessWidget {
  const ExploreMoreShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.45,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusLarge),
                          topRight: Radius.circular(Dimensions.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 15, width: double.infinity, color: Colors.grey[300]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Container(height: 10, width: 50, color: Colors.grey[300]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(height: 15, width: 80, color: Colors.grey[300]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
