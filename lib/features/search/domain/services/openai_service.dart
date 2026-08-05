import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/item/widgets/virtual_try_on_points_dialog.dart';
import 'package:sixam_mart/features/item/widgets/ai_limit_points_dialog.dart';

enum AiLimitStatus {
  allowed,
  limitReached,
  pointsApproved,
}

class OpenAIService {

  Future<Map<String, String>?> identifyItemFromImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": "You are a professional retail cataloging assistant. You identify products with high precision for an e-commerce database."
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Identify the primary product in this image. "
                      "Follow these rules strictly:\n"
                      "1. Return the output in a JSON format.\n"
                      "2. Include 'identified_item': the name in Arabic.\n"
                      "3. Include 'more_details': brief Arabic description or specs of the product.\n"
                      "4. Include 'optimized_query': an optimized search keyword in Arabic for a marketplace search engine.\n"
                      "5. Use standard commercial category names.\n"
                      "6. Do not include any English text, descriptions, or punctuation outside the keys.\n"
                      "7. If no clear retail product is found, set 'identified_item' to 'unknown'."
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "response_format": { "type": "json_object" },
          "temperature": 0.0,
          "max_tokens": 500
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          final Map<String, dynamic> decodedContent = jsonDecode(content);
          return decodedContent.map((key, value) => MapEntry(key, value.toString()));
        }
      } else {
        print('OpenAI API Error: ${response.body}');
      }
    } catch (e) {
      print('Error identifying item: $e');
    }
    return null;
  }

  Future<String?> getAccountAdvice(String productName, String description, String category, String variations, String storeName, String storeRating) async {
    try {
      final languageCode = Get.find<LocalizationController>().locale.languageCode;
      
      String storeInfoPrompt = "";
      String userContent = "Give me advice for this product:\nName: $productName\nDescription: $description\nCategory: $category\nVariations: $variations";
      
      if (storeRating != '0.0' && storeRating != '0') {
        storeInfoPrompt = "Include a brief comment about the seller (Store Name: $storeName, Rating: $storeRating) and whether they are highly rated. ";
        userContent += "\nStore Name: $storeName\nStore Rating: $storeRating";
      }

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful, creative, and expert shopping assistant.\n"
                  "Use Markdown headers (##) to divide your response into clear, interesting sections.\n"
                  "If the product is clothing, **START your response with a Markdown Table size chart** for the available sizes found in the variations (e.g., S: Bust 90cm, Waist 70cm) based on standard international sizing.\n"
                  "Rule for measurements:\n"
                  "1. For men's shirts or t-shirts: Include Neck, Shoulder, and Chest in cm.\n"
                  "2. For other shirts, t-shirts, sweaters, or dresses: Include Bust, Waist, and Hips in cm.\n"
                  "3. For jeans, trousers, shorts, or sweatpants: Include Waist, Hips, and Inseam in cm.\n"
                  "State clearly under the table that these are approximate estimates for guidance.\n\n"
                  "Then add a section 'Material & Quality' (translated to $languageCode), commenting on the likely material quality based on standard fabrics for this item type.\n"
                  "Then add a section 'Style Advice' (translated to $languageCode) to provide detailed, practical, and engaging fashion advice.\n"
                  "$storeInfoPrompt\n"
                  "Keep your advice engaging, well-structured, and easy to read (around 200-300 words). "
                  "Reply entirely in the language matching this code: $languageCode."
            },
            {
              "role": "user",
              "content": userContent
            }
          ],
          "max_tokens": 1000
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
        print('OpenAI API Error: ${response.body}');
      }
    } catch (e) {
      print('Error getting advice: $e');
    }
    return null;
  }

  Future<String?> analyzeEnvironment(XFile image, String productContext) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": "You are an expert interior designer and fashion stylist. Brief, helpful advice only (max 40 words)."
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Analyze this environment/person and the following product: $productContext. Provide specific advice on placement (for furniture) or styling (for wearables) based on what you see in the image."
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "max_tokens": 100
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
        print('OpenAI API Error: ${response.body}');
      }
    } catch (e) {
      print('Error analyzing environment: $e');
    }
    return null;
  }

  Future<String?> extractProductsFromText(String userVoiceInput) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant that extracts product names from user text. "
                   "Follow these rules:\n"
                    "1. Extract specific product names along with any mentioned attributes like color, type, or brand (e.g., 'red shirt', 'leather shoes').\n"
                    "2. If the user mentions multiple items or a recipe/idea, return the names of the required products separated by commas.\n"
                    "3. For example, 'tomato sauce, cheese, pepperoni, dough'.\n"
                    "4. Use the user's language (Arabic or English).\n"
                    "5. If no products can be derived, return 'unknown'."
            },
            {
              "role": "user",
              "content": "Convert the following idea into products: \"$userVoiceInput\""
            }
          ],
          "max_tokens": 50
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
        print('OpenAI API Error: ${response.body}');
      }
    } catch (e) {
      print('Error extracting products: $e');
    }
    return null;
  }
  Future<String?> getChatResponse(String message, {String? systemPrompt, List<Map<String, String>>? history}) async {
    try {
      final messages = [];
      if (systemPrompt != null) {
        messages.add({"role": "system", "content": systemPrompt});
      }
      
      if (history != null) {
        messages.addAll(history);
      }
      
      messages.add({"role": "user", "content": message});

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4-turbo", 
          "messages": messages,
          "max_tokens": 500
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
        throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
  Future<String?> getChatResponseWithImage(String message, XFile image, {String? systemPrompt}) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4o",
          "messages": [
            if (systemPrompt != null)
              {"role": "system", "content": systemPrompt},
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": message
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "max_tokens": 500
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
         throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> analyzeChatLogs(String adminPrompt, List<Map<String, dynamic>> logs) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        '/api/v1/ai/completions',
        {
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "system",
              "content": "You are a professional retail and customer experience business intelligence analyst. "
                  "You analyze chat logs of conversations between users and an AI shopping agent, extracting requested metrics, summaries, trends, and frequently asked questions."
            },
            {
              "role": "user",
              "content": "Here are the customer chat logs in JSON:\n${jsonEncode(logs)}\n\n"
                  "Please perform the following analysis: $adminPrompt\n"
                  "Provide the results as a detailed, structured Arabic report with headers and formatting."
            }
          ],
          "max_tokens": 1500,
          "temperature": 0.5
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content?.trim();
        }
      } else {
        throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in analyzeChatLogs: $e');
      return "عذراً، حدث خطأ أثناء إجراء التحليل: $e";
    }
    return null;
  }

  Future<AiLimitStatus> checkAiLimit(String actionType) async {
    try {
      final apiClient = Get.find<ApiClient>();
      String guestId = AuthHelper.getGuestId();
      final response = await apiClient.getData('/api/v1/ai/check-limit?action_type=$actionType&guest_id=$guestId');
      
      if (response.statusCode == 200) {
        if (response.body != null && response.body['allowed'] == false) {
          final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
          if (!isLoggedIn) {
            final message = response.body['message'] ?? 'عذراً، لقد وصلت إلى الحد اليومي.';
            showCustomSnackBar(message);
            return AiLimitStatus.limitReached;
          }

          final int cost = Get.find<SplashController>().configModel!.virtualTryOnLoyaltyPointCost ?? 10;
          final double currentPoints = (Get.find<ProfileController>().userInfoModel?.loyaltyPoint ?? 0).toDouble();

          if (currentPoints < cost) {
            Get.dialog(VirtualTryOnPointsDialog(cost: cost, currentPoints: currentPoints));
            return AiLimitStatus.limitReached;
          }

          AiLimitStatus status = AiLimitStatus.limitReached;
          await Get.dialog(
            AiLimitPointsDialog(
              cost: cost,
              currentPoints: currentPoints,
              onAccept: () {
                status = AiLimitStatus.pointsApproved;
              },
            ),
          );
          return status;
        }
        return AiLimitStatus.allowed;
      }
    } catch (e) {
      print('Error checking AI limit: $e');
    }
    // Default to allowed if API fails so we don't completely block the user on network issues
    return AiLimitStatus.allowed; 
  }

  Future<void> recordAiUsage(String actionType, {bool deductPoints = false}) async {
    try {
      final apiClient = Get.find<ApiClient>();
      String guestId = AuthHelper.getGuestId();
      await apiClient.postData('/api/v1/ai/record-usage', {
        'action_type': actionType,
        'guest_id': guestId,
        'deduct_points': deductPoints,
      });
    } catch (e) {
      print('Error recording AI usage: $e');
    }
  }
}
