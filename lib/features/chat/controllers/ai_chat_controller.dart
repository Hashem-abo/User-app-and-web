import 'package:get/get.dart';
import 'package:sixam_mart/features/chat/domain/enum/chat_role_enum.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_message.dart';
import 'package:sixam_mart/features/chat/domain/models/ai_chat_alert.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/features/search/domain/services/openai_service.dart';

import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:vibration/vibration.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart' hide Store;
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/chat/domain/repositories/chat_repository.dart';
import 'package:sixam_mart/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:sixam_mart/api/api_client.dart';

class AIChatController extends GetxController implements GetxService {
  final search.SearchController searchController;
  AIChatController({required this.searchController});

  late stt.SpeechToText _speech;
  final RxBool _isListening = false.obs;
  bool get isListening => _isListening.value;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;
  
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages;

  final RxList<AIChatAlert> _alerts = <AIChatAlert>[].obs;
  List<AIChatAlert> get alerts => _alerts;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  ChatMessage? _lastSyncMessage;

  // System prompt for OpenAI
  String get _systemPrompt {
    String basePrompt = '';
    try {
      final config = Get.find<SplashController>().configModel;
      if (config != null && config.openAiSystemPrompt != null && config.openAiSystemPrompt!.isNotEmpty) {
        basePrompt = config.openAiSystemPrompt!;
      }
    } catch (_) {}

    if (basePrompt.isEmpty) {
      basePrompt = '''
    You are "The Hoopoe" (الهدهد), the wise and loyal messenger for "Suliman Market" (سوق سليمان).
    
    About "Suliman Market":
    - We are the biggest online market in Yemen.
    - Located in the capital Sana'a, Hada Street.
    - We provide the best products and stores in Yemen.
    - Our goal is Trust and Quality.
    
    Your goal is to help users find products, stores, and navigate the app with a wise, polite, and efficient tone, like a trusty bird messenger.''';
    }

    String? userAddress = "Unknown";
    try {
      userAddress = Get.find<LocationController>().address ?? "Unknown";
    } catch (e) {
      // handle case where LocationController is not ready
    }

    return '''
    $basePrompt
    
    User Current Location: $userAddress
    
    Current Module Type: ${Get.find<SplashController>().module?.moduleType ?? 'unknown'}
    
    IMPORTANT: Follow these specific action tags strictly:
 
    1. SEARCH: If the user asks to find one or more products, categories, items, or SERVICE from ANY module:
       Reply: SEARCH_ACTION: <product_1>, <product_2>, <product_3>
       Example: "I want milk, eggs, and potato" -> SEARCH_ACTION: milk, eggs, potato
       
       IMPORTANT for SEARCH: You must extract only the CORE product name.
       - Remove adjectives like "baladi", "original", "local" (بلدي، اصلي، محلي).
       - Correct spelling errors (e.g. "شمن" -> "سمن").
       - Example: "سمن بلدي" -> SEARCH_ACTION: سمن
       - Example: "شمن" -> SEARCH_ACTION: سمن
 
       If the user asks for "nearest stores", "all stores", or just "stores", use:
       SEARCH_ACTION: all
       
       If the user asks for "open stores", use:
       SEARCH_ACTION: all (OPEN)
 
       If the user asks for suggestions (e.g., "cheapest", "highest price", "best quality", "nearest"):
       - Compare the items in the provided search results.
       - "Cheapest": Pick the item with the lowest Price.
       - "Highest Price": Pick the item with the highest Price.
       - "Best Quality": Pick the item with the highest Rating.
       - "Nearest": Suggest the first item/store in the list (assuming sorted by proximity).
       - Recommend the best match to the user based on their criteria.
 
       If the user asks about stores, compares them, or asks for distance:
       - Compare 'Rating', 'Delivery Time', and 'Distance' provided in the context.
       - Answer questions like 'Which store is closer?', 'Which has better rating?'.
       - State the distance or delivery time if asked.
 
 
    2. NAVIGATION: If the user asks to go to a specific screen (e.g., "Go to cart", "Open profile") OR asks how to change theme, color, or language:
       Reply: NAVIGATE_ACTION: <screen_code>
       
       Valid <screen_code> values:
       - HOME (Main screen)
       - CART (Shopping cart/basket)
       - PROFILE (User settings/account, Change Language, Change Theme, Change Color)
       - FAVORITE (Wishlist/Saved items)
       - ORDERS (Order history/My orders)
       - CATEGORIES (All departments/sections)
       - WALLET (Balance/Credits/Points)
       - OFFERS (Sales/Promotions)
       - SERVICES (Service list/categories)
       - SERVICE_BOOKINGS (My service bookings/history)
 
    3. ADD_TO_CART: If the user explicitly asks to add an item to the cart (e.g., "Add apples to cart", "I want to buy milk"):
       Reply: ADD_TO_CART_ACTION: <product_name>
       Example: "Add burger to cart" -> ADD_TO_CART_ACTION: burger
 
    4. REMOVE_FROM_CART: If the user asks to remove an item (e.g., "Remove apples", "Delete milk"):
       Reply: REMOVE_FROM_CART_ACTION: <product_name>
       Example: "Remove burger" -> REMOVE_FROM_CART_ACTION: burger
 
    5. CLEAR_CART: If the user asks to empty the cart or delete everything (e.g., "Clear cart", "Empty basket"):
       Reply: CLEAR_CART_ACTION: all
 
    6. ALERT: If the user asks to be notified/alerted when there are new items or discounts in a specific category (e.g., "Notify me when grocery has discounts", "تنبيهي عند وجود تخفيضات في قسم البقالة"):
       Reply: ALERT_ACTION: type=<new_items_or_discount> category=<category_name>
       Example: "تنبيهي لتخفيضات البقالة" -> ALERT_ACTION: type=discount category=grocery
 
    7. SWITCH_MODULE: If the user asks to change or switch the active module/department (e.g., "switch module to grocery", "تغيير القسم إلى المطاعم"):
       Reply: SWITCH_MODULE_ACTION: <module_name_or_type>
       Example: "تغيير إلى المطاعم" -> SWITCH_MODULE_ACTION: food
 
    8. COUPONS: If the user asks for available coupons, promo codes, or wants to apply a coupon code (e.g., 'Do you have coupons?', 'هل هناك كوبونات خصم؟', 'طبق كود SAVE10'):
       Reply: COUPONS_ACTION: list OR COUPONS_ACTION: apply=<code>
       
    9. TRACK_ORDER: If the user asks to track their running orders or check their order status (e.g., 'Where is my order?', 'تتبع طلبي الأخير', 'أين الشحنة؟'):
       Reply: TRACK_ORDER_ACTION: order_id=<optional_id>
       
    10. WISHLIST: If the user wants to view their wishlist, or add/remove products to/from it (e.g., 'Show my wishlist', 'أريد عرض المفضلة', 'أضف هذا للمفضلة'):
       Reply: WISHLIST_ACTION: action=<view|add|remove> item_name=<name>
       
    11. ORDER_HISTORY: If the user wants to see their past orders, or reorder a past order (e.g., 'What did I buy last time?', 'إعادة طلب آخر طلب لي', 'إعادة الطلب رقم 1024'):
       Reply: ORDER_HISTORY_ACTION: action=<view|reorder> order_id=<optional_id>

    12. GIFT_ADVISOR: If the user says they want to buy a gift (e.g., "أريد شراء هدية لـ...", "I want to buy a gift for..."):
        - Stop and ask the user for:
          1. The age of the receiver.
        - Do not search or recommend items immediately until you obtain the age.
        - Once they provide the age, figure out suitable interests/products matching that age group, perform a search query (e.g., SEARCH_ACTION: <item_type>) for matching items, and present a tailored list of suggestions.
        
    13. USAGE: If the user asks how to use the app:
       Reply: Explain briefly: "Fly through the stores, pick what you need, and I'll make sure it's on its way!" (Adjust to user's language and tone).
    
    14. GENERAL: For greetings or chitchat, reply as "The Hoopoe" (الهدهد) in a friendly and wise manner. Use emojis like 🐦, 🪶, ✨ where appropriate.
       Always reply in the same language as the user.
       
    15. ALWAYS drag or guide the user to place an order, add products to cart, or proceed to checkout after answering any query.
 
    Examples:
    User: "Where can I buy apples?" -> You: SEARCH_ACTION: apples
    User: "Go to my cart" -> You: NAVIGATE_ACTION: CART
    User: "Open profile" -> You: NAVIGATE_ACTION: PROFILE
    User: "Show me offers" -> You: NAVIGATE_ACTION: OFFERS
    User: "تنبيهي عند وجود تخفيضات للبقالة" -> You: ALERT_ACTION: type=discount category=grocery
    User: "تغيير إلى البقالة" -> You: SWITCH_MODULE_ACTION: grocery
    User: "هل هناك كوبونات خصم؟" -> You: COUPONS_ACTION: list
    User: "أين طلبي الأخير؟" -> You: TRACK_ORDER_ACTION:
    User: "عرض مفضلتي" -> You: WISHLIST_ACTION: action=view item_name=
    User: "إعادة طلب آخر طلب لي" -> You: ORDER_HISTORY_ACTION: action=reorder order_id=
    User: "أريد شراء هدية لصديقي" -> You: "يسعدني جداً مساعدتك في اختيار الهدية المثالية! 🎁 لتسهيل الاختيار، هل يمكنك إخباري بعمر صديقك؟ 🐦✨"
    User: "Hello" -> You: "Peace be upon you! I am the Hoopoe, your guide to Suliman Market. What are you looking for today? 🐦"
    ''';
  }

  @override
  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    _loadAlerts();
    _loadModuleListIfNeeded();
    _checkAndSimulateAlerts();
  }

  void _loadAlerts() {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      final List<String>? alertStrings = sharedPreferences.getStringList("ai_chat_alerts");
      _alerts.clear();
      if (alertStrings != null) {
        for (String str in alertStrings) {
          _alerts.add(AIChatAlert.fromJson(jsonDecode(str)));
        }
      }
      update();
    } catch (e) {
      print('Error loading alerts: $e');
    }
  }

  Future<void> _saveAlerts() async {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      final List<String> alertStrings = _alerts.map((a) => jsonEncode(a.toJson())).toList();
      await sharedPreferences.setStringList("ai_chat_alerts", alertStrings);
    } catch (e) {
      print('Error saving alerts: $e');
    }
  }

  void _loadModuleListIfNeeded() {
    final splashCtrl = Get.find<SplashController>();
    if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
      splashCtrl.getModules(dataSource: DataSourceEnum.client);
    }
  }

  Future<void> removeAlert(String alertId) async {
    _alerts.removeWhere((a) => a.id == alertId);
    await _saveAlerts();
    update();
  }

  Future<void> switchActiveModule(ModuleModel module, {bool clearMessages = true}) async {
    final splashCtrl = Get.find<SplashController>();
    int index = splashCtrl.moduleList?.indexWhere((m) => m.id == module.id) ?? -1;
    if (index != -1) {
      _isLoading.value = true;
      update();
      await _saveChatHistory(); // save history of current module
      await splashCtrl.switchModule(index, true);
      if (clearMessages) {
        clearActiveMessages(); // reload history of new module starts fresh welcome screen
      }
      _isLoading.value = false;
      update();
      _checkAndSimulateAlerts();
    }
  }

  void _checkAndSimulateAlerts() {
    if (_alerts.isEmpty) return;
    
    // Simulate alert check after a short delay
    Future.delayed(const Duration(seconds: 4), () async {
      try {
        final alert = _alerts.first; // Pick the first alert for simulation
        final categoryCtrl = Get.find<CategoryController>();
        
        final itemModel = await categoryCtrl.categoryServiceInterface.getCategoryItemList(alert.categoryId.toString(), 1, 'all');
        if (itemModel != null && itemModel.items != null && itemModel.items!.isNotEmpty) {
          List<Item> matchedItems = [];
          if (alert.type == 'discount') {
            matchedItems = itemModel.items!.where((item) => item.discount != null && item.discount! > 0).toList();
          } else {
            matchedItems = itemModel.items!.take(3).toList();
          }

          if (matchedItems.isNotEmpty) {
            // Check if we already showed this notification in this session to avoid spamming
            bool alreadyShown = _messages.any((m) => m.text.contains("تنبيه الهدهد") && m.text.contains(alert.categoryName));
            if (!alreadyShown) {
              final text = alert.type == 'discount'
                  ? "🔔 **تنبيه الهدهد:** عثرت على تخفيضات رائعة في قسم **${alert.categoryName}**! تفضل بمشاهدتها:"
                  : "🔔 **تنبيه الهدهد:** تم إضافة منتجات جديدة في قسم **${alert.categoryName}**! تفضل بمشاهدتها:";
              
              _messages.add(ChatMessage(
                text: text,
                role: ChatRole.ai,
                items: matchedItems.take(5).toList(),
              ));
              _saveChatHistory();
              update();
            }
          }
        }
      } catch (e) {
        print('Alert check simulation error: $e');
      }
    });
  }

  Future<void> startListening({required Function(String) onResult}) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if(status == 'notListening' || status == 'done') {
          _isListening.value = false;
          update();
        }
      },
      onError: (errorNotification) {
        _isListening.value = false;
        update();
      },
    );

    if (available) {
      _isListening.value = true;
      update();
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            stopListening();
          }
        },
        localeId: "ar_SA",
      );
    } else {
      _messages.add(ChatMessage(text: "عذراً، خدمة الصوت غير متوفرة في جهازك حالياً. 🐦", role: ChatRole.ai, isError: true));
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening.value = false;
    update();
  }

  Future<void> pickImage(bool isCamera) async {
    final XFile? image = await _picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      _pickedImage = image;
      update();
    }
  }

  void removeImage() {
    _pickedImage = null;
    update();
  }

  bool get hasHistory {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      final currentModule = Get.find<SplashController>().module;
      final key = AppConstants.aiChatHistory + "_module_${currentModule?.id ?? 'default'}";
      final List<String>? history = sharedPreferences.getStringList(key);
      return history != null && history.isNotEmpty;
    } catch (_) {}
    return false;
  }

  void clearActiveMessages() {
    _messages.clear();
    update();
  }

  void loadChatHistory() {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      final currentModule = Get.find<SplashController>().module;
      final key = AppConstants.aiChatHistory + "_module_${currentModule?.id ?? 'default'}";
      final List<String>? history = sharedPreferences.getStringList(key);
      _messages.clear();
      if (history != null) {
        bool legacyFound = false;
        
        for (String str in history) {
           final msg = ChatMessage.fromJson(jsonDecode(str));
           if (msg.text.contains("Uncle Sulaiman") || msg.text.contains("العم سليمان") || msg.text.contains("my son") || msg.text.contains("يا بني")) {
             legacyFound = true;
             break;
           }
           _messages.add(msg);
        }
        
        if (legacyFound) {
          _messages.clear();
          _saveChatHistory();
           _messages.add(ChatMessage(text: "Peace be upon you! I am the Hoopoe, your new guide. The previous messenger has retired. 🐦", role: ChatRole.ai));
        }
      }
      update();
    } catch(e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
        final sharedPreferences = Get.find<SharedPreferences>();
        final currentModule = Get.find<SplashController>().module;
        final key = AppConstants.aiChatHistory + "_module_${currentModule?.id ?? 'default'}";
        
        final messagesToSave = _messages.length > 100 
            ? _messages.sublist(_messages.length - 100) 
            : _messages;
            
        final List<String> history = messagesToSave.map((m) => jsonEncode(m.toJson())).toList();
        await sharedPreferences.setStringList(key, history);

        if (_messages.isNotEmpty) {
          final lastMsg = _messages.last;
          if (lastMsg != _lastSyncMessage && lastMsg.role != ChatRole.system) {
            _lastSyncMessage = lastMsg;
            _saveMessageToDatabase(lastMsg);
          }
        }
     } catch(e) {
        print('Error saving chat history: $e');
     }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && _pickedImage == null) return;

    bool deductPoints = false;
    final limitStatus = await searchController.openAIService.checkAiLimit('question');
    if (limitStatus == AiLimitStatus.limitReached) {
      _pickedImage = null;
      return;
    }
    deductPoints = limitStatus == AiLimitStatus.pointsApproved;

    if (_pickedImage != null) {
       _messages.add(ChatMessage(text: text, role: ChatRole.user, image: _pickedImage));
    } else {
       _messages.add(ChatMessage(text: text, role: ChatRole.user));
    }
    _saveChatHistory();
    
    _isLoading.value = true;
    update();

    try {
      String? responseText;
      
      if (_pickedImage != null) {
        responseText = await searchController.openAIService.getChatResponseWithImage(
          text.isEmpty ? "What is in this image?" : text,
          _pickedImage!,
          systemPrompt: _systemPrompt
        );
        _pickedImage = null; 
      } else {
        List<Map<String, String>> history = [];
        final recentMessages = _messages.where((m) => !m.isError).toList();
        final startIndex = recentMessages.length > 10 ? recentMessages.length - 10 : 0;
        
        for (var i = startIndex; i < recentMessages.length; i++) {
           var m = recentMessages[i];
           if (m.text == text && m.role == ChatRole.user && i == recentMessages.length - 1) continue; 
           
           history.add({
             "role": m.role == ChatRole.user ? "user" : "assistant",
             "content": m.text
           });
        }

        responseText = await searchController.openAIService.getChatResponse(
          text, 
          systemPrompt: _systemPrompt,
          history: history
        );
      }

      if (responseText != null) {
        await searchController.openAIService.recordAiUsage('question', deductPoints: deductPoints);
        if (responseText.startsWith('SEARCH_ACTION:')) {
          final query = responseText.replaceFirst('SEARCH_ACTION:', '').split(' and provide')[0].trim();
          await _performSearchAndReply(query);
        } else if (responseText.startsWith('NAVIGATE_ACTION:')) {
           final screenCode = responseText.replaceFirst('NAVIGATE_ACTION:', '').trim();
           await _performNavigationAndReply(screenCode);
        } else if (responseText.startsWith('ADD_TO_CART_ACTION:')) {
           final itemName = responseText.replaceFirst('ADD_TO_CART_ACTION:', '').trim();
           await _performAddToCart(itemName);
        } else if (responseText.startsWith('REMOVE_FROM_CART_ACTION:')) {
           final itemName = responseText.replaceFirst('REMOVE_FROM_CART_ACTION:', '').trim();
           await _performRemoveFromCart(itemName);
        } else if (responseText.startsWith('CLEAR_CART_ACTION:')) {
           _performClearCart();
        } else if (responseText.startsWith('SWITCH_MODULE_ACTION:')) {
           final target = responseText.replaceFirst('SWITCH_MODULE_ACTION:', '').trim();
           await _performSwitchModule(target);
        } else if (responseText.startsWith('ALERT_ACTION:')) {
           await _performRegisterAlert(responseText);
        } else if (responseText.startsWith('COUPONS_ACTION:')) {
           final subAction = responseText.replaceFirst('COUPONS_ACTION:', '').trim();
           await _performCouponsAction(subAction);
        } else if (responseText.startsWith('TRACK_ORDER_ACTION:')) {
           final orderId = responseText.replaceFirst('TRACK_ORDER_ACTION:', '').trim();
           await _performTrackOrderAction(orderId);
        } else if (responseText.startsWith('WISHLIST_ACTION:')) {
           final wishlistParams = responseText.replaceFirst('WISHLIST_ACTION:', '').trim();
           await _performWishlistAction(wishlistParams);
        } else if (responseText.startsWith('ORDER_HISTORY_ACTION:')) {
           final historyParams = responseText.replaceFirst('ORDER_HISTORY_ACTION:', '').trim();
           await _performOrderHistoryAction(historyParams);
        } else {
          _messages.add(ChatMessage(text: responseText, role: ChatRole.ai));
          _saveChatHistory();
        }
      } else {
         _messages.add(ChatMessage(text: "عذراً، لم تصلني الرسالة بشكل واضح. هل يمكنك التكرار؟ 🐦", role: ChatRole.ai, isError: true));
         _saveChatHistory();
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "عذراً، حديث خطأ في الاتصال: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _performClearCart() {
    Get.find<CartController>().clearCartList();
    _messages.add(ChatMessage(text: "أفرغت السلة كما طلبت! 🗑️", role: ChatRole.ai));
    _saveChatHistory();
  }

  Future<void> _performRemoveFromCart(String itemName) async {
    final cartController = Get.find<CartController>();
    final cartList = cartController.cartList;
    
    // Find item with fuzzy match (contains)
    int index = cartList.indexWhere((element) => element.item!.name!.toLowerCase().contains(itemName.toLowerCase()));

    if (index != -1) {
      final removedItemName = cartList[index].item!.name;
      await cartController.removeFromCart(index);
      _messages.add(ChatMessage(text: "تم حذف $removedItemName من السلة. 🐦", role: ChatRole.ai));
      _saveChatHistory();
    } else {
      _messages.add(ChatMessage(text: "لم أجد $itemName في السلة. 🤔", role: ChatRole.ai));
      _saveChatHistory();
    }
  }

  Future<void> _performAddToCart(String itemName) async {
    _messages.add(ChatMessage(text: "أبحث عن '$itemName' لإضافته... 🛒", role: ChatRole.system));
    _saveChatHistory();
    
    // Search for the item
    await searchController.searchData(itemName, false);
    final items = searchController.searchItemList;

    if (items != null && items.isNotEmpty) {
      final item = items.first; // Pick the best match
      
      // Check for variations (simple check based on ItemModel properties)
      // Assuming 'variations' is a list property or similar. 
      // If we simply check variations isEmpty, or foodVariations for food module.
      
      bool hasVariations = (item.variations != null && item.variations!.isNotEmpty) || 
                           (item.foodVariations != null && item.foodVariations!.isNotEmpty);

      if (hasVariations) {
        // Must navigate to details
        _messages.add(ChatMessage(text: "هذا المنتج يتطلب تحديد خيارات. سأفتح لك التفاصيل! 🐦", role: ChatRole.ai));
        _saveChatHistory();
        await Future.delayed(const Duration(seconds: 1));
        Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, true));
      } else {
        // Direct add to cart
        // Construct CartModel. This requires mapping ItemModel to CartModel.
        // We'll use default values for simple items.
        
        double price = item.price!;
        double discount = item.discount!; // assuming item.discount is double, checking model might be needed but assuming yes
        double discountPrice = PriceConverter.convertWithDiscount(price, discount, item.discountType)!;
        
        CartModel cartModel = CartModel(
          id: null, price: price, discountedPrice: discountPrice, variation: [], foodVariations: [], discountAmount: (price - discountPrice), quantity: 1, addOnIds: [], addOns: [], isCampaign: false, stock: item.stock, item: item, quantityLimit: item.quantityLimit
        );
        
        // Add to cart controller
        Get.find<CartController>().addToCart(cartModel, null);
        
        _messages.add(ChatMessage(text: "تمت إضافة ${item.name} إلى السلة! ✅", role: ChatRole.ai, showCartButton: true));
        _saveChatHistory();
      }
    } else {
      _messages.add(ChatMessage(text: "لم أعثر على منتج بهذا الاسم. هل تريد البحث عنه؟ 🐦", role: ChatRole.ai));
      _saveChatHistory();
    }
  }

  Future<void> _performNavigationAndReply(String screenCode) async {
    String replyMessage = "بسعادة! سأطير بك إلى هناك! 🐦";
    String route = "";

    switch (screenCode.toUpperCase()) {
      case 'CART':
        route = RouteHelper.getCartRoute();
        replyMessage = "إلى السلة! 🛒";
        break;
      case 'PROFILE':
        route = RouteHelper.getProfileRoute();
        replyMessage = "ملفك الشخصي. 👤";
        break;
      case 'FAVORITE':
        route = RouteHelper.getFavouriteScreen();
        replyMessage = "المفضلات لديك. ⭐";
        break;
      case 'ORDERS':
        route = RouteHelper.getOrderRoute();
        replyMessage = "طلباتك السابقة. 📦";
        break;
      case 'CATEGORIES':
        route = RouteHelper.getCategoryRoute();
        replyMessage = "تصفح الأقسام. 📂";
        break;
      case 'WALLET':
        route = RouteHelper.getWalletRoute();
        replyMessage = "المحفظة. 💰";
        break;
      case 'OFFERS':
        route = RouteHelper.getPopularItemRoute(false, true);
        replyMessage = "أفضل العروض! 🔥";
        break;
      case 'SERVICES':
      case 'SERVICE_CATEGORIES':
        route = RouteHelper.getServicesRoute();
        replyMessage = "إليك قائمة الخدمات المتوفرة. 🛠️";
        break;
      case 'SERVICE_BOOKINGS':
        route = RouteHelper.getServiceBookingListRoute();
        replyMessage = "طلبات الخدمات وحجوزاتك. 📅";
        break;
      case 'HOME':
      default:
        route = RouteHelper.initial;
        replyMessage = "إلى الرئيسية. 🏠";
        break;
    }

    _messages.add(ChatMessage(text: replyMessage, role: ChatRole.ai));
    
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.toNamed(route);
  }

  Future<void> _performSearchAndReply(String query) async {
     _messages.add(ChatMessage(text: "أبحث لك عن '$query'... 🔍", role: ChatRole.system));
     
     bool filterOpen = false;
     if (query.toUpperCase().contains("(OPEN)")) {
       filterOpen = true;
       query = query.replaceAll("(OPEN)", "").trim();
     }

     List<String> searchQueries = query.contains(',') 
         ? query.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() 
         : [query];

     List<Item> allItems = [];
     List<Store> allStores = [];
     List<String> notFoundItems = [];

     for (var searchQuery in searchQueries) {
       bool isBroadSearch = false;
       if (searchQuery.toLowerCase() == "all" || searchQuery.toLowerCase() == "stores") {
         searchQuery = ".";
         isBroadSearch = true;
         if(!searchController.isStore) {
            searchController.setStore(true);
         }
       }

       if (isBroadSearch) {
          await Get.find<StoreController>().getStoreList(1, true);
       } else {
          await searchController.searchData(searchQuery, false);
       }
       
       var items = isBroadSearch ? null : searchController.searchItemList;
       var stores = isBroadSearch ? Get.find<StoreController>().storeModel?.stores : searchController.searchStoreList;

       if (!isBroadSearch && (items == null || items.isEmpty) && (stores == null || stores.isEmpty)) {
         final matchedModule = await _findModuleForQuery(searchQuery);
         if (matchedModule != null) {
           _messages.add(ChatMessage(
             text: "لم أجد '${searchQuery}' في القسم الحالي. سأقوم بتغيير القسم إلى **${matchedModule.moduleName}** والبحث هناك! 🐦✨",
             role: ChatRole.ai,
           ));
           update();
           await switchActiveModule(matchedModule, clearMessages: false);
           await searchController.searchData(searchQuery, false);
           items = searchController.searchItemList;
           stores = searchController.searchStoreList;
         }
       }

       if (filterOpen && stores != null) {
         stores = stores.where((s) => s.open == 1).toList();
       }

       if (items != null && items.isNotEmpty) {
         allItems.addAll(items.take(5));
       } else if (stores != null && stores.isNotEmpty) {
         allStores.addAll(stores.take(3));
       } else {
         notFoundItems.add(searchQuery);
       }
     }

     String contextInfo = "Search results:\n";
     if (allItems.isEmpty && allStores.isEmpty) {
       contextInfo += "No items or stores found.";
     } else {
       if (allItems.isNotEmpty) {
         contextInfo += "Items found:\n";
         for (var item in allItems.take(20)) {
           contextInfo += "- ${item.name} (Price: ${item.price}, Rating: ${item.avgRating}, Store: ${item.storeName}, ID: ${item.id})\n";
         }
       }
       if (allStores.isNotEmpty) {
         contextInfo += "Stores found:\n";
         for (var store in allStores.take(10)) {
           contextInfo += "- ${store.name} (Address: ${store.address}, Rating: ${store.avgRating}, Distance: ${store.distance}km, Open: ${store.open == 1})\n";
         }
       }
     }

     if (notFoundItems.isNotEmpty) {
       contextInfo += "\nThe following requested items were NOT found in the database: ${notFoundItems.join(', ')}.\n";
     }

     try {
        final finalResponse = await searchController.openAIService.getChatResponse('''
          Here are the search results from the app database:
          $contextInfo
          
          Please formulate a friendly answer in Arabic.
          1. Detail the found items (including price and store name).
          2. Link Formatting (STRICT):
             - [Product Name](/item-details?id=ID&page=item)
             - [Store Name](/store?id=ID)
          3. For the items that were NOT found (if any), state clearly that they are currently unavailable but will be available soon (سيتوفر قريباً).
          4. ALWAYS drag or guide the user to make an order now, add items to cart, or proceed to checkout.
          Be "The Hoopoe" (الهدهد) in your response. 🐦
        ''', systemPrompt: _systemPrompt);
        
        _messages.removeLast(); 
        
        if (finalResponse != null) {
          _messages.add(ChatMessage(
            text: finalResponse, 
            role: ChatRole.ai, 
            items: allItems.take(15).toList(),
            stores: allStores.take(5).toList(),
          ));
        } else {
           _messages.add(ChatMessage(text: "وجدت بعض النتائج ولكن لا أستطيع عرضها الآن. تفضل بالنظر في القائمة. 🐦", role: ChatRole.ai, isError: true));
        }
        _saveChatHistory();
     } catch(e) {
        _messages.last = ChatMessage(text: "حدث خطأ أثناء البحث.", role: ChatRole.ai, isError: true);
     }
  }

  Future<void> _performSwitchModule(String target) async {
    final splashCtrl = Get.find<SplashController>();
    if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
      await splashCtrl.getModules(dataSource: DataSourceEnum.client);
    }
    
    ModuleModel? matchedModule;
    for (var m in splashCtrl.moduleList ?? []) {
      if (m.moduleName!.toLowerCase().contains(target.toLowerCase()) || 
          m.moduleType!.toLowerCase().contains(target.toLowerCase()) ||
          m.id.toString() == target) {
        matchedModule = m;
        break;
      }
    }

    if (matchedModule != null) {
      await switchActiveModule(matchedModule);
      _messages.add(ChatMessage(text: "تم تغيير القسم إلى **${matchedModule.moduleName}** بنجاح! 🐦✨", role: ChatRole.ai));
      _saveChatHistory();
    } else {
      _messages.add(ChatMessage(text: "عذراً، لم أجد قسماً باسم '$target'. الأقسام المتوفرة هي: ${splashCtrl.moduleList?.map((m) => m.moduleName).join(', ')}. 🐦", role: ChatRole.ai));
      _saveChatHistory();
    }
  }

  Future<void> _performRegisterAlert(String alertResponse) async {
    try {
      String type = 'discount';
      if (alertResponse.contains('type=new_items')) {
        type = 'new_items';
      }
      
      String categoryName = '';
      final categoryMatch = RegExp(r'category=([^&\n\r]+)').firstMatch(alertResponse);
      if (categoryMatch != null) {
        categoryName = categoryMatch.group(1)!.trim();
      } else {
        final parts = alertResponse.split('category=');
        if (parts.length > 1) {
          categoryName = parts[1].trim();
        }
      }
      
      if (categoryName.isEmpty) {
        _messages.add(ChatMessage(text: "عذراً، لم أستطع تحديد اسم القسم المطلوب التنبيه له. 🤔", role: ChatRole.ai));
        _saveChatHistory();
        return;
      }

      final categoryCtrl = Get.find<CategoryController>();
      if (categoryCtrl.categoryList == null || categoryCtrl.categoryList!.isEmpty) {
        await categoryCtrl.getCategoryList(true, allCategory: false, dataSource: DataSourceEnum.client);
      }

      CategoryModel? matchedCategory;
      for (var cat in categoryCtrl.categoryList ?? []) {
        if (cat.name!.toLowerCase().contains(categoryName.toLowerCase())) {
          matchedCategory = cat;
          break;
        }
      }

      if (matchedCategory != null) {
        final existing = _alerts.firstWhereOrNull((a) => a.categoryId == matchedCategory!.id && a.type == type);
        if (existing != null) {
          _messages.add(ChatMessage(text: "تنبيهك لقسم **${matchedCategory.name}** مفعّل بالفعل! 🔔", role: ChatRole.ai));
        } else {
          final alert = AIChatAlert(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: type,
            categoryId: matchedCategory.id!,
            categoryName: matchedCategory.name!,
            createdAt: DateTime.now(),
          );
          _alerts.add(alert);
          await _saveAlerts();
          
          final textConfirm = type == 'discount' 
              ? "أبشر! قمت بتفعيل تنبيه التخفيضات لقسم **${matchedCategory.name}**. سأخبرك فور توفر عروض جديدة! 🔔✨"
              : "أبشر! قمت بتفعيل تنبيه المنتجات الجديدة لقسم **${matchedCategory.name}**. سأقوم بمتابعتها من أجلك! 🔔✨";
          
          _messages.add(ChatMessage(text: textConfirm, role: ChatRole.ai));
        }
        _saveChatHistory();
      } else {
        final availableCats = categoryCtrl.categoryList?.take(5).map((c) => c.name).join(', ') ?? '';
        _messages.add(ChatMessage(text: "لم أعثر على قسم باسم '$categoryName'. هل تقصد أحد هذه الأقسام: $availableCats؟ 🐦", role: ChatRole.ai));
        _saveChatHistory();
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "عذراً، حدث خطأ أثناء إعداد التنبيه: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    }
  }

  Future<void> _performCouponsAction(String actionCode) async {
    try {
      final couponCtrl = Get.find<CouponController>();
      if (actionCode.startsWith('apply=')) {
        final code = actionCode.replaceFirst('apply=', '').trim();
        _messages.add(ChatMessage(text: "أقوم بتطبيق كود الخصم '$code'... 🎟️", role: ChatRole.system));
        _saveChatHistory();
        
        double? discountAmount = await couponCtrl.applyCoupon(code, 100.0, 10.0, null);
        _messages.removeLast();

        if (discountAmount != null && discountAmount > 0) {
          _messages.add(ChatMessage(
            text: "تم تطبيق الكود **$code** بنجاح! خصم بقيمة **${PriceConverter.convertPrice(discountAmount)}**! 🎉✨",
            role: ChatRole.ai,
          ));
        } else {
          _messages.add(ChatMessage(
            text: "كود الخصم **$code** غير صالح أو لم يستوف الحد الأدنى للشراء. 🎟️❌",
            role: ChatRole.ai,
          ));
        }
        _saveChatHistory();
        update();
      } else {
        _messages.add(ChatMessage(text: "أقوم بجلب قسائم الخصم المتوفرة... 🎟️", role: ChatRole.system));
        _saveChatHistory();
        
        await couponCtrl.getCouponList();
        _messages.removeLast();

        if (couponCtrl.couponList != null && couponCtrl.couponList!.isNotEmpty) {
          _messages.add(ChatMessage(
            text: "إليك قسائم الخصم المتوفرة حالياً في سوق سليمان! تفضل باستخدامها عند الدفع: 🎫",
            role: ChatRole.ai,
            coupons: couponCtrl.couponList,
          ));
        } else {
          _messages.add(ChatMessage(text: "لا توجد قسائم خصم نشطة حالياً. تفقدنا لاحقاً! 🐦", role: ChatRole.ai));
        }
        _saveChatHistory();
        update();
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "حدث خطأ أثناء جلب الكوبونات: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    }
  }

  Future<void> _performTrackOrderAction(String orderId) async {
    try {
      final orderCtrl = Get.find<OrderController>();
      _messages.add(ChatMessage(text: "جاري الاستعلام عن حالة الطلب... 📦", role: ChatRole.system));
      _saveChatHistory();
      
      await orderCtrl.getRunningOrders(1);
      _messages.removeLast();

      OrderModel? targetOrder;
      if (orderId.isNotEmpty) {
        final id = int.tryParse(orderId);
        targetOrder = orderCtrl.runningOrderModel?.orders?.firstWhereOrNull((o) => o.id == id);
      } else {
        if (orderCtrl.runningOrderModel?.orders != null && orderCtrl.runningOrderModel!.orders!.isNotEmpty) {
          targetOrder = orderCtrl.runningOrderModel!.orders!.first;
        }
      }

      if (targetOrder != null) {
        await orderCtrl.getOrderDetails(targetOrder.id.toString());
        _messages.add(ChatMessage(
          text: "إليك تفاصيل تتبع طلبك رقم **#${targetOrder.id}**: 📦✨",
          role: ChatRole.ai,
          chatOrders: [targetOrder],
        ));
      } else {
        _messages.add(ChatMessage(text: "لم أجد أي طلبات نشطة حالياً قيد التوصيل. 🐦", role: ChatRole.ai));
      }
      _saveChatHistory();
      update();
    } catch (e) {
      _messages.add(ChatMessage(text: "حدث خطأ أثناء تتبع الطلب: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    }
  }

  Future<void> _performWishlistAction(String wishlistParams) async {
    try {
      final favCtrl = Get.find<FavouriteController>();
      
      String action = 'view';
      if (wishlistParams.contains('action=add')) {
        action = 'add';
      } else if (wishlistParams.contains('action=remove')) {
        action = 'remove';
      }
      
      String itemName = '';
      final nameMatch = RegExp(r'item_name=([^&\n\r]+)').firstMatch(wishlistParams);
      if (nameMatch != null) {
        itemName = nameMatch.group(1)!.trim();
      }

      if (action == 'view') {
        _messages.add(ChatMessage(text: "جاري جلب قائمتك المفضلة... ⭐", role: ChatRole.system));
        _saveChatHistory();
        
        await favCtrl.getFavouriteList();
        _messages.removeLast();

        final items = favCtrl.wishItemList?.where((i) => i != null).cast<Item>().toList() ?? [];
        if (items.isNotEmpty) {
          _messages.add(ChatMessage(
            text: "إليك المنتجات في قائمتك المفضلة: ⭐",
            role: ChatRole.ai,
            items: items,
          ));
        } else {
          _messages.add(ChatMessage(text: "قائمتك المفضلة فارغة حالياً. أضف بعض المنتجات إليها! 🐦⭐", role: ChatRole.ai));
        }
        _saveChatHistory();
        update();
      } else {
        if (itemName.isEmpty) {
          _messages.add(ChatMessage(text: "عذراً، لم أستطع تحديد اسم المنتج المطلوب تعديله في المفضلة. 🤔", role: ChatRole.ai));
          _saveChatHistory();
          return;
        }

        _messages.add(ChatMessage(text: "أبحث عن المنتج '$itemName'... 🔍", role: ChatRole.system));
        _saveChatHistory();
        
        await searchController.searchData(itemName, false);
        _messages.removeLast();

        if (searchController.searchItemList != null && searchController.searchItemList!.isNotEmpty) {
          final item = searchController.searchItemList!.first;
          if (action == 'add') {
            favCtrl.addToFavouriteList(item, null, false);
            _messages.add(ChatMessage(text: "تمت إضافة **${item.name}** إلى قائمتك المفضلة بنجاح! ⭐✨", role: ChatRole.ai));
          } else {
            favCtrl.removeFromFavouriteList(item.id, false);
            _messages.add(ChatMessage(text: "تم حذف **${item.name}** من قائمتك المفضلة. 🗑️⭐", role: ChatRole.ai));
          }
        } else {
          _messages.add(ChatMessage(text: "لم أجد منتجاً بهذا الاسم لتعديله في المفضلة. 🐦", role: ChatRole.ai));
        }
        _saveChatHistory();
        update();
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "حدث خطأ أثناء تعديل المفضلة: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    }
  }

  Future<void> _performOrderHistoryAction(String historyParams) async {
    try {
      final orderCtrl = Get.find<OrderController>();
      
      String action = 'view';
      if (historyParams.contains('action=reorder')) {
        action = 'reorder';
      }
      
      String orderIdStr = '';
      final idMatch = RegExp(r'order_id=([^&\n\r]+)').firstMatch(historyParams);
      if (idMatch != null) {
        orderIdStr = idMatch.group(1)!.trim();
      }

      if (action == 'reorder') {
        int? orderId = int.tryParse(orderIdStr);
        if (orderId == null) {
          await orderCtrl.getHistoryOrders(1);
          if (orderCtrl.historyOrderModel?.orders != null && orderCtrl.historyOrderModel!.orders!.isNotEmpty) {
            orderId = orderCtrl.historyOrderModel!.orders!.first.id;
          }
        }

        if (orderId != null) {
          _messages.add(ChatMessage(text: "جاري إعادة طلب المنتجات من الطلب رقم **#$orderId**... 🛒", role: ChatRole.system));
          _saveChatHistory();
          
          orderCtrl.reorder(orderId);
          _messages.removeLast();
          
          _messages.add(ChatMessage(
            text: "تم إضافة جميع منتجات الطلب رقم **#$orderId** إلى سلة التسوق الخاصة بك بنجاح! 🛒🎉",
            role: ChatRole.ai,
            showCartButton: true,
          ));
        } else {
          _messages.add(ChatMessage(text: "لم أعثر على أي طلبات سابقة لإعادة طلبها. 🐦", role: ChatRole.ai));
        }
        _saveChatHistory();
        update();
      } else {
        _messages.add(ChatMessage(text: "جاري جلب سجل طلباتك السابقة... 📦", role: ChatRole.system));
        _saveChatHistory();
        
        await orderCtrl.getHistoryOrders(1);
        _messages.removeLast();

        if (orderCtrl.historyOrderModel?.orders != null && orderCtrl.historyOrderModel!.orders!.isNotEmpty) {
          _messages.add(ChatMessage(
            text: "إليك سجل طلباتك السابقة من سوق سليمان: 📦👇",
            role: ChatRole.ai,
            chatOrders: orderCtrl.historyOrderModel!.orders,
          ));
        } else {
          _messages.add(ChatMessage(text: "لا يوجد لديك سجل طلبات سابقة بعد. ابدأ بالتسوق الآن! 🛒🐦", role: ChatRole.ai));
        }
        _saveChatHistory();
        update();
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "حدث خطأ أثناء جلب سجل الطلبات: $e", role: ChatRole.ai, isError: true));
      _saveChatHistory();
    }
  }

  // checkLimits removed as we now use centralized backend checking.


  Future<void> _saveMessageToDatabase(ChatMessage message) async {
    try {
      final chatRepo = Get.find<ChatRepositoryInterface>() as ChatRepository;
      final isLoggedIn = AuthHelper.isLoggedIn();
      final body = {
        'text': message.text,
        'role': message.role.toString().split('.').last,
        'module_id': Get.find<SplashController>().module?.id,
        'user_id': isLoggedIn ? Get.find<ProfileController>().userInfoModel?.id : null,
        'guest_id': isLoggedIn ? null : AuthHelper.getGuestId(),
        'timestamp': message.timestamp.toIso8601String(),
      };
      
      await chatRepo.apiClient.postData('/api/v1/customer/ai-chat/save', body);
    } catch (e) {
      print('Failed to save message to database: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversationLogsFromDatabase() async {
    try {
      final chatRepo = Get.find<ChatRepositoryInterface>() as ChatRepository;
      Response response = await chatRepo.apiClient.getData('/api/v1/customer/ai-chat/all');
      if (response.statusCode == 200 && response.body != null) {
        return List<Map<String, dynamic>>.from(response.body);
      }
    } catch (e) {
      print('Failed to fetch conversation logs: $e');
    }
    return [];
  }

  Future<bool> savePromptToServer(String prompt) async {
    try {
      final chatRepo = Get.find<ChatRepositoryInterface>() as ChatRepository;
      Response response = await chatRepo.apiClient.postData('/api/v1/customer/ai-chat/update-prompt', {
        'openai_system_prompt': prompt,
      });
      if (response.statusCode == 200) {
        final config = Get.find<SplashController>().configModel;
        if (config != null) {
          config.openAiSystemPrompt = prompt;
        }
        return true;
      }
    } catch (e) {
      print('Failed to update prompt on server: $e');
    }
    return false;
  }

  /// Searches all other modules on the server to check if any of them has items for the query
  Future<ModuleModel?> _findModuleForQuery(String searchQuery) async {
    try {
      final splashCtrl = Get.find<SplashController>();
      final apiClient = Get.find<ApiClient>();
      
      if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
        await splashCtrl.getModules(dataSource: DataSourceEnum.client);
      }
      
      final currentModule = splashCtrl.module;
      for (var m in splashCtrl.moduleList ?? []) {
        if (currentModule != null && m.id == currentModule.id) {
          continue; // Skip current module
        }
        
        // Prepare custom headers with this module ID
        final tempHeaders = Map<String, String>.from(apiClient.getHeader());
        tempHeaders[AppConstants.moduleId] = m.id.toString();
        
        Response response = await apiClient.getData(
          '${AppConstants.searchUri}items/search?name=$searchQuery&offset=1&limit=12',
          headers: tempHeaders,
        );
        
        if (response.statusCode == 200 && response.body != null) {
          final itemModel = ItemModel.fromJson(response.body);
          if (itemModel.items != null && itemModel.items!.isNotEmpty) {
            return m; // Found module!
          }
        }
      }
    } catch (e) {
      print('Error finding module for query: $e');
    }
    return null;
  }
}
