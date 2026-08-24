import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eslamy/core/notifications/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  const pluginChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezoneChannel = MethodChannel('flutter_timezone');

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pluginChannel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'createNotificationChannel':
              return null;
            case 'deleteNotificationChannel':
              return null;
            case 'show':
              return null;
            default:
              return null;
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, (call) async {
          if (call.method == 'getLocalTimezone') return 'UTC';
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pluginChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, null);
  });

  test('init() sends the @mipmap/ic_launcher small icon to the platform side', () async {
    await NotificationService().init();

    final initializeCall = calls.firstWhere((c) => c.method == 'initialize');
    expect(
      (initializeCall.arguments as Map)['defaultIcon'],
      '@mipmap/ic_launcher',
    );

    final channelCalls = calls
        .where((c) => c.method == 'createNotificationChannel')
        .toList();
    expect(channelCalls.length, 2);
  });

  test('showNow() fires a show call without throwing', () async {
    await NotificationService().showNow(title: 'Test', body: 'Body');
    final showCall = calls.firstWhere((c) => c.method == 'show');
    expect(showCall.arguments['title'], 'Test');
    expect(showCall.arguments['body'], 'Body');
  });
}
