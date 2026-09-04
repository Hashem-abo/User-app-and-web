import 'package:sixam_mart/api/cancellation_token.dart';

/// Encapsulates isolated pagination and lifecycle state for a specific tab or filter category.
/// Guarantees that offsets, items, and in-flight cancellation tokens remain isolated per tab.
class TabPaginationState<T> {
  final String tabKey;
  List<T>? items;
  int offset = 1;
  final Set<String> inFlightOffsets = {};
  final Set<String> loadedOffsets = {};
  int? totalSize;
  int currentModuleIndex = 0;
  bool isLoading = false;
  bool isLoaded = false;
  CancellationToken? activeCancelToken;
  int requestGeneration = 0;

  TabPaginationState({required this.tabKey});

  /// Cancels any active in-flight HTTP connection for this tab.
  void cancelInFlight() {
    if (activeCancelToken != null && !activeCancelToken!.isCancelled) {
      activeCancelToken!.cancel(reason: 'Tab cancelled or switched');
    }
    inFlightOffsets.clear();
  }

  /// Creates and registers a new [CancellationToken], aborting the previous active token if any.
  CancellationToken createNewToken() {
    cancelInFlight();
    final token = CancellationToken();
    activeCancelToken = token;
    requestGeneration++;
    return token;
  }

  /// Resets this tab's pagination state, clearing items and cancelling in-flight operations.
  void reset() {
    cancelInFlight();
    items = null;
    offset = 1;
    loadedOffsets.clear();
    inFlightOffsets.clear();
    totalSize = null;
    currentModuleIndex = 0;
    isLoading = false;
    isLoaded = false;
    requestGeneration++;
  }
}
