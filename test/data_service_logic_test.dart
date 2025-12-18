import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_maker/services/data_service.dart';

void main() {
  group('DataService Background Selection Logic', () {
    final mockAssets = [
      'assets/images/love/bg1.png',
      'assets/images/motivation/bg1.png',
      'assets/images/funny/bg1.png',
      'assets/images/misc/bg1.png',
      'assets/images/misc/bg2.png',
    ];

    test('should retrieve matching category images', () {
      final result = DataService.getCategoryImages('Love', mockAssets);
      expect(result.first, contains('/love/'));
    });

    test('should handle normalization (Motivational -> motivation)', () {
      final result = DataService.getCategoryImages('Motivational', mockAssets);
      expect(result.first, contains('/motivation/'));
    });

    test('should fallback to misc if category folder not found', () {
      final result = DataService.getCategoryImages(
        'Festival Wishes',
        mockAssets,
      );
      expect(result.first, contains('/misc/'));
    });

    test('should fallback to misc for unknown category', () {
      final result = DataService.getCategoryImages(
        'Unknown Category',
        mockAssets,
      );
      expect(result.first, contains('/misc/'));
    });

    test(
      'should fallback to any asset if misc is empty (absolute fallback)',
      () {
        final noMiscAssets = ['assets/images/love/bg1.png'];
        final result = DataService.getCategoryImages('Unknown', noMiscAssets);
        // Should pick from what's available
        expect(result.first, contains('/love/'));
      },
    );

    test('should return hardcoded fallback if list is empty', () {
      final result = DataService.getCategoryImages('Love', []);
      expect(result.first, 'assets/images/bg1.png');
    });
  });
}
