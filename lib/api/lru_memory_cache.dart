import 'dart:collection';
import 'package:flutter/widgets.dart';

/// An entry in the [LruMemoryCache] with expiration metadata and SWR support.
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  final DateTime staleUntil;
  int hitCount;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
    DateTime? staleUntil,
    this.hitCount = 1,
  }) : staleUntil = staleUntil ?? expiresAt.add(const Duration(seconds: 120));

  bool get isExpired => DateTime.now().isAfter(staleUntil);
  bool get isStale => DateTime.now().isAfter(expiresAt) && !isExpired;
}

/// A bounded Least-Recently-Used (LRU) in-memory cache with TTL support,
/// Stale-While-Revalidate (SWR) capabilities, pattern-based invalidation,
/// and automatic eviction on OS low-memory warnings via [WidgetsBindingObserver].
class LruMemoryCache<T> with WidgetsBindingObserver {
  final int maxEntries;
  final Duration defaultTtl;
  final Duration defaultStaleGracePeriod;
  final LinkedHashMap<String, _CacheEntry<T>> _map = LinkedHashMap<String, _CacheEntry<T>>();

  LruMemoryCache({
    this.maxEntries = 50,
    this.defaultTtl = const Duration(seconds: 60),
    this.defaultStaleGracePeriod = const Duration(seconds: 120),
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

  /// Retrieves a cached value if present and valid.
  /// Refreshes the entry's position to mark it as most-recently-used.
  /// If [allowStale] is true, returns value even if past TTL but within stale grace period.
  T? get(String key, {bool allowStale = false}) {
    final entry = _map.remove(key);
    if (entry == null) return null;

    // Hard expired
    if (entry.isExpired) {
      return null;
    }

    // Soft expired (stale), but caller does not permit stale data
    if (!allowStale && entry.isStale) {
      return null;
    }

    entry.hitCount++;
    // Re-insert at the end to mark as most recently used (LRU contract)
    _map[key] = entry;
    return entry.value;
  }

  /// Returns true if entry exists and is in the stale grace window (needs revalidation).
  bool isStale(String key) {
    final entry = _map[key];
    if (entry == null) return false;
    return entry.isStale;
  }

  /// Stores a value in the cache with a specified or default TTL and stale grace period.
  /// If capacity is exceeded, evicts the least-recently-used entry.
  void put(String key, T value, {Duration? ttl, Duration? staleGracePeriod}) {
    _map.remove(key);

    if (_map.length >= maxEntries) {
      // Remove least recently used (first key in LinkedHashMap)
      final oldestKey = _map.keys.first;
      _map.remove(oldestKey);
    }

    final effectiveTtl = ttl ?? defaultTtl;
    final effectiveGrace = staleGracePeriod ?? defaultStaleGracePeriod;
    final now = DateTime.now();

    _map[key] = _CacheEntry<T>(
      value: value,
      expiresAt: now.add(effectiveTtl),
      staleUntil: now.add(effectiveTtl + effectiveGrace),
    );
  }

  bool containsKey(String key, {bool allowStale = false}) {
    final entry = _map[key];
    if (entry == null) return false;
    if (entry.isExpired || (!allowStale && entry.isStale)) {
      _map.remove(key);
      return false;
    }
    return true;
  }

  void remove(String key) {
    _map.remove(key);
  }

  /// Removes all entries matching the given predicate.
  int removeMatching(bool Function(String key) predicate) {
    final keysToRemove = _map.keys.where(predicate).toList();
    for (final k in keysToRemove) {
      _map.remove(k);
    }
    return keysToRemove.length;
  }

  /// Removes all entries whose key contains [pattern].
  int removeContaining(String pattern) {
    return removeMatching((k) => k.contains(pattern));
  }

  /// Removes all entries whose key starts with [prefix].
  int removePrefix(String prefix) {
    return removeMatching((k) => k.startsWith(prefix));
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
