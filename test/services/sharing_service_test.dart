import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/models.dart';
import 'package:hijri_minder/services/sharing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SharingService', () {
    late SharingService service;
    late PersonalizedMessage testMessage;

    setUp(() {
      service = SharingService();
      testMessage = PersonalizedMessage(
        content: 'Happy birthday, Ahmad! May Allah bless you.',
        recipientName: 'Ahmad',
        relationship: 'brother',
        language: 'en',
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );
    });

    group('copyToClipboard', () {
      test('should copy message to clipboard successfully', () async {
        // Mock the clipboard
        const channel = MethodChannel('flutter/platform');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        final result = await service.copyToClipboard('Test message');

        expect(result, isTrue);
        expect(log, hasLength(1));
        expect(log.first.method, equals('Clipboard.setData'));
        expect(log.first.arguments['text'], equals('Test message'));
      });

      test('should handle clipboard errors gracefully', () async {
        const channel = MethodChannel('flutter/platform');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error', message: 'Clipboard error');
        });

        final result = await service.copyToClipboard('Test message');

        expect(result, isFalse);
      });
    });

    group('shareWithAppInvitation', () {
      test('should add app invitation to message content', () async {
        // Mock the sharing channel
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        await service.shareWithAppInvitation(testMessage);

        expect(log, hasLength(1));
        expect(log.first.method, equals('shareText'));
        
        final sharedText = log.first.arguments['text'] as String;
        expect(sharedText, contains(testMessage.content));
        expect(sharedText, contains('HijriMinder'));
        expect(sharedText, contains('Islamic Calendar App'));
      });
    });

    group('createSocialMediaContent', () {
      test('should create decorated content with hashtags', () async {
        final result = await service.createSocialMediaContent(
          testMessage,
          includeHashtags: true,
        );

        expect(result, contains(testMessage.content));
        expect(result, contains('#IslamicCalendar'));
        expect(result, contains('#HijriDate'));
        expect(result, contains('#MuslimFamily'));
        expect(result, contains('🌙✨'));
      });

      test('should create content without hashtags when disabled', () async {
        final result = await service.createSocialMediaContent(
          testMessage,
          includeHashtags: false,
        );

        expect(result, contains(testMessage.content));
        expect(result, isNot(contains('#IslamicCalendar')));
        expect(result, contains('🌙✨')); // Should still have decoration
      });

      test('should use appropriate hashtags for different languages', () async {
        final arabicMessage = testMessage.copyWith(language: 'ar');
        final result = await service.createSocialMediaContent(
          arabicMessage,
          includeHashtags: true,
        );

        expect(result, contains('#التقويم_الهجري'));
        expect(result, contains('#التاريخ_الهجري'));
      });
    });

    group('app availability', () {
      test('should handle app availability check', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppAvailable') {
            final package = methodCall.arguments['package'] as String;
            return package == 'com.whatsapp'; // Only WhatsApp is "available"
          }
          return false;
        });

        final whatsappAvailable = await service.isAppAvailable('com.whatsapp');
        final telegramAvailable = await service.isAppAvailable('org.telegram.messenger');

        expect(whatsappAvailable, isTrue);
        expect(telegramAvailable, isFalse);
      });

      test('should handle platform exceptions in app availability', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error', message: 'Platform error');
        });

        final result = await service.isAppAvailable('com.whatsapp');

        expect(result, isFalse);
      });
    });

    group('getAvailableSharingApps', () {
      test('should return list of available apps', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getAvailableApps') {
            return [
              {
                'name': 'WhatsApp',
                'packageName': 'com.whatsapp',
                'iconPath': '/path/to/icon',
                'isInstalled': true,
              },
              {
                'name': 'Telegram',
                'packageName': 'org.telegram.messenger',
                'iconPath': '/path/to/icon',
                'isInstalled': false,
              },
            ];
          }
          return [];
        });

        final apps = await service.getAvailableSharingApps();

        expect(apps, hasLength(2));
        expect(apps.first.name, equals('WhatsApp'));
        expect(apps.first.packageName, equals('com.whatsapp'));
        expect(apps.first.isInstalled, isTrue);
        expect(apps.last.isInstalled, isFalse);
      });

      test('should handle empty app list', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return [];
        });

        final apps = await service.getAvailableSharingApps();

        expect(apps, isEmpty);
      });

      test('should handle platform exceptions', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error', message: 'Platform error');
        });

        final apps = await service.getAvailableSharingApps();

        expect(apps, isEmpty);
      });
    });

    group('shareMessage', () {
      test('should call platform method with correct parameters', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        final result = await service.shareMessage(testMessage);

        expect(result, isTrue);
        expect(log, hasLength(1));
        expect(log.first.method, equals('shareText'));
        expect(log.first.arguments['text'], equals(testMessage.content));
        expect(log.first.arguments['subject'], equals('Birthday Wishes'));
      });

      test('should handle platform exceptions', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error', message: 'Sharing failed');
        });

        final result = await service.shareMessage(testMessage);

        expect(result, isFalse);
      });
    });

    group('shareToApp', () {
      test('should call platform method with app package', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        final result = await service.shareToApp(testMessage, 'com.whatsapp');

        expect(result, isTrue);
        expect(log, hasLength(1));
        expect(log.first.method, equals('shareToApp'));
        expect(log.first.arguments['text'], equals(testMessage.content));
        expect(log.first.arguments['package'], equals('com.whatsapp'));
      });
    });

    group('localization', () {
      test('should provide correct share subjects for different languages', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        // Test Arabic
        final arabicMessage = testMessage.copyWith(language: 'ar');
        await service.shareMessage(arabicMessage);
        expect(log.last.arguments['subject'], equals('تهنئة بالمولد'));

        // Test Indonesian
        final indonesianMessage = testMessage.copyWith(language: 'id');
        await service.shareMessage(indonesianMessage);
        expect(log.last.arguments['subject'], equals('Ucapan Ulang Tahun'));

        // Test Urdu
        final urduMessage = testMessage.copyWith(language: 'ur');
        await service.shareMessage(urduMessage);
        expect(log.last.arguments['subject'], equals('سالگرہ کی مبارکباد'));
      });

      test('should provide appropriate app invitation text for different languages', () async {
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        // Test Arabic invitation
        final arabicMessage = testMessage.copyWith(language: 'ar');
        await service.shareWithAppInvitation(arabicMessage);
        
        final sharedText = log.last.arguments['text'] as String;
        expect(sharedText, contains('التقويم الهجري'));
        expect(sharedText, contains('حمل الآن'));
      });
    });

    group('SharingApp model', () {
      test('should create SharingApp from map correctly', () {
        final map = {
          'name': 'WhatsApp',
          'packageName': 'com.whatsapp',
          'iconPath': '/path/to/icon',
          'isInstalled': true,
        };

        final app = SharingApp.fromMap(map);

        expect(app.name, equals('WhatsApp'));
        expect(app.packageName, equals('com.whatsapp'));
        expect(app.iconPath, equals('/path/to/icon'));
        expect(app.isInstalled, isTrue);
      });

      test('should convert SharingApp to map correctly', () {
        const app = SharingApp(
          name: 'Telegram',
          packageName: 'org.telegram.messenger',
          iconPath: '/path/to/telegram',
          isInstalled: false,
        );

        final map = app.toMap();

        expect(map['name'], equals('Telegram'));
        expect(map['packageName'], equals('org.telegram.messenger'));
        expect(map['iconPath'], equals('/path/to/telegram'));
        expect(map['isInstalled'], isFalse);
      });
    });

    group('popular apps constants', () {
      test('should contain expected popular app packages', () {
        expect(SharingService.popularApps['whatsapp'], equals('com.whatsapp'));
        expect(SharingService.popularApps['telegram'], equals('org.telegram.messenger'));
        expect(SharingService.popularApps['messenger'], equals('com.facebook.orca'));
        expect(SharingService.popularApps['instagram'], equals('com.instagram.android'));
        expect(SharingService.popularApps['twitter'], equals('com.twitter.android'));
        expect(SharingService.popularApps['facebook'], equals('com.facebook.katana'));
      });
    });
  });
}