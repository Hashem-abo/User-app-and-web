# ما تم تعديله على تطبيق المستخدم
2026/09/12

- **تحديث نموذج المنتج (Item Model):**
  - تم تعديل [item_model.dart](file:///e:/program/apk/User-app-and-web/lib/features/item/domain/models/item_model.dart) لاستقبال وتخزين بيانات المخزون الموحّد: `storeStock`، `hubStock`، وشارة الشحن السريع `isExpressAvailable` ووقت التوصيل السريع `expressDeliveryTime`.

- **شاشة تفاصيل المنتج (Item Details Screen & Title Widget):**
  - تم تعديل [item_title_view_widget.dart](file:///e:/program/apk/User-app-and-web/lib/features/item/widgets/item_title_view_widget.dart) لإظهار شارة المخزون الموحّد (رصيد المتجر + رصيد المستودع المركزي FBS)، مع شارة التوصيل السريع (Express) في حال توفر رصيد في **مستودعات المنصة المركزية (Platform Hubs / FBS)**.
  - تم تعديل [item_details_screen.dart](file:///e:/program/apk/User-app-and-web/lib/features/item/screens/item_details_screen.dart) لتأمين منطق فحص الكمية ومنع تصفير الرصيد عند التنقل بين التنوعات التي لا تملك رصيداً منفصلاً.

- **شاشة السلة وإتمام الطلب (Cart & Checkout Flow):**
  - تم تعديل [checkout_controller.dart](file:///e:/program/apk/User-app-and-web/lib/features/checkout/controllers/checkout_controller.dart) لإضافة إدارة حالة مسار التنفيذ (`fulfillmentType`: `platform_hub` أو `vendor`).
  - تم تعديل [top_section.dart](file:///e:/program/apk/User-app-and-web/lib/features/checkout/widgets/top_section.dart) لإضافة بطاقة اختيار خيار الشحن المزدوج:
    1. خيار **التوصيل السريع (FBS Express)**: شحن مباشر من **مستودعات المنصة المركزية (Platform Hubs / FBS)** خلال 15-30 دقيقة.
    2. خيار **التوصيل العادي من المتجر (Standard Store Delivery)**: شحن من المتجر مباشرة.
  - تم تعديل [place_order_body_model.dart](file:///e:/program/apk/User-app-and-web/lib/features/checkout/domain/models/place_order_body_model.dart) لتمرير حقل `fulfillment_type` في بيانات الطلب إلى الـ API.

- **حل مشكلة ظهور شريط "إنتهى من المخزن" (Out of Stock Bug Fix):**
  - تم تعديل دالة `isItemEntirelyOutOfStock` في [item_helper.dart](file:///e:/program/apk/User-app-and-web/lib/helper/item_helper.dart) لفحص توفر رصيد في **مخازن الإيداع والشحن (FBS)** (`hubStock > 0`) أو المخزون الموحّد/رصيد المتجر (`stock > 0` أو `storeStock > 0`) قبل تقييم التنوعات، لمنع اعتبار المنتج منتهياً بالخطأ عند وجود تنوعات صفرية غير مفعلة المخزون.
  - تم تأمين [item_bottom_sheet.dart](file:///e:/program/apk/User-app-and-web/lib/common/widgets/item_bottom_sheet.dart) لضمان اعتماد المخزون الموحّد للمنتج عند اختيار التنوعات الافتراضية.

- **الترجمة والنصوص (Localization):**
  - تم تحديث ملفات الترجمة العربية والإنجليزية [ar.json](file:///e:/program/apk/User-app-and-web/assets/language/ar.json) و [en.json](file:///e:/program/apk/User-app-and-web/assets/language/en.json) لإضافة كافة مفاتيح ونصوص الشحن السريع FBS والمخزون الموحّد.
