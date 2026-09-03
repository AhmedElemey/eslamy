import 'package:eslamy/features/hajj_umrah/service/ritual_progress_service.dart';
import 'package:eslamy/features/hajj_umrah/service/tawaf_sai_counter_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RitualProgressService', () {
    late RitualProgressService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = RitualProgressService();
    });

    test('loadCompletedSteps returns an empty set when nothing is stored', () async {
      expect(await service.loadCompletedSteps(), isEmpty);
    });

    test('saveCompletedSteps then loadCompletedSteps round-trips', () async {
      await service.saveCompletedSteps({'ihram', 'tawaf', 'sai'});

      final loaded = await service.loadCompletedSteps();
      expect(loaded, {'ihram', 'tawaf', 'sai'});
    });

    test('saveCompletedSteps overwrites the previous set', () async {
      await service.saveCompletedSteps({'ihram'});
      await service.saveCompletedSteps({'tawaf', 'sai'});

      expect(await service.loadCompletedSteps(), {'tawaf', 'sai'});
    });

    test('saveCompletedSteps with an empty set clears stored steps', () async {
      await service.saveCompletedSteps({'ihram'});
      await service.saveCompletedSteps({});

      expect(await service.loadCompletedSteps(), isEmpty);
    });
  });

  group('TawafSaiCounterService', () {
    late TawafSaiCounterService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = TawafSaiCounterService();
    });

    test('getTawafCount defaults to 0 when nothing is stored', () async {
      expect(await service.getTawafCount(), 0);
    });

    test('getSaiCount defaults to 0 when nothing is stored', () async {
      expect(await service.getSaiCount(), 0);
    });

    test('setTawafCount then getTawafCount round-trips', () async {
      await service.setTawafCount(4);
      expect(await service.getTawafCount(), 4);
    });

    test('setSaiCount then getSaiCount round-trips', () async {
      await service.setSaiCount(5);
      expect(await service.getSaiCount(), 5);
    });

    test('Tawaf and Sa\'i counts are stored independently', () async {
      await service.setTawafCount(7);
      await service.setSaiCount(2);

      expect(await service.getTawafCount(), 7);
      expect(await service.getSaiCount(), 2);
    });
  });
}
