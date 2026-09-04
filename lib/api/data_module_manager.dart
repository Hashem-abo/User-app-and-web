import 'dart:async';
import 'package:sixam_mart/api/lru_memory_cache.dart';

/// Central singleton coordinator for application-wide network request deduplication,
/// in-memory bounded LRU response caching, and tab/module request sequence generation.
class DataModuleManager {
  static final DataModuleManager _instance = DataModuleManager._internal();
  factory DataModuleManager() => _instance;
  DataModuleManager._internal();

  /// In-flight request map for coalescing simultaneous identical calls (thundering herd protection)
  final Map<String, Future<dynamic>> _inFlightRequests = {};

  /// Bounded LRU response cache (capped at 100 entries with 120s TTL by default)
  final LruMemoryCache<dynamic> _lruCache = LruMemoryCache<dynamic>(
    maxEntries: 100,
    defaultTtl: const Duration(seconds: 120),
    defaultStaleGracePeriod: const Duration(seconds: 180),
  );

  /// Generation tracking map keyed by context (e.g., 'national_products_tab', 'category_items', 'home_module')
  final Map<String, int> _contextGenerations = {};

  LruMemoryCache<dynamic> get cache => _lruCache;

  /// Invalidates cached entries by URI prefix
  void invalidatePrefix(String prefix) {
    _lruCache.removePrefix(prefix);
  }

  /// Invalidates cached entries whose keys match any of the given patterns
  void invalidatePatterns(List<String> patterns) {
    _lruCache.removeMatching((key) {
      for (final p in patterns) {
        if (key.contains(p)) return true;
      }
      return false;
    });
  }

  /// Coalesces concurrent identical asynchronous operations into a single Future.
  /// If a request with [key] is currently executing, subsequent callers await the same Future.
  Future<T> coalesce<T>(String key, Future<T> Function() fetcher) {
    if (_inFlightRequests.containsKey(key)) {
      return _inFlightRequests[key]! as Future<T>;
    }

    final completer = Completer<T>();
    _inFlightRequests[key] = completer.future;

    fetcher().then((result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }).catchError((error, stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }).whenComplete(() {
      _inFlightRequests.remove(key);
    });

    return completer.future;
  }

  /// Increments and returns the next active generation sequence for a given [contextKey].
  /// Any previously in-flight requests holding older generations will be marked stale.
  int nextGeneration(String contextKey) {
    final next = (_contextGenerations[contextKey] ?? 0) + 1;
    _contextGenerations[contextKey] = next;
    return next;
  }

  /// Checks whether a given [generation] is still the active generation for [contextKey].
  bool isGenerationActive(String contextKey, int generation) {
    return _contextGenerations[contextKey] == generation;
  }

  /// Explicitly invalidates any in-flight operations for a [contextKey].
  void invalidateContext(String contextKey) {
    _contextGenerations[contextKey] = (_contextGenerations[contextKey] ?? 0) + 1;
  }

  /// Generates a deterministic, canonical cache key for an endpoint and query parameters.
  static String buildCanonicalKey(String endpoint, {Map<String, dynamic>? query, int? moduleId, String? languageCode}) {
    final buffer = StringBuffer(endpoint);

    final params = <String, String>{};
    if (moduleId != null) {
      params['moduleId'] = moduleId.toString();
    }
    if (languageCode != null) {
      params['lang'] = languageCode;
    }
    if (query != null && query.isNotEmpty) {
      query.forEach((k, v) {
        if (v != null) {
          params[k] = v.toString();
        }
      });
    }

    if (params.isNotEmpty) {
      final sortedKeys = params.keys.toList()..sort();
      buffer.write('?');
      buffer.write(sortedKeys.map((k) => '$k=${Uri.encodeComponent(params[k]!)}').join('&'));
    }

    return buffer.toString();
  }

  /// Evicts all memory cache entries (called on low memory pressure or manual flush).
  void clearMemoryCache() {
    _lruCache.clear();
  }

  void handleMemoryPressure() {
    _lruCache.handleMemoryPressure();
  }
}
