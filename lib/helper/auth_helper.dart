import 'package:get/get.dart';
import 'package:suliman/features/auth/controllers/auth_controller.dart';

class AuthHelper {
  static bool isGuestLoggedIn() {
    return Get.find<AuthController>().isGuestLoggedIn();
  }

  static String getGuestId() {
    return Get.find<AuthController>().getGuestId();
  }

  static bool isLoggedIn() {
    return Get.find<AuthController>().isLoggedIn();
  }

  static String getGuestEmail() {
    String guestId = getGuestId();
    if (guestId.isNotEmpty && guestId != '0' && guestId != 'null') {
      return 'guest$guestId@gmail.com';
    }
    return 'guest${DateTime.now().millisecondsSinceEpoch % 1000000}@gmail.com';
  }
}
