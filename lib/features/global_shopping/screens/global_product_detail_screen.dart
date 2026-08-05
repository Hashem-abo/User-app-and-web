import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_browse_controller.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_product_model.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_cart_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/contact_share/screens/contact_share_sheet.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class GlobalProductDetailScreen extends StatefulWidget {
  final GlobalProductModel product;

  const GlobalProductDetailScreen({super.key, required this.product});

  @override
  State<GlobalProductDetailScreen> createState() => _GlobalProductDetailScreenState();
}

class _GlobalProductDetailScreenState extends State<GlobalProductDetailScreen> {
  int _quantity = 1;
  String? _selectedVid;
  int _imageIndex = 0;
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<GlobalBrowseController>().getDetails(widget.product.id ?? '');
    });
  }

  void _scrollListener() {
    bool isScrolled = _scrollController.offset >= 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _glassButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isScrolled ? Colors.transparent : Theme.of(context).cardColor.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context, String shareUrl, String shareText) {
    if (AuthHelper.isLoggedIn()) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => ContactShareSheet(
          shareableType: 'item',
          shareableId: int.tryParse(widget.product.id ?? '') ?? 0,
          shareableName: widget.product.title ?? '',
          shareUrl: shareUrl,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'share_product'.tr == 'share_product' ? 'مشاركة المنتج' : 'share_product'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            Text(
              'share_this_product_with_others'.tr == 'share_this_product_with_others' ? 'شارك هذا المنتج مع الآخرين' : 'share_this_product_with_others'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                showCustomSnackBar('link_copied'.tr == 'link_copied' ? 'تم نسخ الرابط' : 'link_copied'.tr, isError: false);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                ),
                child: Row(children: [
                  Expanded(child: Text('copy_product_link'.tr == 'copy_product_link' ? 'نسخ رابط المنتج' : 'copy_product_link'.tr, style: robotoMedium)),
                  const Icon(Icons.copy, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            InkWell(
              onTap: () {
                Share.share(shareText);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                ),
                child: Row(children: [
                  Expanded(child: Text('share_via_apps'.tr == 'share_via_apps' ? 'مشاركة عبر التطبيقات' : 'share_via_apps'.tr, style: robotoMedium)),
                  const Icon(Icons.send, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalBrowseController>(builder: (browseCtrl) {
      final product = browseCtrl.productDetails ?? widget.product;
      final images = product.images ?? [];
      final variants = product.variants ?? [];
      final double price = product.price ?? 0;
      final double originalPrice = product.originalPrice ?? 0;
      final bool isLoading = browseCtrl.isLoading;
      final bool hasDiscount = originalPrice > 0 && price != originalPrice;

      return GetBuilder<GlobalCartController>(builder: (cartCtrl) {
        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: Center(
              child: _glassButton(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            backgroundColor: _isScrolled ? Theme.of(context).cardColor : Colors.transparent,
            elevation: 0,
            title: AnimatedOpacity(
              opacity: _isScrolled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                product.title ?? 'Product Details',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            centerTitle: true,
            actions: [
              _glassButton(
                onTap: () {
                  String shareUrl = product.url ?? '';
                  if (AuthHelper.isLoggedIn()) {
                    String refCode = Get.find<ProfileController>().userInfoModel?.refCode ?? '';
                    if (refCode.isNotEmpty) {
                      shareUrl = shareUrl.contains('?') ? '$shareUrl&ref=$refCode' : '$shareUrl?ref=$refCode';
                    }
                  }
                  String shareText = '${product.title ?? 'Product'} \n$shareUrl';
                  _showShareBottomSheet(context, shareUrl, shareText);
                },
                child: Icon(Icons.send_outlined, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              _glassButton(
                onTap: () => Get.to(() => const GlobalCartScreen()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                    if (cartCtrl.cartList.isNotEmpty)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            '${cartCtrl.cartList.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: isLoading && product.id == widget.product.id
                ? const CustomLoaderWidget()
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        if (images.isNotEmpty)
                          Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.width,
                                child: PageView.builder(
                                  controller: _imagePageController,
                                  itemCount: images.length,
                                  onPageChanged: (i) => setState(() => _imageIndex = i),
                                  itemBuilder: (_, i) => CustomImage(
                                    image: images[i],
                                    fit: BoxFit.cover,
                                    placeholder: Images.defultImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              if (images.length > 1)
                                Positioned(
                                  bottom: 15,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      images.length,
                                      (i) => Container(
                                        width: _imageIndex == i ? 16 : 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        decoration: BoxDecoration(
                                          color: _imageIndex == i ? Theme.of(context).primaryColor : Colors.white.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 12 + MediaQuery.of(context).padding.top + 50,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _sourceColor(product.source),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _sourceLabel(product.source),
                                    style: robotoMedium.copyWith(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            height: MediaQuery.of(context).size.width,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.grey)),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              // Price section matching details screen
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${(price * _quantity).toStringAsFixed(2)}',
                                    style: robotoBlack.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 28,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (hasDiscount)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '\$${(originalPrice * _quantity).toStringAsFixed(2)}',
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).disabledColor.withValues(alpha: 0.6),
                                          fontSize: Dimensions.fontSizeDefault,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              // Title
                              Text(
                                product.title ?? 'Unknown Product',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                              ),

                              if (product.category != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Category: ${product.category!}',
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),

                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.local_shipping, size: 18, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Shipping: \$4.50 Flat Rate',
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 18, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Est. Delivery: 7-15 business days',
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              if (product.url != null && product.url!.isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    if (await canLaunchUrlString(product.url!)) {
                                      await launchUrlString(product.url!, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.open_in_new, size: 16, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        'View Product on Original Website',
                                        style: robotoMedium.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const Divider(height: 24),

                              // Description Section
                              if (product.description != null && product.description!.isNotEmpty) ...[
                                Text('description'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  product.description!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                                  ),
                                  maxLines: _isDescriptionExpanded ? null : 3,
                                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                                if (product.description!.length > 150)
                                  InkWell(
                                    onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Text(
                                        _isDescriptionExpanded ? 'show_less'.tr : 'show_more'.tr,
                                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                                      ),
                                    ),
                                  ),
                                const Divider(height: 24),
                              ],

                              // Variants Section
                              if (variants.isNotEmpty) ...[
                                Text('variant'.tr.isNotEmpty ? 'variant'.tr : 'Variant', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: variants.map((v) {
                                    final label = _variantLabel(v);
                                    final vid = _variantId(v);
                                    final bool selected = _selectedVid == vid;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedVid = vid),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                          border: Border.all(
                                            color: selected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: selected ? [] : [
                                            BoxShadow(
                                              color: Colors.grey.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          label,
                                          style: robotoRegular.copyWith(
                                            color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                            fontSize: Dimensions.fontSizeSmall,
                                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const Divider(height: 24),
                              ],

                              // Quantity row
                              Row(
                                children: [
                                  Text('quantity'.tr.isNotEmpty ? 'quantity'.tr : 'Quantity', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  const Spacer(),
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('$_quantity', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () => setState(() => _quantity++),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
            ),
            child: cartCtrl.isLoading
                ? const CustomLoaderWidget()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (!AuthHelper.isLoggedIn()) {
                        Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                        return;
                      }
                      bool added = await cartCtrl.addToCart(
                        product.source ?? 'shein',
                        product.id ?? '',
                        _quantity,
                        _selectedVid ?? '',
                      );
                      Get.snackbar(
                        added ? 'Added to Cart' : 'Error',
                        added ? '${product.title ?? 'Product'} added to cart!' : 'Could not add to cart.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: added ? Colors.green : Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    child: Text(
                      '${'add_to_cart'.tr} • \$${(price * _quantity).toStringAsFixed(2)}',
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
          ),
        );
      });
    });
  }

  String _variantLabel(ProductVariant v) {
    String label = v.name ?? (v.options?.isNotEmpty == true ? v.options!.first : '');
    String title = (widget.product.title ?? '').trim();
    if (title.isNotEmpty) {
      String cleanTitle = title.replaceAll('...', '').trim();
      if (cleanTitle.isNotEmpty) {
        String lowerLabel = label.toLowerCase();
        String lowerTitle = cleanTitle.toLowerCase();
        if (lowerLabel.startsWith(lowerTitle)) {
          label = label.substring(lowerTitle.length).trim();
        } else {
          label = label.replaceAll(RegExp(RegExp.escape(cleanTitle), caseSensitive: false), '').trim();
        }
      }
    }
    label = label.replaceAll(RegExp(r'^[-,\s]+|[-,\s]+$'), '');
    return label.isNotEmpty ? label : (v.name ?? '');
  }

  String _variantId(ProductVariant v) {
    return v.name ?? '';
  }

  Color _sourceColor(String? source) {
    switch (source) {
      case 'shein':
        return const Color(0xFFE91E63);
      case 'aliexpress':
        return const Color(0xFFFF6900);
      case 'cj':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  String _sourceLabel(String? source) {
    switch (source) {
      case 'shein':
        return 'SHEIN';
      case 'aliexpress':
        return 'AliExpress';
      case 'cj':
        return 'CJ Drop';
      default:
        return 'GLOBAL';
    }
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
