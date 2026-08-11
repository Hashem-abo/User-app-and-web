import 'package:get/get.dart';

class NotificationModel {
  int? id;
  Data? data;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;

  NotificationModel({this.id, this.data, this.createdAt, this.updatedAt, this.imageFullUrl});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class Data {
  String? _title;
  String? _description;
  String? imageFullUrl;
  String? type;

  String? get title => _translateNotificationTitle(_title);
  set title(String? value) => _title = value;

  String? get description => _translateNotificationDescription(_description);
  set description(String? value) => _description = value;

  Data({String? title, String? description, this.imageFullUrl, this.type}) {
    _title = title;
    _description = description;
  }

  Data.fromJson(Map<String, dynamic> json) {
    _title = json['title'];
    _description = json['description']?.toString();
    imageFullUrl = json['image_full_url'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = _title;
    data['description'] = _description;
    data['image_full_url'] = imageFullUrl;
    data['type'] = type;
    return data;
  }

  static String? _translateNotificationTitle(String? text) {
    if (text == null || text.isEmpty) return text;
    
    bool isArabic = false;
    try {
      isArabic = Get.locale?.languageCode == 'ar';
    } catch (_) {}

    String normalized = text.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (isArabic) {
      if (normalized.contains('placed')) {
        return 'تم تقديم الطلب';
      }
      if (normalized.contains('confirm')) {
        return 'تم تأكيد الطلب';
      }
      if (normalized.contains('accept')) {
        return 'تم قبول الطلب';
      }
      if (normalized.contains('process') || normalized.contains('cook') || normalized.contains('prepar')) {
        return 'جاري تحضير الطلب';
      }
      if (normalized.contains('delivery') || normalized.contains('picked') || normalized.contains('way') || normalized.contains('ship')) {
        return 'طلبك في الطريق';
      }
      if (normalized.contains('deliver')) {
        return 'تم تسليم الطلب';
      }
      if (normalized.contains('cancel')) {
        return 'تم إلغاء الطلب';
      }
      if (normalized.contains('refund')) {
        return 'تم استرداد المبلغ';
      }
      if (normalized.contains('assign')) {
        return 'تم تعيين مندوب التوصيل';
      }
      if (normalized.contains('schedule')) {
        return 'طلب مجدول';
      }
      if (normalized.contains('otp') || normalized.contains('verification') || normalized.contains('code')) {
        return 'رمز تحقق الاستلام';
      }
      if (normalized.contains('fail')) {
        return 'فشل توصيل الطلب';
      }
      if (normalized.contains('reject')) {
        return 'تم رفض الطلب';
      }
      if (normalized.contains('refer') || normalized.contains('earn')) {
        return 'دعوة الأصدقاء والربح';
      }
      if (normalized.contains('order notification')) {
        return 'إشعارات الطلبات';
      }
      if (normalized.contains('congratulation') || normalized.contains('congrats')) {
        return 'تهانينا!';
      }
    } else {
      if (text.contains('تقديم') || text.contains('طلبك بنجاح')) return 'Order Placed';
      if (text.contains('تأكيد')) return 'Order Confirmed';
      if (text.contains('قبول')) return 'Order Accepted';
      if (text.contains('تحضير') || text.contains('تجهيز')) return 'Order Processing';
      if (text.contains('طريق') || text.contains('خارج للتوصيل')) return 'Out for Delivery';
      if (text.contains('تسليم') || text.contains('توصيل') || text.contains('تنفيذ')) return 'Order Delivered';
      if (text.contains('إلغاء')) return 'Order Cancelled';
      if (text.contains('استرداد')) return 'Order Refunded';
      if (text.contains('تعيين') || text.contains('مندوب')) return 'Delivery Partner Assigned';
      if (text.contains('مجدول')) return 'Scheduled Order';
      if (text.contains('رمز') || text.contains('تحقق')) return 'Verification Code';
      if (text.contains('تهانينا') || text.contains('مبروك')) return 'Congratulations!';
      if (text.contains('إشعار') || text.contains('إشعارات')) return 'Order Notification';
    }

    return text;
  }

  static String? _translateNotificationDescription(String? text) {
    if (text == null || text.isEmpty) return text;
    try {
      if (Get.locale?.languageCode != 'ar') {
        if (text.contains('تقديم')) return 'Your order has been placed successfully.';
        if (text.contains('تأكيد')) return 'Your order has been confirmed and is being processed.';
        if (text.contains('قبول')) return 'Your order has been accepted by the store/pharmacy.';
        if (text.contains('تحضير') || text.contains('تجهيز')) return 'Your order is currently being prepared.';
        if (text.contains('طريق') || text.contains('خارج للتوصيل')) return 'Your order is out for delivery.';
        if (text.contains('تسليم') || text.contains('توصيل') || text.contains('تنفيذ')) {
          return 'Your order has been delivered successfully. Thank you!';
        }
        if (text.contains('إلغاء')) return 'Your order has been cancelled successfully.';
        if (text.contains('استرداد')) return 'Your order amount has been refunded to your account.';
        if (text.contains('تعيين') || text.contains('مندوب')) return 'A delivery partner has been assigned to your order.';
        if (text.contains('مجدول')) return 'Your order has been scheduled for delivery.';
        if (text.contains('رمز') || text.contains('تحقق')) {
          String code = text.replaceAll(RegExp(r'\D'), '');
          if (code.isNotEmpty) {
            return 'Your order delivery verification code is: $code';
          }
          return 'Verification code for your order delivery has been generated.';
        }
        if (text.contains('تهانينا') || text.contains('مبروك')) return 'Congratulations! You have received a new reward.';
        
        return text;
      }
    } catch (_) {
      return text;
    }

    String normalized = text.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (normalized.contains('placed')) {
      return 'تم تقديم طلبك بنجاح.';
    }
    if (normalized.contains('confirm')) {
      return 'تم تأكيد طلبك بنجاح وجاري العمل عليه.';
    }
    if (normalized.contains('accept')) {
      return 'تم قبول طلبك من قبل المتجر/الصيدلية.';
    }
    if (normalized.contains('process') || normalized.contains('cook') || normalized.contains('prepar')) {
      return 'طلبك قيد التحضير والتجهيز الآن.';
    }
    if (normalized.contains('delivery') || normalized.contains('picked') || normalized.contains('way') || normalized.contains('ship')) {
      return 'طلبك خارج للتوصيل وفي الطريق إليك مع مندوب التوصيل.';
    }
    if (normalized.contains('deliver')) {
      return 'تم توصيل وتسليم طلبك بنجاح، شكراً لتعاملك معنا.';
    }
    if (normalized.contains('cancel')) {
      return 'تم إلغاء طلبك بنجاح.';
    }
    if (normalized.contains('refund')) {
      return 'تم استرداد مبلغ طلبك بنجاح إلى حسابك.';
    }
    if (normalized.contains('assign')) {
      return 'تم تعيين مندوب توصيل لطلبك وجاري تجهيزه للتوصيل.';
    }
    if (normalized.contains('schedule')) {
      return 'تم جدولة طلبك للتوصيل في الوقت المحدد مسبقاً.';
    }
    if (normalized.contains('otp') || normalized.contains('verification') || normalized.contains('code')) {
      String code = text.replaceAll(RegExp(r'\D'), '');
      if (code.isNotEmpty) {
        return 'رمز التحقق الخاص بتأكيد استلام طلبك هو: $code';
      }
      return 'تم إصدار رمز التحقق الخاص باستلام طلبك.';
    }
    if (normalized.contains('fail')) {
      return 'لم نتمكن من توصيل طلبك بنجاح، يرجى التواصل مع الدعم.';
    }
    if (normalized.contains('reject')) {
      return 'تم رفض طلبك من قبل المتجر/الصيدلية.';
    }
    if (normalized.contains('congratulation') || normalized.contains('congrats')) {
      return 'تهانينا! لقد حصلت على مكافأة أو هدية جديدة.';
    }
    if (normalized.contains('order notification')) {
      return 'إشعار جديد بخصوص حالة طلبك.';
    }

    return text;
  }
}
