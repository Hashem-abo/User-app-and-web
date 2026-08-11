import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/date_converter.dart';

void main() {
  group('DateConverter - Standard Parsing', () {
    test('formatDate should format DateTime correctly', () {
      final dt = DateTime(2026, 8, 11, 14, 30, 0);
      final formatted = DateConverter.formatDate(dt);
      expect(formatted, contains('2026-08-11'));
      expect(formatted, contains('02:30:00 PM'));
    });

    test('dateToDate should format yyyy-MM-dd', () {
      final dt = DateTime(2026, 1, 5);
      expect(DateConverter.dateToDate(dt), equals('2026-01-05'));
    });

    test('dateToReadableDate should format dd MMM, yyy', () {
      final dt = DateTime(2026, 12, 25);
      expect(DateConverter.dateToReadableDate(dt), equals('25 Dec, 2026'));
    });

    test('localDateToIsoString should format ISO timestamp', () {
      final dt = DateTime(2026, 8, 11, 10, 20, 30, 450);
      expect(DateConverter.localDateToIsoString(dt), equals('2026-08-11T10:20:30.450'));
    });

    test('convertFromMinute should format min/hour/day/week/month/year', () {
      expect(DateConverter.convertFromMinute(15, 30), contains('15-30'));
      expect(DateConverter.convertFromMinute(120, 180), contains('2-3'));
      expect(DateConverter.convertFromMinute(2880, 4320), contains('2-3'));
    });
  });

  group('DateConverter - Edge Cases & Robustness', () {
    test('containTAndZToUTCFormat handles short ISO strings without RangeError', () {
      const shortIso = '2026-08-11';
      expect(() => DateConverter.containTAndZToUTCFormat(shortIso), returnsNormally);
      final result = DateConverter.containTAndZToUTCFormat(shortIso);
      expect(result, contains('11 Aug, 2026'));
    });

    test('differenceInMinute handles null orderTime and scheduleAt safely without crashing', () {
      expect(
        DateConverter.differenceInMinute(null, null, null, null),
        equals(0),
      );
    });

    test('convertTodayYesterdayFormat handles current date', () {
      final today = DateTime.now();
      final formatted = DateConverter.convertTodayYesterdayFormat(today.toIso8601String());
      expect(formatted, contains('Today'));
    });

    test('convertTodayYesterdayFormat handles yesterday across month boundary', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final formatted = DateConverter.convertTodayYesterdayFormat(yesterday.toIso8601String());
      expect(formatted, contains('Yesterday'));
    });
  });
}
