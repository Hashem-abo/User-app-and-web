import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

void main() {
  group('ItemModel Deserialization - Safe Architecture (Fixed)', () {
    test('ItemModel.fromJson with products key works cleanly', () {
      final json = {
        'total_size': 1,
        'limit': '10',
        'offset': 1,
        'products': [],
      };

      final model = ItemModel.fromJson(json);
      expect(model.totalSize, equals(1));
      expect(model.limit, equals('10'));
      expect(model.items, isEmpty);
    });

    test('ItemModel.fromJson with items key parses safely without SplashController in memory', () {
      final json = {
        'total_size': 1,
        'limit': '10',
        'offset': 1,
        'items': [
          {'id': 1, 'name': 'Sample Item', 'module_type': 'grocery'}
        ],
      };

      expect(() => ItemModel.fromJson(json), returnsNormally);
      final model = ItemModel.fromJson(json);
      expect(model.items, isNotNull);
      expect(model.items!.length, equals(1));
      expect(model.items!.first.id, equals(1));
      expect(model.items!.first.name, equals('Sample Item'));
    });
  });
}
