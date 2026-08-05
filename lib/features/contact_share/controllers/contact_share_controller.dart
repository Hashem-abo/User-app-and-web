import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class ContactShareController extends GetxController implements GetxService {
  final ApiClient apiClient;
  ContactShareController({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Contact> _deviceContacts = [];
  List<Contact> get deviceContacts => _deviceContacts;

  List<dynamic> _matchedUsers = [];
  List<dynamic> get matchedUsers => _matchedUsers;

  List<Contact> _unmatchedContacts = [];
  List<Contact> get unmatchedContacts => _unmatchedContacts;

  List<Contact> _filteredUnmatchedContacts = [];
  List<Contact> get filteredUnmatchedContacts => _filteredUnmatchedContacts;

  List<dynamic> _filteredMatchedUsers = [];
  List<dynamic> get filteredMatchedUsers => _filteredMatchedUsers;

  String _searchQuery = '';

  Future<void> initSharing() async {
    _isLoading = true;
    _matchedUsers = [];
    _unmatchedContacts = [];
    _filteredMatchedUsers = [];
    _filteredUnmatchedContacts = [];
    _searchQuery = '';
    update();

    bool permissionGranted = await _requestContactsPermission();
    if (permissionGranted) {
      await _fetchAndMatchContacts();
    } else {
      _isLoading = false;
      update();
    }
  }

  Future<bool> _requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      PermissionStatus newStatus = await Permission.contacts.request();
      return newStatus.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Prompt user to open settings
      showCustomSnackBar('contacts_permission_denied_settings'.tr, isError: true);
    }
    return false;
  }

  Future<void> _fetchAndMatchContacts() async {
    try {
      // Fetch device contacts with phone numbers
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      _deviceContacts = contacts.where((c) => c.phones.isNotEmpty).toList();

      List<String> hashes = [];
      Map<String, Contact> hashToContactMap = {};

      for (var contact in _deviceContacts) {
        for (var phone in contact.phones) {
          // Clean phone number (keep digits only)
          String cleaned = phone.number.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleaned.isNotEmpty) {
            String hash = sha256.convert(utf8.encode(cleaned)).toString();
            hashes.add(hash);
            hashToContactMap[hash] = contact;
          }
        }
      }

      if (hashes.isEmpty) {
        _isLoading = false;
        update();
        return;
      }

      // Call matching endpoint
      Response response = await apiClient.postData(
        '/api/v1/customer/contacts/match',
        {'hashes': hashes},
      );

      if (response.statusCode == 200 && response.body != null) {
        List<dynamic> matchedList = response.body;
        _matchedUsers = matchedList;
        
        // Identify unmatched contacts to list under invite/external section
        Set<String> matchedNames = matchedList.map((m) => (m['name'] as String).toLowerCase()).toSet();
        _unmatchedContacts = _deviceContacts.where((c) {
          return !matchedNames.contains(c.displayName.toLowerCase());
        }).toList();

        _filteredMatchedUsers = List.from(_matchedUsers);
        _filteredUnmatchedContacts = List.from(_unmatchedContacts);
      } else {
        _unmatchedContacts = List.from(_deviceContacts);
        _filteredUnmatchedContacts = List.from(_unmatchedContacts);
      }
    } catch (e) {
      _unmatchedContacts = List.from(_deviceContacts);
      _filteredUnmatchedContacts = List.from(_unmatchedContacts);
    }

    _isLoading = false;
    update();
  }

  void searchContacts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMatchedUsers = List.from(_matchedUsers);
      _filteredUnmatchedContacts = List.from(_unmatchedContacts);
    } else {
      _filteredMatchedUsers = _matchedUsers.where((user) {
        return (user['name'] as String).toLowerCase().contains(query.toLowerCase());
      }).toList();

      _filteredUnmatchedContacts = _unmatchedContacts.where((contact) {
        return contact.displayName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  Future<bool> shareToUser({
    required int recipientId,
    required String shareableType,
    required int shareableId,
  }) async {
    _isLoading = true;
    update();

    Response response = await apiClient.postData(
      '/api/v1/customer/share',
      {
        'recipient_id': recipientId,
        'shareable_type': shareableType,
        'shareable_id': shareableId,
      },
    );

    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      showCustomSnackBar('shared_successfully'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBar(response.statusText ?? 'failed_to_share'.tr, isError: true);
      return false;
    }
  }

  void shareExternally(String shareUrl) {
    Share.share(shareUrl);
  }

  void copyLinkToClipboard(String shareUrl) {
    Clipboard.setData(ClipboardData(text: shareUrl));
    showCustomSnackBar('link_copied_to_clipboard'.tr, isError: false);
  }
}
