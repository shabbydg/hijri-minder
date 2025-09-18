import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/models.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/services/message_templates_service.dart';
import 'package:hijri_minder/services/sharing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Task 12 - Messaging System Integration Tests', () {
    late MessageTemplatesService messageService;
    late SharingService sharingService;

    setUpAll(() async {
      // Initialize services
      await ServiceLocator.setupServices();
      messageService = ServiceLocator.messageTemplatesService;
      sharingService = ServiceLocator.sharingService;
    });

    tearDownAll(() async {
      await ServiceLocator.reset();
    });

    group('Message Template Generation Flow', () {
      test('should generate personalized birthday message in multiple languages', () {
        const recipientName = 'Ahmad';
        const relationship = 'brother';
        
        // Test English
        final englishTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'en');
        expect(englishTemplates, isNotEmpty);
        
        final englishMessage = messageService.generatePersonalizedMessage(
          englishTemplates.first,
          recipientName,
          relationship,
          'en',
        );
        
        expect(englishMessage, contains('Ahmad'));
        expect(englishMessage, anyOf([contains('brother'), isNot(contains('{relationship}'))]));
        expect(englishMessage, contains('Allah'));
        
        // Test Arabic
        final arabicTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'ar');
        expect(arabicTemplates, isNotEmpty);
        
        final arabicMessage = messageService.generatePersonalizedMessage(
          arabicTemplates.first,
          recipientName,
          relationship,
          'ar',
        );
        
        expect(arabicMessage, contains('Ahmad'));
        expect(arabicMessage, anyOf([contains('أخي'), isNot(contains('{relationship}'))])); // Arabic for brother
        expect(arabicMessage, contains('الله'));
      });

      test('should generate anniversary messages with Islamic elements', () {
        const recipientName = 'Fatima';
        const relationship = 'wife';
        
        final templates = messageService.getMessageTemplates(ReminderType.anniversary, 'en');
        expect(templates, isNotEmpty);
        
        final message = messageService.generatePersonalizedMessage(
          templates.first,
          recipientName,
          relationship,
          'en',
        );
        
        expect(message, contains('Fatima'));
        expect(message, anyOf([contains('wife'), isNot(contains('{relationship}'))]));
        expect(message, anyOf([
          contains('Allah'),
          contains('bless'),
          contains('marriage'),
          contains('anniversary'),
        ]));
      });

      test('should generate respectful religious messages', () {
        const recipientName = 'Abdullah';
        const relationship = 'father';
        
        final templates = messageService.getMessageTemplates(ReminderType.religious, 'en');
        expect(templates, isNotEmpty);
        
        final message = messageService.generatePersonalizedMessage(
          templates.first,
          recipientName,
          relationship,
          'en',
        );
        
        expect(message, contains('Abdullah'));
        expect(message, anyOf([
          contains('Allah'),
          contains('mercy'),
          contains('Jannah'),
          contains('peace'),
          contains('Inna lillahi'),
        ]));
      });
    });

    group('Islamic Greeting Templates', () {
      test('should provide authentic Islamic greetings in multiple languages', () {
        // Test English greetings
        final englishGreetings = messageService.getIslamicGreetingTemplates('en');
        expect(englishGreetings, isNotEmpty);
        expect(englishGreetings.any((g) => g.contains('Assalamu Alaikum')), isTrue);
        expect(englishGreetings.any((g) => g.contains('Barakallahu')), isTrue);
        expect(englishGreetings.any((g) => g.contains('Quran')), isTrue);
        
        // Test Arabic greetings
        final arabicGreetings = messageService.getIslamicGreetingTemplates('ar');
        expect(arabicGreetings, isNotEmpty);
        expect(arabicGreetings.any((g) => g.contains('السلام عليكم')), isTrue);
        expect(arabicGreetings.any((g) => g.contains('بارك الله')), isTrue);
        
        // Test Indonesian greetings
        final indonesianGreetings = messageService.getIslamicGreetingTemplates('id');
        expect(indonesianGreetings, isNotEmpty);
        expect(indonesianGreetings.any((g) => g.contains('Assalamu\'alaikum')), isTrue);
        expect(indonesianGreetings.any((g) => g.contains('Barakallahu')), isTrue);
      });

      test('should provide religious anniversary templates with Quranic verses', () {
        final templates = messageService.getReligiousAnniversaryTemplates('en');
        expect(templates, isNotEmpty);
        expect(templates.any((t) => t.contains('Quran')), isTrue);
        expect(templates.any((t) => t.contains('Allah')), isTrue);
        expect(templates.any((t) => t.contains('blessed')), isTrue);
      });
    });

    group('Language Support Validation', () {
      test('should support all declared languages for all reminder types', () {
        for (final language in MessageTemplatesService.supportedLanguages) {
          for (final type in ReminderType.values) {
            final templates = messageService.getMessageTemplates(type, language);
            expect(templates, isNotEmpty, 
              reason: 'Language $language should have templates for $type');
            
            // Each template should be meaningful (not too short)
            for (final template in templates) {
              expect(template.trim().length, greaterThan(10),
                reason: 'Template should be meaningful: $template');
            }
          }
        }
      });

      test('should localize relationship terms correctly', () {
        const relationships = ['mother', 'father', 'brother', 'sister', 'son', 'daughter'];
        const template = 'Hello {relationship}';
        
        for (final relationship in relationships) {
          // Test Arabic localization
          final arabicMessage = messageService.generatePersonalizedMessage(
            template,
            'Test',
            relationship,
            'ar',
          );
          expect(arabicMessage, isNot(contains(relationship)),
            reason: 'Arabic should translate relationship: $relationship');
          
          // Test Indonesian localization
          final indonesianMessage = messageService.generatePersonalizedMessage(
            template,
            'Test',
            relationship,
            'id',
          );
          expect(indonesianMessage, isNot(contains(relationship)),
            reason: 'Indonesian should translate relationship: $relationship');
        }
      });
    });

    group('Sharing Integration', () {
      test('should create social media content with Islamic hashtags', () async {
        final message = PersonalizedMessage(
          content: 'Happy birthday, Ahmad! May Allah bless you.',
          recipientName: 'Ahmad',
          relationship: 'brother',
          language: 'en',
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        );

        final socialContent = await sharingService.createSocialMediaContent(
          message,
          includeHashtags: true,
        );

        expect(socialContent, contains(message.content));
        expect(socialContent, contains('#IslamicCalendar'));
        expect(socialContent, contains('#HijriDate'));
        expect(socialContent, contains('#MuslimFamily'));
        expect(socialContent, contains('🌙✨'));
      });

      test('should create app invitation content in multiple languages', () async {
        // Mock the sharing channel
        const channel = MethodChannel('hijri_minder/sharing');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        });

        // Test English invitation
        final englishMessage = PersonalizedMessage(
          content: 'Birthday wishes',
          recipientName: 'Ahmad',
          relationship: 'brother',
          language: 'en',
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        );

        await sharingService.shareWithAppInvitation(englishMessage);
        
        final englishSharedText = log.last.arguments['text'] as String;
        expect(englishSharedText, contains('HijriMinder'));
        expect(englishSharedText, contains('Islamic Calendar App'));
        expect(englishSharedText, contains('Download now'));

        // Test Arabic invitation
        final arabicMessage = englishMessage.copyWith(language: 'ar');
        await sharingService.shareWithAppInvitation(arabicMessage);
        
        final arabicSharedText = log.last.arguments['text'] as String;
        expect(arabicSharedText, contains('التقويم الهجري'));
        expect(arabicSharedText, contains('حمل الآن'));
      });

      test('should handle clipboard operations', () async {
        // Mock the clipboard
        const channel = MethodChannel('flutter/platform');
        final List<MethodCall> log = <MethodCall>[];
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        const testMessage = 'Test Islamic message with بركة الله';
        final result = await sharingService.copyToClipboard(testMessage);

        expect(result, isTrue);
        expect(log, hasLength(1));
        expect(log.first.method, equals('Clipboard.setData'));
        expect(log.first.arguments['text'], equals(testMessage));
      });
    });

    group('End-to-End Message Flow', () {
      test('should complete full message creation and sharing flow', () async {
        // Step 1: Get templates for birthday
        final templates = messageService.getMessageTemplates(ReminderType.birthday, 'en');
        expect(templates, isNotEmpty);

        // Step 2: Generate personalized message
        const recipientName = 'Aisha';
        const relationship = 'sister';
        final personalizedContent = messageService.generatePersonalizedMessage(
          templates.first,
          recipientName,
          relationship,
          'en',
        );

        // Step 3: Create PersonalizedMessage object
        final message = PersonalizedMessage(
          content: personalizedContent,
          recipientName: recipientName,
          relationship: relationship,
          language: 'en',
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        );

        // Step 4: Prepare for sharing with social media content
        final socialContent = await sharingService.createSocialMediaContent(
          message,
          includeHashtags: true,
        );

        // Verify the complete flow
        expect(message.content, contains('Aisha'));
        expect(message.content, anyOf([contains('sister'), isNot(contains('{relationship}'))]));
        expect(message.content, contains('Allah'));
        expect(socialContent, contains(message.content));
        expect(socialContent, contains('#IslamicCalendar'));
        expect(socialContent, contains('🌙✨'));
      });

      test('should handle multi-language message generation and sharing', () async {
        const recipientName = 'محمد'; // Arabic name
        const relationship = 'son';
        
        // Generate Arabic message
        final arabicTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'ar');
        final arabicContent = messageService.generatePersonalizedMessage(
          arabicTemplates.first,
          recipientName,
          relationship,
          'ar',
        );

        final arabicMessage = PersonalizedMessage(
          content: arabicContent,
          recipientName: recipientName,
          relationship: relationship,
          language: 'ar',
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        );

        // Create social content with Arabic hashtags
        final arabicSocialContent = await sharingService.createSocialMediaContent(
          arabicMessage,
          includeHashtags: true,
        );

        expect(arabicMessage.content, contains('محمد'));
        expect(arabicMessage.content, anyOf([contains('ابني'), isNot(contains('{relationship}'))])); // Arabic for son
        expect(arabicSocialContent, contains('#التقويم_الهجري'));
        expect(arabicSocialContent, contains('#التاريخ_الهجري'));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle unsupported languages gracefully', () {
        final templates = messageService.getMessageTemplates(ReminderType.birthday, 'unsupported');
        final englishTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'en');
        
        expect(templates, equals(englishTemplates));
      });

      test('should handle empty or invalid input gracefully', () {
        const template = 'Hello {name}, from {relationship}';
        
        // Test with empty name
        final emptyNameResult = messageService.generatePersonalizedMessage(
          template,
          '',
          'friend',
          'en',
        );
        expect(emptyNameResult, contains('from friend'));
        
        // Test with empty relationship
        final emptyRelationshipResult = messageService.generatePersonalizedMessage(
          template,
          'Test',
          '',
          'en',
        );
        expect(emptyRelationshipResult, contains('Hello Test'));
      });

      test('should validate language support correctly', () {
        expect(messageService.isLanguageSupported('en'), isTrue);
        expect(messageService.isLanguageSupported('ar'), isTrue);
        expect(messageService.isLanguageSupported('id'), isTrue);
        expect(messageService.isLanguageSupported('ur'), isTrue);
        expect(messageService.isLanguageSupported('ms'), isTrue);
        expect(messageService.isLanguageSupported('tr'), isTrue);
        expect(messageService.isLanguageSupported('fa'), isTrue);
        expect(messageService.isLanguageSupported('bn'), isTrue);
        expect(messageService.isLanguageSupported('xyz'), isFalse);
        
        expect(messageService.getDefaultLanguage(), equals('en'));
      });
    });

    group('Cultural Authenticity Validation', () {
      test('should contain authentic Islamic terminology', () {
        final languages = ['en', 'ar', 'id', 'ur'];
        
        for (final language in languages) {
          final birthdayTemplates = messageService.getMessageTemplates(ReminderType.birthday, language);
          final islamicGreetings = messageService.getIslamicGreetingTemplates(language);
          
          // Birthday templates should contain Islamic blessings
          expect(birthdayTemplates.any((t) => 
            t.toLowerCase().contains('allah') || 
            t.contains('بارك') || 
            t.contains('barakallah') ||
            t.contains('berkah')
          ), isTrue, reason: 'Birthday templates in $language should contain Islamic blessings');
          
          // Islamic greetings should contain authentic phrases
          expect(islamicGreetings.any((g) => 
            g.contains('Assalamu') || 
            g.contains('السلام') ||
            g.contains('Barakallahu') ||
            g.contains('بارك الله')
          ), isTrue, reason: 'Islamic greetings in $language should contain authentic phrases');
        }
      });

      test('should provide culturally appropriate religious messages', () {
        final templates = messageService.getMessageTemplates(ReminderType.religious, 'en');
        
        // Should contain Islamic phrases for death
        expect(templates.any((t) => t.contains('Inna lillahi')), isTrue);
        expect(templates.any((t) => t.contains('Jannah')), isTrue);
        expect(templates.any((t) => t.contains('mercy')), isTrue);
        expect(templates.any((t) => t.contains('Allah')), isTrue);
        
        // Should be respectful and not celebratory
        expect(templates.any((t) => t.toLowerCase().contains('happy')), isFalse);
        expect(templates.any((t) => t.toLowerCase().contains('celebrate')), isFalse);
      });
    });
  });
}