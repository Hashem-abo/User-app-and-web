import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/search/domain/models/popular_categories_model.dart';
import 'package:sixam_mart/features/search/domain/models/search_suggestion_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/search/domain/services/search_service_interface.dart';
import 'package:sixam_mart/features/search/domain/services/openai_service.dart';
import 'package:sixam_mart/features/search/widgets/image_source_bottom_sheet.dart';
import 'package:sixam_mart/features/search/screens/noon_vision_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/chat/controllers/ai_chat_controller.dart';

class SearchController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;
  final OpenAIService openAIService = OpenAIService();

  SearchController({required this.searchServiceInterface}) {
    _speech = stt.SpeechToText();
  }

  List<Item>? _searchItemList;
  List<Item>? get searchItemList => _searchItemList;
  
  List<Item>? _allItemList;
  List<Item>? get allItemList => _allItemList;
  
  List<Item>? _suggestedItemList;
  List<Item>? get suggestedItemList => _suggestedItemList;
  
  List<Store>? _searchStoreList;
  List<Store>? get searchStoreList => _searchStoreList;
  
  List<Store>? _allStoreList;
  List<Store>? get allStoreList => _allStoreList;
  
  String? _searchText = '';
  String? get searchText => _searchText;
  
  String? _storeResultText = '';
  
  String? _itemResultText = '';
  
  double _lowerValue = 0;
  double get lowerValue => _lowerValue;
  
  double _upperValue = 0;
  double get upperValue => _upperValue;
  
  List<String> _historyList = [];
  List<String> get historyList => _historyList;
  
  bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;
  
  final List<String> _sortList = ['ascending'.tr, 'descending'.tr];
  List<String> get sortList => _sortList;
  
  int _sortIndex = -1;
  int get sortIndex => _sortIndex;

  int _storeSortIndex = -1;
  int get storeSortIndex => _storeSortIndex;
  
  int _rating = -1;
  int get rating => _rating;

  int _storeRating = -1;
  int get storeRating => _storeRating;
  
  bool _isStore = false;
  bool get isStore => _isStore;
  
  bool _isAvailableItems = false;
  bool get isAvailableItems => _isAvailableItems;

  bool _isAvailableStore = false;
  bool get isAvailableStore => _isAvailableStore;
  
  bool _isDiscountedItems = false;
  bool get isDiscountedItems => _isDiscountedItems;

  bool _isDiscountedStore = false;
  bool get isDiscountedStore => _isDiscountedStore;
  
  bool _veg = false;
  bool get veg => _veg;

  bool _storeVeg = false;
  bool get storeVeg => _storeVeg;
  
  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  bool _storeNonVeg = false;
  bool get storeNonVeg => _storeNonVeg;
  
  String? _searchHomeText = '';
  String? get searchHomeText => _searchHomeText;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<PopularCategoryModel?>? _popularCategoryList;
  List<PopularCategoryModel?>? get popularCategoryList => _popularCategoryList;

  bool _isAiSearch = false;
  bool get isAiSearch => _isAiSearch;

  XFile? _searchImage;
  XFile? get searchImage => _searchImage;

  Map<String, String>? _aiResult;
  Map<String, String>? get aiResult => _aiResult;

  void toggleVeg() {
    _veg = !_veg;
    update();
  }

  void toggleStoreVeg() {
    _storeVeg = !_storeVeg;
    update();
  }

  void toggleNonVeg() {
    _nonVeg = !_nonVeg;
    update();
  }

  void toggleStoreNonVeg() {
    _storeNonVeg = !_storeNonVeg;
    update();
  }

  void toggleAvailableItems() {
    _isAvailableItems = !_isAvailableItems;
    update();
  }

  void toggleAvailableStore() {
    _isAvailableStore = !_isAvailableStore;
    update();
  }

  void toggleDiscountedItems() {
    _isDiscountedItems = !_isDiscountedItems;
    update();
  }

  void toggleDiscountedStore() {
    _isDiscountedStore = !_isDiscountedStore;
    update();
  }

  void setStore(bool isStore) {
    if (_isStore != isStore) {
      _isStore = isStore;
      update();
    }
  }

  void setSearchMode(bool isSearchMode, {bool canUpdate = true}) {
    _isSearchMode = isSearchMode;
    if(isSearchMode) {
      _searchText = '';
      _itemResultText = '';
      _storeResultText = '';
      _allStoreList = null;
      _allItemList = null;
      _searchItemList = null;
      _searchStoreList = null;
      _sortIndex = -1;
      _storeSortIndex = -1;
      _isDiscountedItems = false;
      _isDiscountedStore = false;
      _isAvailableItems = false;
      _isAvailableStore = false;
      _veg = false;
      _storeVeg = false;
      _nonVeg = false;
      _storeNonVeg = false;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
      _isAiSearch = false;
    }
    if(isSearchMode) {
       Get.find<ServiceController>().clearSearchData();
    }
    if(_isStore) {
      _isStore = !_isStore;
    }
    if(canUpdate) {
      update();
    }
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void sortItemSearchList() {
    _searchItemList = searchServiceInterface.sortItemSearchList(_allItemList, _upperValue, _lowerValue, _rating, _veg, _nonVeg, _isAvailableItems, _isDiscountedItems, _sortIndex);
    update();
  }

  void sortStoreSearchList() {
    _searchStoreList = searchServiceInterface.sortStoreSearchList(_allStoreList, _storeRating, _storeVeg, _storeNonVeg, _isAvailableStore, _isDiscountedStore, _storeSortIndex);
    update();
  }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void getSuggestedItems() async {
    List<Item>? suggestedItemList = await searchServiceInterface.getSuggestedItems();
    if(suggestedItemList != null) {
      _suggestedItemList = [];
      _suggestedItemList!.addAll(suggestedItemList);
    }
    update();
  }

  void _saveHistoryToStorage() {
    final int? currentModuleId = Get.find<SplashController>().module?.id;
    List<String> allHistory = searchServiceInterface.getSearchAddress();
    
    allHistory.removeWhere((h) {
      if (h.contains('_')) {
        final parts = h.split('_');
        return parts[0] == currentModuleId.toString();
      } else {
        return _historyList.contains(h);
      }
    });
    
    for (int i = _historyList.length - 1; i >= 0; i--) {
      allHistory.insert(0, "${currentModuleId}_${_historyList[i]}");
    }
    
    if (allHistory.length > 30) {
      allHistory = allHistory.sublist(0, 30);
    }
    
    searchServiceInterface.saveSearchHistory(allHistory);
  }

  Future<void> searchData(String? query, bool fromHome) async {
    if((_isStore && query!.isNotEmpty && query != _storeResultText) || (!_isStore && query!.isNotEmpty && (query != _itemResultText || fromHome))) {
      _searchHomeText = query;
      _searchText = query;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
      if (_isStore) {
        _searchStoreList = null;
        _allStoreList = null;
      } else {
        _searchItemList = null;
        _allItemList = null;
      }
      if (!_historyList.contains(query)) {
        _historyList.insert(0, query);
      }
      _saveHistoryToStorage();
      _isSearchMode = false;
      if(!fromHome) {
        update();
      }

      _isAiSearch = false;
      bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';
      if (isService) {
        if (_isStore) {
          _storeResultText = query;
        } else {
          _itemResultText = query;
        }
        await Get.find<ServiceController>().searchServices(query, 1, _isStore);
      } else {
        Response response = await searchServiceInterface.getSearchData(query, _isStore);
        if (response.statusCode == 200) {
          if (query.isEmpty) {
            if (_isStore) {
              _searchStoreList = [];
            } else {
              _searchItemList = [];
            }
          } else {
            if (_isStore) {
              _storeResultText = query;
              _searchStoreList = [];
              _allStoreList = [];
              final stores = StoreModel.fromJson(response.body).stores;
              if (stores != null) {
                _searchStoreList!.addAll(stores);
                _allStoreList!.addAll(stores);
              }
            } else {
              _itemResultText = query;
              _searchItemList = [];
              _allItemList = [];
              final items = ItemModel.fromJson(response.body).items;
              if (items != null) {
                _searchItemList!.addAll(items);
                _allItemList!.addAll(items);
              }
            }
          }
        }
      }
      update();
    }
  }

  Future<void> searchByAiData(String? query, bool fromHome) async {
    if(query != null && query.isNotEmpty && (query != _itemResultText || fromHome)) {
      _searchHomeText = query;
      _searchText = query;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
      _searchItemList = null;
      _allItemList = null;
      
      if (!_historyList.contains(query)) {
        _historyList.insert(0, query);
      }
      _saveHistoryToStorage();
      _isSearchMode = false;
      if(!fromHome) {
        update();
      }

      _isAiSearch = true;
      Response response = await searchServiceInterface.getSearchByAiData(query);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _searchItemList = [];
        } else {
          _itemResultText = query;
          _searchItemList = [];
          _allItemList = [];
          final items = ItemModel.fromJson(response.body).items;
          if (items != null) {
            _searchItemList!.addAll(items);
            _allItemList!.addAll(items);
          }
        }
      }
      update();
    }
  }

  void getHistoryList() {
    _isSearchMode = true;
    _searchText = '';
    _historyList = [];
    final allHistory = searchServiceInterface.getSearchAddress();
    final int? currentModuleId = Get.find<SplashController>().module?.id;
    for (var h in allHistory) {
      if (h.contains('_')) {
        final parts = h.split('_');
        if (parts[0] == currentModuleId.toString()) {
          final cleanQuery = parts.sublist(1).join('_');
          if (!_historyList.contains(cleanQuery)) {
            _historyList.add(cleanQuery);
          }
        }
      } else {
        if (!_historyList.contains(h)) {
          _historyList.add(h);
        }
      }
    }
  }

  void removeHistory(int index) {
    _historyList.removeAt(index);
    _saveHistoryToStorage();
    update();
  }

  void clearSearchHistory() async {
    final int? currentModuleId = Get.find<SplashController>().module?.id;
    List<String> allHistory = searchServiceInterface.getSearchAddress();
    allHistory.removeWhere((h) {
      if (h.contains('_')) {
        final parts = h.split('_');
        return parts[0] == currentModuleId.toString();
      }
      return true;
    });
    searchServiceInterface.saveSearchHistory(allHistory);
    _historyList = [];
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setStoreRating(int rate) {
    _storeRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  void setStoreSortIndex(int index) {
    _storeSortIndex = index;
    update();
  }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _isAvailableItems = false;
    _isDiscountedItems = false;
    _veg = false;
    _nonVeg = false;
    _sortIndex = -1;
    update();
  }

  void resetStoreFilter() {
    _storeRating = -1;
    _isAvailableStore = false;
    _isDiscountedStore = false;
    _storeVeg = false;
    _storeNonVeg = false;
    _storeSortIndex = -1;
    update();
  }

  void clearSearchHomeText() {
    _searchHomeText = '';
    update();
  }

  void clearSearchImage() {
    _searchImage = null;
    _aiResult = null;
    update();
  }

  Future<List<String>> getSearchSuggestions(String searchText) async {
    List<String> items = <String>[];
    bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';
    if (isService) {
      // For services, we can use the same suggestion mechanism if backed by the same logic,
      // or implement a service-specific suggestion endpoint.
      // For now, let's stick to the existing one as it might be module-aware on backend.
    }
    _searchSuggestionModel = await searchServiceInterface.getSearchSuggestions(searchText);
    if(_searchSuggestionModel != null) {
      if (_searchSuggestionModel!.items != null) {
        for (var item in _searchSuggestionModel!.items!) {
          if (item.name != null) {
            items.add(item.name!);
          }
        }
      }
      if (_searchSuggestionModel!.stores != null) {
        for (var store in _searchSuggestionModel!.stores!) {
          if (store.name != null) {
            items.add(store.name!);
          }
        }
      }
    }
    return items;
  }

  Future<void> getPopularCategories() async {
    _popularCategoryList = null;
    _popularCategoryList = await searchServiceInterface.getPopularCategories();
    update();
  }

  Future<void> searchByImage(bool fromHome) async {
    bool deductPoints = false;
    try {
      final limitStatus = await openAIService.checkAiLimit('image_search');
      if (limitStatus == AiLimitStatus.limitReached) return;
      deductPoints = limitStatus == AiLimitStatus.pointsApproved;
    } catch (_) {}

    if (AuthHelper.isLoggedIn()) {
      Get.bottomSheet(
        ImageSourceBottomSheet(
          onImageSelected: (source) async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: source);

            if (image != null) {
              Get.dialog(const Center(child: CustomLoaderWidget()), barrierDismissible: false);
              final Map<String, String>? aiResponse = await openAIService.identifyItemFromImage(image);
              Get.back();

              if (aiResponse != null) {
                await openAIService.recordAiUsage('image_search', deductPoints: deductPoints);
                String item = aiResponse['identified_item'] ?? 'unknown';
                String details = aiResponse['more_details'] ?? '';
                String query = aiResponse['optimized_query'] ?? item;

                if (item.toLowerCase() == 'unknown') {
                  showCustomSnackBar('could_not_identify_the_item'.tr);
                } else {
                  _searchImage = image;
                  _aiResult = aiResponse;
                  update();
                  Get.to(() => NoonVisionScreen(fromHome: fromHome));
                }
              } else {
                showCustomSnackBar('failed_to_process_image'.tr);
              }
            }
          },
        ),
        backgroundColor: Colors.transparent,
      );
    } else {
      showCustomSnackBar('you_are_not_logged_in'.tr);
    }
  }


  ///Voice Search..................

  bool voiceIsListening = false;
  String voiceText = '';
  double voiceSoundLevel = 0.0;
  bool voiceAvailable = false;
  bool _isAiVoice = false;
  Timer? _voiceAutoSubmitTimer;

  late stt.SpeechToText _speech;

  /// Initialize speech (safe to call multiple times)
  Future<void> initVoice({bool isUpdate = true}) async {
    try {
      final available = await _speech.initialize(onStatus: _onStatus, onError: _onError);
      voiceAvailable = available;
    } catch (e) {
      voiceAvailable = false;
    }
    if(isUpdate) update();
  }
  
  void setAiVoice(bool enable, {bool isUpdate = true}) {
    _isAiVoice = enable;
    if(isUpdate) update();
  }

  void _onStatus(String status) {
    if (status == stt.SpeechToText.listeningStatus) {
      setVoiceListening(true);
      cancelVoiceAutoSubmit();
    } else if (status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus || status == 'not listening') {
      setVoiceListening(false);
      scheduleVoiceAutoSubmit(const Duration(seconds: 2));
    }
  }

  void _onError(dynamic error) {
    setVoiceListening(false);
  }

  /// Start listening and optionally update an external TextEditingController live
  Future<void> startVoiceListening({TextEditingController? externalController}) async {
    cancelVoiceAutoSubmit();

    // Clear any previous session
    try {
      if (_speech.isListening) await _speech.stop();
      await _speech.cancel();
    } catch (_) {}

    if (!voiceAvailable) {
      await initVoice();
      if (!voiceAvailable) return;
    }

    // Reset
    setVoiceText('');
    setVoiceSoundLevel(0.0);

    try {
      await _speech.listen(
        onResult: (result) {
          final recognized = result.recognizedWords;
          setVoiceText(recognized);
          if (externalController != null) {
            externalController.text = recognized;
            externalController.selection = TextSelection.fromPosition(TextPosition(offset: externalController.text.length));
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        onSoundLevelChange: (level) {
          final normalized = (level / 50).clamp(0.0, 1.0);
          setVoiceSoundLevel(normalized);
        },
        localeId: 'ar', // Set Arabic locale
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true, listenMode: stt.ListenMode.search),
      );
      if (_speech.isListening) {
        setVoiceListening(true);
      } else {
        setVoiceListening(false);
      }
    } catch (e) {
      setVoiceListening(false);
    }
  }



  /// Stop or cancel listening
  Future<void> stopVoiceListening({bool submit = false}) async {
    cancelVoiceAutoSubmit();
    try {
      await _speech.stop();
    } catch (e) {
      try {
        await _speech.cancel();
      } catch (_) {}
    }
    setVoiceListening(false);
    if (submit) await submitVoiceNow();
  }

  void setVoiceListening(bool value, {bool isUpdate = true}) {
    voiceIsListening = value;
    if(isUpdate) update();
  }

  void setVoiceText(String text, {bool isUpdate = true}) {
    voiceText = text;
    if(isUpdate) update();
  }

  void setVoiceSoundLevel(double level, {bool isUpdate = true}) {
    voiceSoundLevel = level;
    if(isUpdate) update();
  }

  void scheduleVoiceAutoSubmit(Duration duration) {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = Timer(duration, () async {
      await submitVoiceNow();
    });
  }

  void cancelVoiceAutoSubmit() {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = null;
  }

  Future<void> submitVoiceNow() async {
    cancelVoiceAutoSubmit();
    final text = voiceText.trim();
    if (text.isNotEmpty) {
      try {
        if ((Get.isBottomSheetOpen ?? false) || (Get.isDialogOpen ?? false)) {
          Get.back();
        }
      } catch (_) {}

      String finalQuery = text;
      
      if (_isAiVoice) {
        bool deductPoints = false;
        try {
          final limitStatus = await openAIService.checkAiLimit('voice_extract');
          if (limitStatus == AiLimitStatus.limitReached) return;
          deductPoints = limitStatus == AiLimitStatus.pointsApproved;
        } catch (_) {}

        showCustomSnackBar('processing_with_ai'.tr, isError: false);
        final extracted = await openAIService.extractProductsFromText(text);
        await openAIService.recordAiUsage('voice_extract', deductPoints: deductPoints);
        if (extracted != null && extracted.toLowerCase() != 'unknown') {
          // AI returns comma-separated list, we convert to spaces for the backend's OR search
          finalQuery = extracted.replaceAll(',', ' ').replaceAll('،', ' ');
        }
      } else {
        // For normal voice search, we convert conjunctions like 'and' or 'و' to spaces
        // to leverage the backend's multi-word (OR) search capability.
        finalQuery = text.replaceAll(' و ', ' ').replaceAll(' and ', ' ').replaceAll('،', ' ').replaceAll(',', ' ');
      }

      // Both AI-preprocessed and normal voice searches now use the AI endpoint
      // to ensure we search in both item names and descriptions.
      await searchByAiData(finalQuery, false);
    }
  }


  @override
  void onClose() {
    _voiceAutoSubmitTimer?.cancel();
    super.onClose();
  }
  
}