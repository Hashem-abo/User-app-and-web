import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/chat/controllers/ai_chat_controller.dart';
import 'package:sixam_mart/features/chat/widgets/message_bubble.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final ValueNotifier<bool> _isTyping = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AIChatController>()) {
      Get.put(AIChatController(searchController: Get.find<search.SearchController>()));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AIChatController>().clearActiveMessages();
    });

    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    bool hasText = _textController.text.trim().isNotEmpty;
    if (_isTyping.value != hasText) {
      _isTyping.value = hasText;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _isTyping.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hoopoe_name'.tr, style: robotoBold),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AIChatController>(
        builder: (chatController) {
          if (chatController.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (chatController.messages.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.support_agent_rounded, size: 60, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "السلام عليكم! أنا الهدهد 🐦", 
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
                              textAlign: TextAlign.center,
                            ),
                            if (chatController.hasHistory) ...[
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {
                                  chatController.loadChatHistory();
                                },
                                icon: Icon(Icons.history_rounded, size: 16, color: Theme.of(context).primaryColor),
                                label: Text(
                                  "عرض المحادثة السابقة 💬",
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              "مساعدك الشخصي الذكي، موجود لخدمتك في أي وقت.",
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // Dropdown to switch active module (placed above the features)
                            GetBuilder<SplashController>(
                              builder: (splashCtrl) {
                                if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
                                  return const SizedBox();
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "القسم النشط:  ",
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: splashCtrl.module?.id,
                                          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor, size: 20),
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                                          dropdownColor: Theme.of(context).cardColor,
                                          onChanged: (int? newValue) {
                                            if (newValue != null && newValue != splashCtrl.module?.id) {
                                              final selectedModule = splashCtrl.moduleList!.firstWhere((mod) => mod.id == newValue);
                                              chatController.switchActiveModule(selectedModule);
                                            }
                                          },
                                          items: splashCtrl.moduleList!.map<DropdownMenuItem<int>>((mod) {
                                            return DropdownMenuItem<int>(
                                              value: mod.id,
                                              child: Text(
                                                mod.moduleName ?? '', 
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            _buildFeatureItem(context, Icons.search, "البحث عن المنتجات", "مثال: \"أين أجد تفاح أحمر؟\""),
                            _buildFeatureItem(context, Icons.store, "البحث عن المتاجر", "مثال: \"أقرب متجر بقالة مني\""),
                            _buildFeatureItem(context, Icons.compare_arrows, "مقارنة الأسعار", "مثال: \"هل هذا السعر جيد؟\""),
                            _buildFeatureItem(context, Icons.shopping_cart_checkout, "تعبئة السلة", "مثال: \"أضف قائمة مقاضي للبيت\""),
                            _buildFeatureItem(context, Icons.navigation, "التنقل داخل التطبيق", "مثال: \"خذني إلى سلة التسوق\""),
                            _buildFeatureItem(context, Icons.build_circle_outlined, "الخدمات والحجوزات", "مثال: \"أريد قسم خدمات السباكة\""),
                            _buildFeatureItem(context, Icons.camera_alt, "تحليل الصور", "التقط صورة لمنتج واسألني عنه!"),
                            const SizedBox(height: 10),

                            /*
                            const Divider(height: 40),
                            Text(
                              "القسم النشط حالياً: ${Get.find<SplashController>().module?.moduleName ?? ''} 📍",
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "هل تريد المساعدة في قسم آخر؟",
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            
                            GetBuilder<SplashController>(builder: (splashCtrl) {
                              if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
                                return const SizedBox();
                              }
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: splashCtrl.moduleList!.map((mod) {
                                  final isCurrent = mod.id == splashCtrl.module?.id;
                                  return ChoiceChip(
                                    label: Text(mod.moduleName ?? '', style: robotoMedium.copyWith(
                                      color: isCurrent ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                      fontSize: Dimensions.fontSizeSmall,
                                    )),
                                    selected: isCurrent,
                                    selectedColor: Theme.of(context).primaryColor,
                                    backgroundColor: Theme.of(context).cardColor,
                                    onSelected: (selected) {
                                      if (selected && !isCurrent) {
                                        chatController.switchActiveModule(mod);
                                      }
                                    },
                                  );
                                }).toList(),
                              );
                            }),
                            */

                            if (chatController.alerts.isNotEmpty) ...[
                              const Divider(height: 40),
                              Text(
                                "تنبيهاتك النشطة 🔔",
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chatController.alerts.length,
                                itemBuilder: (context, index) {
                                  final alert = chatController.alerts[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      leading: Icon(
                                        alert.type == 'discount' ? Icons.local_offer : Icons.fiber_new,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: Text(
                                        "قسم ${alert.categoryName}",
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      subtitle: Text(
                                        alert.type == 'discount' ? "تنبيه التخفيضات" : "تنبيه منتجات جديدة",
                                        style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => chatController.removeAlert(alert.id),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: chatController.messages.length + (chatController.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatController.messages.length) {
                        return const CustomLoaderWidget(size: 30);
                      }
                      return MessageBubble(message: chatController.messages[index]);
                    },
                  );
                }),
              ),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1, offset: const Offset(0, -2))],
                ),
                child: Column(
                  children: [
                    GetBuilder<CartController>(
                      builder: (cartCtrl) {
                        if (cartCtrl.cartList.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shopping_cart, size: 18, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "لديك ${cartCtrl.cartList.length} منتجات في السلة",
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "عرض السلة 🛒",
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    if (chatController.pickedImage != null)
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: kIsWeb ? NetworkImage(chatController.pickedImage!.path) : FileImage(File(chatController.pickedImage!.path)) as ImageProvider, 
                                fit: BoxFit.cover
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0, right: 0,
                            child: InkWell(
                              onTap: () => chatController.removeImage(),
                              child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 15, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                      
                    ValueListenableBuilder<bool>(
                      valueListenable: _isTyping,
                      builder: (context, isTyping, child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: AuthHelper.isLoggedIn() && !isTyping,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: false,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_photo_alternate, color: Theme.of(context).primaryColor),
                                    onPressed: () => chatController.pickImage(false),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                                    onPressed: () => chatController.pickImage(true),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                key: const ValueKey('chat_text_field_input'),
                                controller: _textController,
                                focusNode: _focusNode,
                                style: robotoRegular,
                                minLines: isTyping ? 2 : 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "ai_chat_input_hint".tr,
                                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).disabledColor.withOpacity(0.1),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onSubmitted: (value) => _sendMessage(chatController),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              heroTag: 'ai_chat_send_btn',
                              onPressed: () => _sendMessage(chatController),
                              mini: true,
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 0,
                              child: const Icon(Icons.send, color: Colors.white),
                            ),
                            Visibility(
                              visible: AuthHelper.isLoggedIn() && !isTyping,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: false,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FloatingActionButton(
                                  heroTag: 'ai_chat_mic_btn',
                                  onPressed: () => _listen(chatController),
                                  mini: true,
                                  backgroundColor: chatController.isListening ? Colors.red : Theme.of(context).primaryColor,
                                  elevation: 0,
                                  child: Icon(chatController.isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendMessage(AIChatController chatController) {
    if (_textController.text.trim().isNotEmpty) {
      chatController.sendMessage(_textController.text.trim());
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _listen(AIChatController chatController) {
    if (chatController.isListening) {
      chatController.stopListening();
    } else {
      chatController.startListening(onResult: (text) {
        _textController.text = text;
        _sendMessage(chatController);
      });
    }
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: 2),
                Text(subtitle, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}