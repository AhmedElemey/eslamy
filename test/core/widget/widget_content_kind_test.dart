import 'package:eslamy/core/widget/widget_content_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetContentKindX.storageKey', () {
    test('every kind has a distinct, stable storage key', () {
      final keys = WidgetContentKind.values.map((k) => k.storageKey).toSet();
      expect(keys, hasLength(WidgetContentKind.values.length));
      expect(keys, {'prayer', 'ayah', 'dua', 'hijri'});
    });
  });

  group('WidgetContentKindX.fromStorageKey', () {
    test('round-trips every kind through its own storage key', () {
      for (final kind in WidgetContentKind.values) {
        expect(WidgetContentKindX.fromStorageKey(kind.storageKey), kind);
      }
    });

    test('returns null for an unknown key', () {
      expect(WidgetContentKindX.fromStorageKey('not_a_kind'), isNull);
    });

    test('returns null for an empty key', () {
      expect(WidgetContentKindX.fromStorageKey(''), isNull);
    });

    test('is case-sensitive (no accidental case-folding)', () {
      expect(WidgetContentKindX.fromStorageKey('Prayer'), isNull);
    });
  });
}
