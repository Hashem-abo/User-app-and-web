import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/search/domain/services/search_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';

class CandidateStoreInfo {
  final int storeId;
  final String storeName;
  final int availableItemsCount;
  final List<String> availableKeywords;
  final List<String> missingKeywords;

  CandidateStoreInfo({
    required this.storeId,
    required this.storeName,
    required this.availableItemsCount,
    required this.availableKeywords,
    required this.missingKeywords,
  });
}

class SmartShoppingListController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;
  SmartShoppingListController({required this.searchServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<String> _quickSuggestions = [];
  List<String> get quickSuggestions => _quickSuggestions;

  bool _isSuggestionsLoading = false;
  bool get isSuggestionsLoading => _isSuggestionsLoading;

  String? _nearestStoreName;
  String? get nearestStoreName => _nearestStoreName;

  static const List<String> defaultFallbackSuggestions = [
    'طماطم',
    'تفاح',
    'حليب',
    'خبز',
    'بيض',
    'جبن',
    'أرز',
    'سكر',
    'شاي',
  ];

  List<String> _keywords = [];
  List<String> get keywords => _keywords;

  final Map<String, List<Item>> _rawResults = {};
  Map<String, List<Item>> _results = {};
  Map<String, List<Item>> get results => _results;

  final Map<String, bool> _keywordLoading = {};
  Map<String, bool> get keywordLoading => _keywordLoading;

  int? _selectedStoreId;
  int? get selectedStoreId => _selectedStoreId;

  String? _selectedStoreName;
  String? get selectedStoreName => _selectedStoreName;

  List<CandidateStoreInfo> _candidateStores = [];
  List<CandidateStoreInfo> get candidateStores => _candidateStores;

  String _rawInput = '';
  String get rawInput => _rawInput;

  int get availableCount => _keywords.where((kw) => (_results[kw] ?? []).isNotEmpty).length;
  int get missingCount => _keywords.length - availableCount;

  void setRawInput(String text) {
    _rawInput = text;
    update();
  }

  /// Parses text into distinct non-empty keywords with support for all delimiters:
  /// newlines, commas (English/Arabic), dashes, slashes, plus, pipes, bullet points, numbers, and conjunctions.
  List<String> parseKeywords(String text) {
    if (text.trim().isEmpty) return [];

    // Pre-processing: replace conjunctions like " و " or " and " or " & " with standard delimiter "\n"
    String normalized = text
        .replaceAll(RegExp(r'\s+و\s+'), '\n')
        .replaceAll(RegExp(r'\s+and\s+', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'\s*&\s*'), '\n');

    // Split by newlines, commas (English/Arabic/Chinese), semicolons, pipes, slashes, plus, or dashes with spaces
    List<String> tokens = normalized.split(RegExp(r'[\n\r,،，;؛|\/\\\+]+|\s+[-–—_]\s+|\s+•\s+|\s+\*\s+'));
    List<String> cleaned = [];

    for (var token in tokens) {
      String trimmed = token.trim();
      if (trimmed.isEmpty) continue;

      // Handle sub-token split if someone wrote "1- طماطم 2- تفاح" on the same line
      List<String> subTokens = trimmed.split(RegExp(r'(?<=\D)\s+(?=\d+[\.\-\)\s])'));

      for (var sub in subTokens) {
        String item = sub.trim();

        // 1. Remove leading numbering / bullets / symbols (e.g., "1.", "2-", "3)", "•", "-", "*", "١.", "٢-")
        item = item.replaceFirst(RegExp(r'^[\d٠-٩]+[\.\-\)\s:]*\s*'), '').trim();
        item = item.replaceFirst(RegExp(r'^[-–—*•◦▪▫#>\(\)\[\]]\s*'), '').trim();

        // 2. Remove leading Arabic "و" if it remained attached to the word (e.g. "وتفاح" -> "تفاح")
        if (item.startsWith('و') && item.length > 3 && !['ورق', 'ورد', 'ويفر', 'وجبة', 'وطني', 'وفير', 'وافل'].any((w) => item.startsWith(w))) {
          String withoutWaw = item.substring(1).trim();
          if (withoutWaw.isNotEmpty) {
            item = withoutWaw;
          }
        }

        // 3. Remove trailing punctuation
        item = item.replaceAll(RegExp(r'[\.\-\)\s:,،;؛]+$'), '').trim();

        // 4. Normalize multiple spaces into single space
        item = item.replaceAll(RegExp(r'\s+'), ' ');

        // Accept only meaningful words (length >= 2)
        if (item.length >= 2 && !cleaned.contains(item)) {
          cleaned.add(item);
        }
      }
    }

    return cleaned;
  }

  /// Execute search for all parsed keywords in parallel
  Future<void> searchList(String text) async {
    _rawInput = text;
    _keywords = parseKeywords(text);
    if (_keywords.isEmpty) return;

    _isLoading = true;
    _rawResults.clear();
    _results.clear();
    _keywordLoading.clear();
    _candidateStores.clear();
    _selectedStoreId = null;
    _selectedStoreName = null;

    for (var kw in _keywords) {
      _keywordLoading[kw] = true;
      _rawResults[kw] = [];
      _results[kw] = [];
    }
    update();

    // Perform queries in parallel
    await Future.wait(_keywords.map((kw) => _searchKeyword(kw)));

    _isLoading = false;
    _selectBestSingleStore();
    update();
  }

  Future<void> _searchKeyword(String keyword) async {
    try {
      Response response = await searchServiceInterface.getSearchData(keyword, false);
      if (response.statusCode == 200 && response.body != null) {
        ItemModel itemModel = ItemModel.fromJson(response.body);
        _rawResults[keyword] = itemModel.items ?? [];
      } else {
        _rawResults[keyword] = [];
      }
    } catch (e) {
      _rawResults[keyword] = [];
    } finally {
      _keywordLoading[keyword] = false;
    }
  }

  /// Evaluates all candidate stores and automatically locks onto the Single Best Store
  /// (the store that can fulfill the maximum number of items in a single basket).
  void _selectBestSingleStore() {
    if (_rawResults.isEmpty) {
      _results.clear();
      return;
    }

    // 1. Calculate store coverage: Map<storeId, Set<keyword>>
    Map<int, Set<String>> storeKeywordMap = {};
    Map<int, String> storeNames = {};

    for (var entry in _rawResults.entries) {
      String keyword = entry.key;
      List<Item> items = entry.value;
      for (var item in items) {
        if (item.storeId != null) {
          storeKeywordMap.putIfAbsent(item.storeId!, () => <String>{}).add(keyword);
          if (item.storeName != null && item.storeName!.isNotEmpty) {
            storeNames[item.storeId!] = item.storeName!;
          }
        }
      }
    }

    _candidateStores.clear();

    // If no stores found in results, fallback to raw items
    if (storeKeywordMap.isEmpty) {
      _results = Map.from(_rawResults);
      _selectedStoreId = null;
      _selectedStoreName = null;
      return;
    }

    // 2. Build candidate store list sorted by match count (descending)
    List<int> sortedStores = storeKeywordMap.keys.toList()
      ..sort((a, b) => storeKeywordMap[b]!.length.compareTo(storeKeywordMap[a]!.length));

    for (int storeId in sortedStores) {
      Set<String> matched = storeKeywordMap[storeId]!;
      List<String> missing = _keywords.where((kw) => !matched.contains(kw)).toList();

      _candidateStores.add(
        CandidateStoreInfo(
          storeId: storeId,
          storeName: storeNames[storeId] ?? 'Store #$storeId',
          availableItemsCount: matched.length,
          availableKeywords: matched.toList(),
          missingKeywords: missing,
        ),
      );
    }

    // 3. Set the top candidate as active store
    if (_candidateStores.isNotEmpty) {
      applyStoreFilter(_candidateStores.first.storeId, _candidateStores.first.storeName);
    }
  }

  /// Filters all results to strictly show items from ONE selected store.
  /// If the store doesn't have an item for a keyword, that keyword gets an empty list (Marked as Not Available).
  void applyStoreFilter(int storeId, String storeName) {
    _selectedStoreId = storeId;
    _selectedStoreName = storeName;

    Map<String, List<Item>> storeFilteredResults = {};
    for (String keyword in _keywords) {
      List<Item> storeItems = (_rawResults[keyword] ?? [])
          .where((item) => item.storeId == storeId)
          .toList();

      storeFilteredResults[keyword] = storeItems;
    }

    _results = storeFilteredResults;
    update();
  }

  /// Re-search a single keyword
  Future<void> retryKeyword(String keyword) async {
    _keywordLoading[keyword] = true;
    update();
    await _searchKeyword(keyword);
    _keywordLoading[keyword] = false;

    if (_selectedStoreId != null) {
      _results[keyword] = (_rawResults[keyword] ?? [])
          .where((item) => item.storeId == _selectedStoreId)
          .toList();
    } else {
      _results[keyword] = _rawResults[keyword] ?? [];
    }
    update();
  }

  /// Loads quick product suggestions dynamically from the closest store to the customer.
  Future<void> loadNearestStoreSuggestions({bool forceReload = false}) async {
    if (_quickSuggestions.isNotEmpty && !forceReload) {
      return;
    }

    _isSuggestionsLoading = true;
    update();

    try {
      if (!Get.isRegistered<StoreController>()) {
        _quickSuggestions = List.from(defaultFallbackSuggestions);
        _isSuggestionsLoading = false;
        update();
        return;
      }

      final storeController = Get.find<StoreController>();
      List<Store> candidateStores = [];

      // Collect stores from active caches in StoreController
      if (storeController.storeModel?.stores != null && storeController.storeModel!.stores!.isNotEmpty) {
        candidateStores.addAll(storeController.storeModel!.stores!);
      }
      if (storeController.latestStoreList != null && storeController.latestStoreList!.isNotEmpty) {
        for (var s in storeController.latestStoreList!) {
          if (!candidateStores.any((cs) => cs.id == s.id)) {
            candidateStores.add(s);
          }
        }
      }
      if (storeController.popularStoreList != null && storeController.popularStoreList!.isNotEmpty) {
        for (var s in storeController.popularStoreList!) {
          if (!candidateStores.any((cs) => cs.id == s.id)) {
            candidateStores.add(s);
          }
        }
      }

      // If cache is empty, fetch stores from service
      if (candidateStores.isEmpty) {
        try {
          List<Store>? fetched = await storeController.storeServiceInterface.getLatestStoreList('all', source: DataSourceEnum.client);
          if (fetched != null && fetched.isNotEmpty) {
            candidateStores.addAll(fetched);
          }
        } catch (_) {}
      }
      if (candidateStores.isEmpty) {
        try {
          StoreModel? sm = await storeController.storeServiceInterface.getStoreList(1, 'all', 'all', source: DataSourceEnum.client);
          if (sm?.stores != null && sm!.stores!.isNotEmpty) {
            candidateStores.addAll(sm.stores!);
          }
        } catch (_) {}
      }

      // Filter stores by active module if applicable
      int? currentModuleId = Get.isRegistered<SplashController>() ? Get.find<SplashController>().module?.id : null;
      if (currentModuleId != null) {
        List<Store> moduleStores = candidateStores.where((s) => s.moduleId == currentModuleId).toList();
        if (moduleStores.isNotEmpty) {
          candidateStores = moduleStores;
        }
      }

      // Find closest store using customer's address coordinates
      Store? closestStore;
      AddressModel? userAddress = AddressHelper.getUserAddressFromSharedPref();

      if (userAddress?.latitude != null && userAddress?.longitude != null && candidateStores.isNotEmpty) {
        double? userLat = double.tryParse(userAddress!.latitude!);
        double? userLng = double.tryParse(userAddress.longitude!);

        if (userLat != null && userLng != null) {
          candidateStores.sort((a, b) {
            double? latA = double.tryParse(a.latitude ?? '');
            double? lngA = double.tryParse(a.longitude ?? '');
            double? latB = double.tryParse(b.latitude ?? '');
            double? lngB = double.tryParse(b.longitude ?? '');

            if (latA == null || lngA == null) return 1;
            if (latB == null || lngB == null) return -1;

            double distA = Geolocator.distanceBetween(userLat, userLng, latA, lngA);
            double distB = Geolocator.distanceBetween(userLat, userLng, latB, lngB);
            return distA.compareTo(distB);
          });
        }
      }

      if (candidateStores.isNotEmpty) {
        closestStore = candidateStores.first;
      }

      if (closestStore != null && closestStore.id != null) {
        _nearestStoreName = closestStore.name;

        // Fetch products available in this closest store
        ItemModel? storeItems = await storeController.storeServiceInterface.getStoreItemList(
          storeID: closestStore.id,
          offset: 1,
          type: 'all',
        );

        List<String> dynamicSuggestions = [];
        if (storeItems?.items != null && storeItems!.items!.isNotEmpty) {
          for (var item in storeItems.items!) {
            if (item.name != null && item.name!.trim().isNotEmpty) {
              String cleaned = _cleanSuggestionName(item.name!);
              if (cleaned.length >= 2 && !dynamicSuggestions.contains(cleaned)) {
                dynamicSuggestions.add(cleaned);
              }
            }
          }
        }

        // If items are few, supplement with recommended products
        if (dynamicSuggestions.length < 9) {
          try {
            var recItems = await storeController.storeServiceInterface.getStoreRecommendedItemList(closestStore.id);
            if (recItems?.items != null) {
              for (var item in recItems!.items!) {
                if (item.name != null && item.name!.trim().isNotEmpty) {
                  String cleaned = _cleanSuggestionName(item.name!);
                  if (cleaned.length >= 2 && !dynamicSuggestions.contains(cleaned)) {
                    dynamicSuggestions.add(cleaned);
                  }
                }
              }
            }
          } catch (_) {}
        }

        if (dynamicSuggestions.isNotEmpty) {
          _quickSuggestions = dynamicSuggestions.take(9).toList();
        } else {
          _quickSuggestions = List.from(defaultFallbackSuggestions);
        }
      } else {
        _quickSuggestions = List.from(defaultFallbackSuggestions);
      }
    } catch (e) {
      _quickSuggestions = List.from(defaultFallbackSuggestions);
    } finally {
      _isSuggestionsLoading = false;
      update();
    }
  }

  /// Cleans and trims item names to produce short, clear keyword suggestions (max 2 words, no promo text)
  String _cleanSuggestionName(String rawName) {
    String name = rawName.trim();
    // Remove content inside brackets/parentheses e.g. (1 كجم), (حجم كبير)
    name = name.replaceAll(RegExp(r'[\(\[\{][^\)\]\}]*[\)\]\}]'), ' ').trim();
    // Remove marketing/promotional words or redundant phrases
    name = name.replaceAll(RegExp(r'متوفر في جميع البقالات|متوفر في البقالات|متوفر في|متوفر الان|متوفر الآن|متوفر|عرض خاص|تخفيضات|عرض محدود|عرض ترويجي', caseSensitive: false), ' ').trim();
    // Remove weights/quantities e.g. 1 كجم, 500 مل, 2 حبة, 1L, etc.
    name = name.replaceAll(RegExp(r'\s+\d+[\s]*(كجم|كغ|جرام|جم|مل|لتر|حبه|حبة|علبة|علب|كرتون|kg|g|ml|l|ltr)\b', caseSensitive: false), ' ').trim();
    // Remove standalone digits / bullets
    name = name.replaceAll(RegExp(r'^\d+[\.\-\s]*'), '').trim();
    // Normalize spaces
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Limit to first 2 words for short chip suggestions
    List<String> words = name.split(' ');
    if (words.length > 2) {
      name = words.sublist(0, 2).join(' ');
    }
    return name.trim();
  }

  /// Clear all data
  void clear() {
    _keywords.clear();
    _rawResults.clear();
    _results.clear();
    _keywordLoading.clear();
    _candidateStores.clear();
    _selectedStoreId = null;
    _selectedStoreName = null;
    _rawInput = '';
    _isLoading = false;
    update();
  }
}
