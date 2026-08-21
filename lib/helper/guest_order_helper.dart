import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';

class GuestOrderModel {
  final int id;
  final String? contactNumber;
  final String? date;
  final String? status;

  GuestOrderModel({required this.id, this.contactNumber, this.date, this.status = 'pending'});

  Map<String, dynamic> toJson() => {
    'id': id,
    'contact_number': contactNumber,
    'date': date,
    'status': status,
  };

  factory GuestOrderModel.fromJson(Map<String, dynamic> json) => GuestOrderModel(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    contactNumber: json['contact_number']?.toString(),
    date: json['date']?.toString(),
    status: json['status']?.toString() ?? 'pending',
  );
}

class GuestOrderHelper {
  static const String _key = 'guest_orders_list';

  static Future<void> addGuestOrder(int orderId, String? contactNumber, {String status = 'pending'}) async {
    try {
      SharedPreferences prefs = Get.find<SharedPreferences>();
      List<String> list = prefs.getStringList(_key) ?? [];

      String phone = (contactNumber != null && contactNumber != 'null' && contactNumber.trim().isNotEmpty)
          ? contactNumber.trim()
          : (Get.isRegistered<AuthController>() ? Get.find<AuthController>().getGuestNumber().trim() : '');

      Map<String, dynamic> data = {
        'id': orderId,
        'contact_number': phone,
        'date': DateTime.now().toIso8601String(),
        'status': status,
      };

      list.removeWhere((item) {
        try {
          final decoded = jsonDecode(item);
          return decoded['id'].toString() == orderId.toString();
        } catch (e) {
          return false;
        }
      });

      list.insert(0, jsonEncode(data));
      await prefs.setStringList(_key, list);
    } catch (e) {
      // Ignore write errors
    }
  }

  static List<GuestOrderModel> getGuestOrders() {
    try {
      SharedPreferences prefs = Get.find<SharedPreferences>();
      List<String> list = prefs.getStringList(_key) ?? [];
      List<GuestOrderModel> result = [];
      for (String item in list) {
        try {
          result.add(GuestOrderModel.fromJson(jsonDecode(item)));
        } catch (e) {
          // Ignore invalid item
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  static Future<void> removeGuestOrder(int orderId) async {
    try {
      SharedPreferences prefs = Get.find<SharedPreferences>();
      List<String> list = prefs.getStringList(_key) ?? [];
      list.removeWhere((item) {
        try {
          final decoded = jsonDecode(item);
          return decoded['id'].toString() == orderId.toString();
        } catch (e) {
          return false;
        }
      });
      await prefs.setStringList(_key, list);
    } catch (e) {
      // Ignore write errors
    }
  }
}
