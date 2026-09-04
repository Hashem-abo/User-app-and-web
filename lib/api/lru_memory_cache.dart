import 'dart:collection';
import 'package:flutter/widgets.dart';

/// An entry in the [LruMemoryCache] with expiration metadata.
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// A bounded Least-Recently-Used (LRU) in-memory cache with TTL support and
/// automatic eviction on OS low-memory warnings via [WidgetsBindingObserver].
class LruMemoryCache<T> with WidgetsBindingObserver {
  final int maxEntries;
  final Duration defaultTtl;
  final LinkedHashMap<String, _CacheEntry<T>> _map = LinkedHashMap<String, _CacheEntry<T>>();

  LruMemoryCache({
    this.maxEntries = 20,
    this.defaultTtl = const Duration(seconds: 60),
    bool registerMemoryObserver = true,
  }) {
    if (registerMemoryObserver) {
      try {
        WidgetsBinding.instance.addObserver(this);
      } catch (_) {
        // May fail in non-Flutter headless unit tests; handled gracefully.
      }
    }
  }

  int get length => _map.length;

  /// Retrieves a cached value if present and not expired.
  /// Refreshes the entry's position to mark it as most-recently-used.
  T? get(String key) {
    final entry = _map.remove(key);
    if (entry == null) return null;

    if (entry.isExpired) {
      return null;
    }

    // Re-insert at the end to mark as most recently used
    _map[key] = entry;
    return entry.value;
  }

  /// Stores a value in the cache with a specified or default TTL.
  /// If capacity is exceeded, evicts the least-recently-used entry.
  void put(String key, T value, {Duration? ttl}) {
    _map.remove(key);

    if (_map.length >= maxEntries) {
      // Remove least recently used (first key in LinkedHashMap)
      final oldestKey = _map.keys.first;
      _map.remove(oldestKey);
    }

    final effectiveTtl = ttl ?? defaultTtl;
    _map[key] = _CacheEntry<T>(
      value: value,
      expiresAt: DateTime.now().add(effectiveTtl),
    );
  }

  bool containsKey(String key) {
    final entry = _map[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _map.remove(key);
      return false;
    }
    return true;
  }

  void remove(String key) {
    _map.remove(key);
  }

  void clear() {
    _map.clear();
  }

  /// Handler for OS memory pressure warnings.
  /// Evicts all cached entries to immediately free heap memory.
  void handleMemoryPressure() {
    _map.clear();
  }

  @override
  void didHaveMemoryPressure() {
    handleMemoryPressure();
  }

  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    _map.clear();
  }
}
