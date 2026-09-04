import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/api/cancellation_token.dart';
import 'package:sixam_mart/api/lru_memory_cache.dart';
import 'package:sixam_mart/api/data_module_manager.dart';
import 'package:sixam_mart/common/models/tab_pagination_state.dart';

void main() {
  group('CancellationToken Tests', () {
    test('Token initializes in non-cancelled state', () {
      final token = CancellationToken();
      expect(token.isCancelled, isFalse);
      expect(() => token.throwIfCancelled(), returnsNormally);
    });

    test('Cancelling token marks state and notifies listeners', () {
      final token = CancellationToken();
      bool listenerCalled = false;
      token.onCancel(() {
        listenerCalled = true;
      });

      token.cancel(reason: 'User switched tab');
      expect(token.isCancelled, isTrue);
      expect(token.cancelReason, equals('User switched tab'));
      expect(listenerCalled, isTrue);
      expect(() => token.throwIfCancelled(), throwsA(isA<CancellationException>()));
    });

    test('Attaching listener to already cancelled token fires immediately', () {
      final token = CancellationToken();
      token.cancel();
      bool immediateListenerCalled = false;
      token.onCancel(() {
        immediateListenerCalled = true;
      });
      expect(immediateListenerCalled, isTrue);
    });
  });

  group('LruMemoryCache Tests', () {
    test('Caches and retrieves items within TTL', () {
      final cache = LruMemoryCache<String>(maxEntries: 3, defaultTtl: const Duration(seconds: 10));
      cache.put('key1', 'value1');
      expect(cache.get('key1'), equals('value1'));
      expect(cache.containsKey('key1'), isTrue);
    });

    test('Evicts least recently used entry when capacity exceeded', () {
      final cache = LruMemoryCache<String>(maxEntries: 3, defaultTtl: const Duration(seconds: 10));
      cache.put('k1', 'v1');
      cache.put('k2', 'v2');
      cache.put('k3', 'v3');

      // Access k1 to make it most recently used
      cache.get('k1');

      // Add k4; since maxEntries is 3, k2 (least recently used) should be evicted
      cache.put('k4', 'v4');

      expect(cache.get('k1'), equals('v1'));
      expect(cache.get('k2'), isNull); // Evicted!
      expect(cache.get('k3'), equals('v3'));
      expect(cache.get('k4'), equals('v4'));
    });

    test('Flushes entries when system memory pressure is received', () {
      final cache = LruMemoryCache<String>(maxEntries: 10, defaultTtl: const Duration(seconds: 30));
      cache.put('k1', 'v1');
      cache.put('k2', 'v2');
      expect(cache.length, equals(2));

      // Simulate OS low-memory warning
      cache.handleMemoryPressure();
      expect(cache.length, equals(0));
      expect(cache.get('k1'), isNull);
    });

    test('Expired TTL entries return null', () async {
      final cache = LruMemoryCache<String>(maxEntries: 5, defaultTtl: const Duration(milliseconds: 50));
      cache.put('fast_expire', 'data');
      expect(cache.get('fast_expire'), equals('data'));

      await Future.delayed(const Duration(milliseconds: 70));
      expect(cache.get('fast_expire'), isNull);
    });
  });

  group('DataModuleManager Request Coalescing & Generation Tests', () {
    test('Coalesces concurrent identical requests into single Future', () async {
      final manager = DataModuleManager();
      int networkCallCount = 0;

      Future<String> mockFetch() async {
        networkCallCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return 'success_payload';
      }

      // Fire 5 concurrent requests for identical key
      final futures = List.generate(5, (_) => manager.coalesce('GET:/api/v1/items/popular', mockFetch));
      final results = await Future.wait(futures);

      expect(results.every((r) => r == 'success_payload'), isTrue);
      expect(networkCallCount, equals(1)); // Only 1 actual call executed!
    });

    test('Generation tokens properly track and invalidate stale requests', () {
      final manager = DataModuleManager();
      const contextKey = 'national_products_tab';

      final gen1 = manager.nextGeneration(contextKey);
      expect(manager.isGenerationActive(contextKey, gen1), isTrue);

      final gen2 = manager.nextGeneration(contextKey);
      expect(manager.isGenerationActive(contextKey, gen1), isFalse); // Old generation invalidated!
      expect(manager.isGenerationActive(contextKey, gen2), isTrue);
    });
  });

  group('TabPaginationState Isolation Tests', () {
    test('Isolated tab states keep their own offsets, items and cancel tokens', () {
      final popularTab = TabPaginationState<String>(tabKey: 'popular');
      final recommendedTab = TabPaginationState<String>(tabKey: 'recommended');

      popularTab.offset = 3;
      popularTab.items = ['pop_1', 'pop_2'];
      popularTab.activeCancelToken = CancellationToken();

      recommendedTab.offset = 1;
      recommendedTab.items = ['rec_1'];
      recommendedTab.activeCancelToken = CancellationToken();

      // Verify popular tab state does not affect recommended tab
      expect(popularTab.offset, equals(3));
      expect(recommendedTab.offset, equals(1));
      expect(popularTab.items!.length, equals(2));
      expect(recommendedTab.items!.length, equals(1));

      // Cancel popular tab's active token
      popularTab.cancelInFlight();
      expect(popularTab.activeCancelToken!.isCancelled, isTrue);
      expect(recommendedTab.activeCancelToken!.isCancelled, isFalse);
    });
  });
}
