import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_product_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/services/global_shopping_service_interface.dart';

class GlobalBrowseController extends GetxController implements GetxService {
  final GlobalShoppingServiceInterface service;

  GlobalBrowseController({required this.service});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isImageSearching = false;
  bool get isImageSearching => _isImageSearching;

  String _selectedSource = 'shein'; // shein, aliexpress, cj
  String get selectedSource => _selectedSource;

  List<GlobalProductModel>? _products;
  List<GlobalProductModel>? get products => _products;

  GlobalProductModel? _productDetails;
  GlobalProductModel? get productDetails => _productDetails;

  int _page = 1;
  int get page => _page;

  bool _isPaginateLoading = false;
  bool get isPaginateLoading => _isPaginateLoading;

  bool _offsetError = false;
  bool get offsetError => _offsetError;

  void setSource(String source) {
    _selectedSource = source;
    _products = null;
    _page = 1;
    _offsetError = false;
    update();
  }

  Future<void> search(String query, {bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_isPaginateLoading || _isLoading || _offsetError) return;
      _isPaginateLoading = true;
      update();
      try {
        List<GlobalProductModel>? moreProducts = await service.searchProducts(_selectedSource, query, _page + 1);
        if (moreProducts != null && moreProducts.isNotEmpty) {
          _products ??= [];
          _products!.addAll(moreProducts);
          _page++;
        } else {
          _offsetError = true;
        }
      } catch (e) {
        _offsetError = true;
      }
      _isPaginateLoading = false;
      update();
    } else {
      _isLoading = true;
      _products = null;
      _page = 1;
      _offsetError = false;
      update();

      try {
        _products = await service.searchProducts(_selectedSource, query, _page);
      } catch (e) {
        _products = [];
      }

      _isLoading = false;
      update();
    }
  }

  Future<void> searchByImage(String imageUrl) async {
    _isImageSearching = true;
    _isLoading = true;
    _products = null;
    _page = 1;
    _offsetError = false;
    update();

    try {
      _products = await service.searchProductsByImage(_selectedSource, imageUrl);
    } catch (e) {
      _products = [];
    }

    _isImageSearching = false;
    _isLoading = false;
    update();
  }

  /// Called by the UI when it directly processes the multipart upload response.
  void setImageSearching(bool value) {
    _isImageSearching = value;
    _isLoading = value;
    if (value) _products = null;
    update();
  }

  /// Called by the UI to directly set products from a parsed JSON response.
  void setImageSearchResults(List<dynamic> rawList) {
    try {
      _products = rawList.map((p) => GlobalProductModel.fromJson(p as Map<String, dynamic>)).toList();
    } catch (_) {
      _products = [];
    }
    _isImageSearching = false;
    _isLoading = false;
    update();
  }

  Future<void> getDetails(String id) async {
    _isLoading = true;
    _productDetails = null;
    update();

    try {
      _productDetails = await service.getProductDetails(_selectedSource, id);
    } catch (e) {
      _productDetails = null;
    }

    _isLoading = false;
    update();
  }
}
