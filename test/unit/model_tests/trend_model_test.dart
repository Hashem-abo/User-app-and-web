import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/trends/domain/models/trend_model.dart';

void main() {
  group('TrendHashtagModel Deserialization & Serialization', () {
    test('fromMap creates valid TrendHashtagModel with empty items', () {
      final json = {
        'tag': 'summer_sale',
        'title': 'Summer Sale',
        'subtitle': 'Hot Deals',
        'cover_image': 'cover.jpg',
        'items': [],
      };

      final model = TrendHashtagModel.fromJson(json);

      expect(model.tag, equals('summer_sale'));
      expect(model.title, equals('Summer Sale'));
      expect(model.subtitle, equals('Hot Deals'));
      expect(model.coverImage, equals('cover.jpg'));
      expect(model.items, isEmpty);
    });

    test('toJson produces matching key-value pairs', () {
      final model = TrendHashtagModel(
        tag: 'fashion',
        title: 'Fashion Trends',
        subtitle: 'New Styles',
        coverImage: 'img.png',
        items: [],
      );

      final json = model.toJson();
      expect(json['tag'], equals('fashion'));
      expect(json['title'], equals('Fashion Trends'));
      expect(json['cover_image'], equals('img.png'));
    });

    test('fromJson handles null optional fields gracefully', () {
      final json = <String, dynamic>{};
      final model = TrendHashtagModel.fromJson(json);

      expect(model.tag, isNull);
      expect(model.title, isNull);
      expect(model.items, isEmpty);
    });

    test('fromJson throws exception when items is not a Iterable/List', () {
      final malformedJson = {
        'tag': 'tech',
        'items': 'not_a_list', // Sending string instead of List causes .forEach to crash
      };

      expect(
        () => TrendHashtagModel.fromJson(malformedJson),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });

  group('TrendBrandModel Deserialization & Serialization', () {
    test('fromJson creates valid TrendBrandModel', () {
      final json = {
        'name': 'Nike',
        'tagline': 'Just Do It',
        'logo': 'logo.png',
        'banner': 'banner.png',
        'items': [],
      };

      final model = TrendBrandModel.fromJson(json);
      expect(model.name, equals('Nike'));
      expect(model.tagline, equals('Just Do It'));
      expect(model.items, isEmpty);
    });

    test('fromJson throws exception when items is not a List', () {
      final malformedJson = {
        'name': 'Adidas',
        'items': 12345, // Invalid type
      };

      expect(
        () => TrendBrandModel.fromJson(malformedJson),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });
}
