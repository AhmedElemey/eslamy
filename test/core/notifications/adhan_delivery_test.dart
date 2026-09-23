import 'package:eslamy/core/notifications/adhan_delivery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('adhanDeliveryFor', () {
    final prayer = DateTime(2026, 9, 4, 17, 45);

    test('schedules a prayer that is still ahead', () {
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 17, 44, 59)),
        AdhanDelivery.schedule,
      );
    });

    test('shows immediately when hour and minute match, ignoring seconds', () {
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 17, 45)),
        AdhanDelivery.showNow,
      );
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 17, 45, 30)),
        AdhanDelivery.showNow,
      );
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 17, 45, 59)),
        AdhanDelivery.showNow,
      );
    });

    test('skips a prayer whose minute has already passed', () {
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 17, 46)),
        AdhanDelivery.skip,
      );
      expect(
        adhanDeliveryFor(prayer, DateTime(2026, 9, 4, 18, 0)),
        AdhanDelivery.skip,
      );
    });
  });
}
