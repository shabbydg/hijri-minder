import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/models.dart';
import 'package:hijri_minder/services/message_templates_service.dart';
import 'package:hijri_minder/services/sharing_service.dart';

/// Demonstration of the messaging system functionality
void main() {
  group('Messaging System Demo', () {
    late MessageTemplatesService messageService;
    late SharingService sharingService;

    setUp(() {
      messageService = MessageTemplatesService();
      sharingService = SharingService();
    });

    test('Demo: Generate birthday messages in multiple languages', () {
      print('\n=== Birthday Message Generation Demo ===');
      
      const recipientName = 'Ahmad';
      const relationship = 'brother';
      
      // English
      final englishTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'en');
      final englishMessage = messageService.generatePersonalizedMessage(
        englishTemplates.first,
        recipientName,
        relationship,
        'en',
      );
      print('English: $englishMessage');
      
      // Arabic
      final arabicTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'ar');
      final arabicMessage = messageService.generatePersonalizedMessage(
        arabicTemplates.first,
        recipientName,
        relationship,
        'ar',
      );
      print('Arabic: $arabicMessage');
      
      // Indonesian
      final indonesianTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'id');
      final indonesianMessage = messageService.generatePersonalizedMessage(
        indonesianTemplates.first,
        recipientName,
        relationship,
        'id',
      );
      print('Indonesian: $indonesianMessage');
      
      // Urdu
      final urduTemplates = messageService.getMessageTemplates(ReminderType.birthday, 'ur');
      final urduMessage = messageService.generatePersonalizedMessage(
        urduTemplates.first,
        recipientName,
        relationship,
        'ur',
      );
      print('Urdu: $urduMessage');
      
      // Verify all messages contain the name
      expect(englishMessage, contains('Ahmad'));
      expect(arabicMessage, contains('Ahmad'));
      expect(indonesianMessage, contains('Ahmad'));
      expect(urduMessage, contains('Ahmad'));
    });

    test('Demo: Islamic greetings in multiple languages', () {
      print('\n=== Islamic Greetings Demo ===');
      
      final languages = ['en', 'ar', 'id', 'ur'];
      
      for (final language in languages) {
        final greetings = messageService.getIslamicGreetingTemplates(language);
        print('$language: ${greetings.first}');
      }
      
      // Verify greetings are available
      for (final language in languages) {
        final greetings = messageService.getIslamicGreetingTemplates(language);
        expect(greetings, isNotEmpty);
      }
    });

    test('Demo: Anniversary messages', () {
      print('\n=== Anniversary Messages Demo ===');
      
      const recipientName = 'Fatima & Ali';
      const relationship = 'couple';
      
      final templates = messageService.getMessageTemplates(ReminderType.anniversary, 'en');
      final message = messageService.generatePersonalizedMessage(
        templates.first,
        recipientName,
        relationship,
        'en',
      );
      print('Anniversary: $message');
      
      expect(message, contains('Fatima & Ali'));
      expect(message, anyOf([contains('Allah'), contains('bless'), contains('marriage')]));
    });

    test('Demo: Religious/Memorial messages', () {
      print('\n=== Religious/Memorial Messages Demo ===');
      
      const recipientName = 'Abdullah';
      const relationship = 'father';
      
      final templates = messageService.getMessageTemplates(ReminderType.religious, 'en');
      final message = messageService.generatePersonalizedMessage(
        templates.first,
        recipientName,
        relationship,
        'en',
      );
      print('Memorial: $message');
      
      expect(message, contains('Abdullah'));
      expect(message, anyOf([
        contains('Allah'),
        contains('mercy'),
        contains('Jannah'),
        contains('peace'),
      ]));
    });

    test('Demo: Social media content creation', () async {
      print('\n=== Social Media Content Demo ===');
      
      final message = PersonalizedMessage(
        content: 'Happy birthday, Ahmad! May Allah bless you with happiness and prosperity.',
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
      
      print('Social Media Content:');
      print(socialContent);
      
      expect(socialContent, contains(message.content));
      expect(socialContent, contains('#IslamicCalendar'));
      expect(socialContent, contains('#HijriDate'));
      expect(socialContent, contains('🌙✨'));
    });

    test('Demo: Language support validation', () {
      print('\n=== Language Support Demo ===');
      
      print('Supported languages: ${MessageTemplatesService.supportedLanguages}');
      
      for (final language in MessageTemplatesService.supportedLanguages) {
        final isSupported = messageService.isLanguageSupported(language);
        print('$language: ${isSupported ? "✓" : "✗"}');
        expect(isSupported, isTrue);
      }
      
      // Test unsupported language
      expect(messageService.isLanguageSupported('xyz'), isFalse);
      expect(messageService.getDefaultLanguage(), equals('en'));
    });
  });
}