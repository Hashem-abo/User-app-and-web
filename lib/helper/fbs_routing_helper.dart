import 'package:geolocator/geolocator.dart';
import 'package:suliman/features/address/domain/models/address_model.dart';
import 'package:suliman/features/cart/domain/models/cart_model.dart';
import 'package:suliman/features/item/domain/models/item_model.dart';
import 'package:suliman/helper/address_helper.dart';

class FbsRoutingHelper {
  /// Calculate if FBS Hub is closer to the user than the merchant store
  static bool isHubCloserThanStore(Item? item, AddressModel? userAddress) {
    if (item == null) return false;
    
    AddressModel? address = userAddress ?? AddressHelper.getUserAddressFromSharedPref();
    if (address == null) return false;

    double? userLat = double.tryParse(address.latitude ?? '');
    double? userLng = double.tryParse(address.longitude ?? '');
    if (userLat == null || userLng == null) return false;

    double? storeLat = double.tryParse(item.storeLat ?? '');
    double? storeLng = double.tryParse(item.storeLng ?? '');

    if ((storeLat == null || storeLng == null) && item.storeDetails != null) {
      storeLat = double.tryParse(item.storeDetails!['latitude']?.toString() ?? '');
      storeLng = double.tryParse(item.storeDetails!['longitude']?.toString() ?? '');
    }

    double? hubLat = double.tryParse(item.hubLat ?? '');
    double? hubLng = double.tryParse(item.hubLng ?? '');

    if (storeLat == null || storeLng == null || hubLat == null || hubLng == null) {
      return false;
    }

    double distToStore = Geolocator.distanceBetween(userLat, userLng, storeLat, storeLng);
    double distToHub = Geolocator.distanceBetween(userLat, userLng, hubLat, hubLng);

    // Hub is strictly closer than merchant store
    return distToHub < distToStore;
  }

  /// Check if ALL items in the cart are available in a single FBS hub
  static bool areAllItemsAvailableInHub(List<CartModel> fullCartList) {
    if (fullCartList.isEmpty) return false;

    int? commonHubId;
    for (var c in fullCartList) {
      final item = c.item;
      if (item == null) return false;

      int hubStock = item.hubStock ?? 0;
      int qty = c.quantity ?? 1;
      int? hubId = item.nearestHubId;

      if (hubStock < qty || hubId == null || hubId <= 0) {
        return false;
      }

      if (commonHubId == null) {
        commonHubId = hubId;
      } else if (commonHubId != hubId) {
        return false;
      }
    }

    return true;
  }

  /// Get effective Store ID for routing and grouping in cart
  static int getEffectiveStoreId(CartModel cart, List<CartModel> fullCartList, [AddressModel? userAddress]) {
    final item = cart.item;
    if (item == null) return 0;

    int merchantStoreId = item.storeId ?? 0;
    int? hubId = item.nearestHubId;
    int hubStock = item.hubStock ?? 0;
    int qty = cart.quantity ?? 1;

    // If item is not in hub or hub has insufficient stock, stay in merchant store
    if (hubId == null || hubId <= 0 || hubStock < qty) {
      return merchantStoreId;
    }

    // Check if multi-store
    Set<int> distinctMerchantStoreIds = {};
    for (var c in fullCartList) {
      if (c.item?.storeId != null && c.item!.storeId! > 0) {
        distinctMerchantStoreIds.add(c.item!.storeId!);
      }
    }
    bool isMultiStore = distinctMerchantStoreIds.length > 1;

    if (isMultiStore) {
      // If ALL items from all stores are available in the hub -> consolidate to FBS Hub
      if (areAllItemsAvailableInHub(fullCartList)) {
        return hubId;
      }
      // If only some items are available in hub -> compare proximity for available items
      if (isHubCloserThanStore(item, userAddress)) {
        return hubId;
      } else {
        return merchantStoreId;
      }
    } else {
      // Single store order:
      // Item is available in hub -> compare proximity
      if (isHubCloserThanStore(item, userAddress)) {
        return hubId;
      } else {
        return merchantStoreId;
      }
    }
  }

  /// Get effective Store Name for cart display
  static String getEffectiveStoreName(CartModel cart, List<CartModel> fullCartList, [AddressModel? userAddress]) {
    final item = cart.item;
    if (item == null) return '';

    int effectiveId = getEffectiveStoreId(cart, fullCartList, userAddress);
    int? hubId = item.nearestHubId;

    if (hubId != null && effectiveId == hubId) {
      if (item.hubName != null && item.hubName!.trim().isNotEmpty) {
        return item.hubName!;
      }
      return 'مستودع المنصة المركزي (FBS)';
    }

    return item.storeName ?? '';
  }

  /// Whether the effective store for this cart item is FBS Hub
  static bool isEffectiveFbs(CartModel cart, List<CartModel> fullCartList, [AddressModel? userAddress]) {
    final item = cart.item;
    if (item == null || item.nearestHubId == null) return false;
    return getEffectiveStoreId(cart, fullCartList, userAddress) == item.nearestHubId;
  }
}
