import 'package:eslamy/features/hajj_umrah/data/hajj_umrah_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hajjUmrahDuas', () {
    test('every dua has a unique, non-empty id', () {
      final ids = hajjUmrahDuas.map((d) => d.id).toList();
      expect(ids, isNotEmpty);
      expect(ids.every((id) => id.isNotEmpty), isTrue);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test(
      'every dua has non-empty Arabic text and translation, unless it is a '
      '"no specific dua mandated" placeholder (empty arabic/translation but '
      'a note explaining why, e.g. farewell_tawaf)',
      () {
        for (final dua in hajjUmrahDuas) {
          if (dua.arabic.isEmpty) {
            expect(
              dua.note,
              isNotEmpty,
              reason:
                  'dua ${dua.id} has no Arabic text and no note explaining why',
            );
            continue;
          }
          expect(dua.translation, isNotEmpty, reason: 'dua ${dua.id}');
        }
      },
    );
  });

  group('hajjPhases and umrahPhases', () {
    test('phase ids are unique across both tracks', () {
      final ids = [...hajjPhases, ...umrahPhases].map((p) => p.id).toList();
      expect(ids, isNotEmpty);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test(
      'step ids are globally unique across every phase in both tracks '
      '(RitualProgressService persists completed step ids in one flat set, '
      'so a collision between two phases would mark the wrong step complete)',
      () {
        final allSteps = [
          ...hajjPhases,
          ...umrahPhases,
        ].expand((p) => p.steps).map((s) => s.id).toList();
        expect(allSteps, isNotEmpty);
        expect(allSteps.toSet(), hasLength(allSteps.length));
      },
    );

    test('every phase has at least one step', () {
      for (final phase in [...hajjPhases, ...umrahPhases]) {
        expect(phase.steps, isNotEmpty, reason: 'phase ${phase.id}');
      }
    });

    test('every duaId referenced by a phase exists in hajjUmrahDuas', () {
      final knownDuaIds = hajjUmrahDuas.map((d) => d.id).toSet();
      for (final phase in [...hajjPhases, ...umrahPhases]) {
        for (final duaId in phase.duaIds) {
          expect(
            knownDuaIds.contains(duaId),
            isTrue,
            reason: 'phase ${phase.id} references unknown dua "$duaId"',
          );
        }
      }
    });

    test('every phase has non-empty title, subtitle and overview', () {
      for (final phase in [...hajjPhases, ...umrahPhases]) {
        expect(phase.title, isNotEmpty, reason: 'phase ${phase.id}');
        expect(phase.subtitle, isNotEmpty, reason: 'phase ${phase.id}');
        expect(phase.overview, isNotEmpty, reason: 'phase ${phase.id}');
      }
    });
  });

  group('holySites', () {
    test('every site has a unique id', () {
      final ids = holySites.map((s) => s.id).toList();
      expect(ids, isNotEmpty);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('coordinates are within valid lat/lng ranges', () {
      for (final site in holySites) {
        expect(
          site.latitude,
          inInclusiveRange(-90.0, 90.0),
          reason: 'site ${site.id}',
        );
        expect(
          site.longitude,
          inInclusiveRange(-180.0, 180.0),
          reason: 'site ${site.id}',
        );
      }
    });

    test('geofence radius is positive', () {
      for (final site in holySites) {
        expect(site.radiusMeters, greaterThan(0), reason: 'site ${site.id}');
      }
    });

    test('relatedPhaseId, when set, references a real phase', () {
      final knownPhaseIds = [
        ...hajjPhases,
        ...umrahPhases,
      ].map((p) => p.id).toSet();
      for (final site in holySites) {
        final relatedId = site.relatedPhaseId;
        if (relatedId == null) continue;
        expect(
          knownPhaseIds.contains(relatedId),
          isTrue,
          reason: 'site ${site.id} references unknown phase "$relatedId"',
        );
      }
    });
  });
}
