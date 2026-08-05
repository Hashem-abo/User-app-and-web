import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_browse_controller.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_cart_screen.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_product_detail_screen.dart';
import 'package:sixam_mart/features/global_shopping/widgets/global_product_card.dart';
import 'package:sixam_mart/features/global_shopping/widgets/source_selector_tab.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/home/widgets/module_sticky_delegate.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';

class GlobalHomeScreen extends StatefulWidget {
  const GlobalHomeScreen({super.key});

  @override
  State<GlobalHomeScreen> createState() => _GlobalHomeScreenState();
}

class _GlobalHomeScreenState extends State<GlobalHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategoryQuery = 'trending';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        final browseCtrl = Get.find<GlobalBrowseController>();
        if (!browseCtrl.isPaginateLoading && !browseCtrl.isLoading && !browseCtrl.offsetError) {
          browseCtrl.search(_selectedCategoryQuery, isLoadMore: true);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final splashCtrl = Get.find<SplashController>();
      if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
        final headers = Map<String, String>.from(Get.find<ApiClient>().getHeader());
        headers.remove(AppConstants.moduleId);
        splashCtrl.getModules(headers: headers, dataSource: DataSourceEnum.client);
      }
      Get.find<GlobalBrowseController>().search('trending');
      Get.find<GlobalCartController>().getCartList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Image search ───────────────────────────────────────────────

  Future<void> _pickAndSearchByImage(ImageSource imageSource) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: imageSource,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (pickedFile == null) return;

      final browseCtrl = Get.find<GlobalBrowseController>();
      browseCtrl.setImageSearching(true);

      Get.snackbar(
        '🔍 Visual Search',
        'Searching products by image…',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postMultipartData(
        '/api/v1/global-shopping/search-by-image',
        {'source': browseCtrl.selectedSource},
        [MultipartBody('image', pickedFile)],
      );

      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> data = response.body is List
            ? response.body as List<dynamic>
            : jsonDecode(response.body.toString());
        browseCtrl.setImageSearchResults(data);
      } else {
        browseCtrl.setImageSearching(false);
        Get.snackbar('Error', 'Image search failed. Try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.find<GlobalBrowseController>().setImageSearching(false);
      Get.snackbar('Error', 'Could not process image.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void _showImageSearchSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('📷', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('Search by Image', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ]),
            const SizedBox(height: 6),
            Text(
              'Take a photo or pick from gallery to find similar products.',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: _ImageSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF6C63FF),
                  onTap: () => _pickAndSearchByImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ImageSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF43B89C),
                  onTap: () => _pickAndSearchByImage(ImageSource.gallery),
                ),
              ),
            ]),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getCategories(String source) {
    if (source == 'shein') {
      return [
        {'name': 'All', 'query': 'trending', 'icon': '✨'},
        {'name': 'Dresses', 'query': 'dress', 'icon': '👗'},
        {'name': 'T-Shirts', 'query': 't-shirt', 'icon': '👕'},
        {'name': 'Shoes', 'query': 'shoes', 'icon': '👟'},
        {'name': 'Bags', 'query': 'bag', 'icon': '👜'},
        {'name': 'Accessories', 'query': 'accessories', 'icon': '🕶️'},
      ];
    } else if (source == 'aliexpress') {
      return [
        {'name': 'All', 'query': 'trending', 'icon': '✨'},
        {'name': 'Phones', 'query': 'phone', 'icon': '📱'},
        {'name': 'Earphones', 'query': 'earphone', 'icon': '🎧'},
        {'name': 'Smart Watches', 'query': 'smart watch', 'icon': '⌚'},
        {'name': 'Gadgets', 'query': 'gadget', 'icon': '🔌'},
        {'name': 'Toys', 'query': 'toy', 'icon': '🧸'},
      ];
    } else {
      return [
        {'name': 'All', 'query': 'trending', 'icon': '✨'},
        {'name': 'Electronics', 'query': 'electronics', 'icon': '💻'},
        {'name': 'Apparel', 'query': 'apparel', 'icon': '👚'},
        {'name': 'Jewelry', 'query': 'jewelry', 'icon': '💍'},
        {'name': 'Home', 'query': 'home', 'icon': '🏠'},
        {'name': 'Fitness', 'query': 'fitness', 'icon': '🏋️'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalBrowseController>(builder: (browseCtrl) {
      return GetBuilder<GlobalCartController>(builder: (cartCtrl) {
        return GetBuilder<SplashController>(builder: (splashCtrl) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ModuleStickyDelegate(
                    splashController: splashCtrl,
                    expandedHeight: 115,
                    collapsedHeight: 60,
                    paddingTop: MediaQuery.of(context).padding.top,
                    searchBarHeight: 130,
                    searchBar: Column(
                      children: [
                        SourceSelectorTab(
                          selectedSource: browseCtrl.selectedSource,
                          onSourceChanged: (src) {
                            browseCtrl.setSource(src);
                            setState(() {
                              _selectedCategoryQuery = 'trending';
                              _searchController.clear();
                            });
                            browseCtrl.search('trending');
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault, 0,
                            Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'ابحث عن المنتجات',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _selectedCategoryQuery = 'trending';
                                              });
                                              browseCtrl.search('trending');
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Theme.of(context).cardColor,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      _selectedCategoryQuery = '';
                                    });
                                    browseCtrl.search(value.isNotEmpty ? value : 'trending');
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ── Image Search Camera Button ──
                              Tooltip(
                                message: 'Search by image',
                                child: InkWell(
                                  onTap: _showImageSearchSheet,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6C63FF), Color(0xFF43B89C)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6C63FF).withOpacity(0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: browseCtrl.isImageSearching
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_enhance_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                        child: Text(
                          'Popular Categories',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          itemCount: _getCategories(browseCtrl.selectedSource).length,
                          itemBuilder: (context, catIndex) {
                            final cat = _getCategories(browseCtrl.selectedSource)[catIndex];
                            bool isSelected = _selectedCategoryQuery == cat['query'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryQuery = cat['query']!;
                                    _searchController.text = cat['name'] == 'All' ? '' : cat['name']!;
                                  });
                                  browseCtrl.search(cat['query']!);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        cat['name']!,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
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
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: browseCtrl.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 80.0),
                            child: CustomLoaderWidget(),
                          ),
                        )
                      : (browseCtrl.products == null || browseCtrl.products!.isEmpty)
                          ? NoDataScreen(text: 'no_data_found'.tr)
                          : Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              child: Column(
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.68,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: browseCtrl.products!.length,
                                    itemBuilder: (context, index) {
                                      final product = browseCtrl.products![index];
                                      return GlobalProductCard(
                                        product: product,
                                        onTap: () {
                                          if (!AuthHelper.isLoggedIn()) {
                                            Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                            showCustomSnackBar('you_are_not_logged_in'.tr);
                                          } else {
                                            Get.to(
                                              () => GlobalProductDetailScreen(product: product),
                                              transition: Transition.rightToLeft,
                                            );
                                          }
                                        },
                                        onAddToCart: () async {
                                          if (!AuthHelper.isLoggedIn()) {
                                            Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                            showCustomSnackBar('you_are_not_logged_in'.tr);
                                            return;
                                          }
                                          bool added = await cartCtrl.addToCart(
                                            product.source ?? 'shein',
                                            product.id ?? '',
                                            1,
                                            '',
                                          );
                                          Get.snackbar(
                                            added ? 'Added to Cart' : 'Error',
                                            added ? '${product.title ?? 'Product'} added!' : 'Could not add to cart.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: added ? Colors.green : Colors.red,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 2),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if (browseCtrl.isPaginateLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                                      child: Center(child: CustomLoaderWidget()),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          );
        });
      });
    });
  }
}

/// Small button card used inside the image-search bottom sheet.
class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
