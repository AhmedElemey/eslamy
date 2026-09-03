import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:eslamy/core/widget/widget_content_kind.dart';
import 'package:eslamy/features/settings/service/settings_database.dart';

import '../../support/sqflite_ffi_setup.dart';

void main() {
  setUpAll(() async {
    initSqfliteFfiForTests();
    // The FFI backend writes a real file to disk that survives across
    // separate `flutter test` runs (unlike a fresh app install), so start
    // from a clean slate for the "defaults when unset" assertions below.
    final path = join(await getDatabasesPath(), 'settings.db');
    await deleteDatabase(path);
  });

  final db = SettingsDatabase();

  group('setValue/getValue', () {
    test('round-trips a stored value', () async {
      await db.setValue('some_key', 'some_value');
      expect(await db.getValue('some_key'), 'some_value');
    });

    test('overwriting a key replaces the old value', () async {
      await db.setValue('overwrite_key', 'first');
      await db.setValue('overwrite_key', 'second');
      expect(await db.getValue('overwrite_key'), 'second');
    });

    test('returns null for a key that was never set', () async {
      expect(await db.getValue('never_set_key_xyz'), isNull);
    });
  });

  group('getTimeValue/setTimeValue', () {
    test('round-trips a time value', () async {
      await db.setTimeValue('time_key', const TimeOfDay(hour: 14, minute: 30));
      final result = await db.getTimeValue('time_key');
      expect(result, const TimeOfDay(hour: 14, minute: 30));
    });

    test('zero-pads hour and minute when storing', () async {
      await db.setTimeValue('time_key', const TimeOfDay(hour: 5, minute: 5));
      expect(await db.getValue('time_key'), '05:05');
      expect(
        await db.getTimeValue('time_key'),
        const TimeOfDay(hour: 5, minute: 5),
      );
    });

    test('returns null when the key was never set', () async {
      expect(await db.getTimeValue('time_key_never_set'), isNull);
    });

    test('returns null for an empty stored value', () async {
      await db.setValue('time_key_empty', '');
      expect(await db.getTimeValue('time_key_empty'), isNull);
    });

    test('returns null for a malformed stored value', () async {
      await db.setValue('time_key_malformed', 'not-a-time');
      expect(await db.getTimeValue('time_key_malformed'), isNull);

      await db.setValue('time_key_malformed', '14');
      expect(await db.getTimeValue('time_key_malformed'), isNull);

      await db.setValue('time_key_malformed', '14:30:00');
      expect(await db.getTimeValue('time_key_malformed'), isNull);

      await db.setValue('time_key_malformed', 'aa:bb');
      expect(await db.getTimeValue('time_key_malformed'), isNull);
    });
  });

  group('getWerdTime/setWerdTime', () {
    test('delegates to the werd_time key', () async {
      await db.setWerdTime(const TimeOfDay(hour: 3, minute: 45));
      expect(
        await db.getWerdTime(),
        const TimeOfDay(hour: 3, minute: 45),
      );
      expect(await db.getValue('werd_time'), '03:45');
    });
  });

  group('getAdhanEnabled/setAdhanEnabled', () {
    test('defaults to true when unset', () async {
      // Runs before any other test in this file touches adhan_enabled.
      expect(await db.getValue('adhan_enabled'), isNull);
      expect(await db.getAdhanEnabled(), isTrue);
    });

    test('reflects setAdhanEnabled(false)', () async {
      await db.setAdhanEnabled(false);
      expect(await db.getAdhanEnabled(), isFalse);
    });

    test('reflects setAdhanEnabled(true)', () async {
      await db.setAdhanEnabled(true);
      expect(await db.getAdhanEnabled(), isTrue);
    });
  });

  group('getWidgetEnabledKinds/setWidgetEnabledKinds', () {
    test('defaults to all kinds when unset', () async {
      // Runs before any other test in this file touches widget_enabled_kinds.
      expect(await db.getValue('widget_enabled_kinds'), isNull);
      expect(await db.getWidgetEnabledKinds(), WidgetContentKind.values);
    });

    test('round-trips a specific subset and preserves order', () async {
      await db.setWidgetEnabledKinds([
        WidgetContentKind.dua,
        WidgetContentKind.prayer,
      ]);
      expect(await db.getWidgetEnabledKinds(), [
        WidgetContentKind.dua,
        WidgetContentKind.prayer,
      ]);
    });

    test(
      'falls back to all values when the stored string decodes to an empty list',
      () async {
        await db.setValue('widget_enabled_kinds', 'not_a_real_kind,also_bogus');
        expect(await db.getWidgetEnabledKinds(), WidgetContentKind.values);
      },
    );

    test('falls back to all values when stored as an empty string', () async {
      await db.setValue('widget_enabled_kinds', '');
      expect(await db.getWidgetEnabledKinds(), WidgetContentKind.values);
    });
  });
}
