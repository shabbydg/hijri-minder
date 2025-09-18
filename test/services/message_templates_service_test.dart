import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/models.dart';
import 'package:hijri_minder/services/message_templates_service.dart';

void main() {
  group('MessageTemplatesService', () {
    late MessageTemplatesService service;

    setUp(() {
      service = MessageTemplatesService();
    });

    group('getMessageTemplates', () {
      test('should return birthday templates in English', () {
        final templates = service.getMessageTemplates(ReminderType.birthday, 'en');
        
        expect(templates, isNotEmpty);
        expect(templates.length, greaterThan(3));
        expect(templates.first, contains('Allah'));
        expect(templates.first, contains('{name}'));
      });

      test('should return anniversary templates in Arabic', () {
        final templates = service.getMessageTemplates(ReminderType.anniversary, 'ar');
        
        expect(templates, isNotEmpty);
        expect(templates.length, greaterThan(3));
        expect(templates.first, contains('بارك الله'));
        expect(templates.first, contains('{name}'));
      });

      test('should return religious templates in Indonesian', () {
        final templates = service.getMessageTemplates(ReminderType.religious, 'id');
        
        expect(templates, isNotEmpty);
        expect(templates.length, greaterThan(3));
        expect(templates.first, contains('Allah'));
        expect(templates.first, contains('{name}'));
      });

      test('should return English templates for unsupported language', () {
        final templates = service.getMessageTemplates(ReminderType.birthday, 'unsupported');
        final englishTemplates = service.getMessageTemplates(ReminderType.birthday, 'en');
        
        expect(templates, equals(englishTemplates));
      });
    });

    group('generatePersonalizedMessage', () {
      test('should replace name and relationship placeholders', () {
        const template = 'Happy birthday, {name}! Best wishes from your {relationship}.';
        const recipientName = 'Ahmad';
        const relationship = 'brother';
        const language = 'en';

        final result = service.generatePersonalizedMessage(
          template,
          recipientName,
          relationship,
          language,
        );

        expect(result, contains('Ahmad'));
        expect(result, contains('brother'));
        expect(result, isNot(contains('{name}')));
        expect(result, isNot(contains('{relationship}')));
      });

      test('should localize relationship terms in Arabic', () {
        const template = 'مبارك {name}، من {relationship}';
        const recipientName = 'أحمد';
        const relationship = 'brother';
        const language = 'ar';

        final result = service.generatePersonalizedMessage(
          template,
          recipientName,
          relationship,
          language,
        );

        expect(result, contains('أحمد'));
        expect(result, contains('أخي')); // Arabic for brother
      });

      test('should handle unknown relationships gracefully', () {
        const template = 'Hello {name}, from your {relationship}';
        const recipientName = 'Test';
        const relationship = 'unknown_relation';
        const language = 'en';

        final result = service.generatePersonalizedMessage(
          template,
          recipientName,
          relationship,
          language,
        );

        expect(result, contains('Test'));
        expect(result, contains('unknown_relation')); // Should keep original
      });
    });

    group('getIslamicGreetingTemplates', () {
      test('should return Islamic greetings in English', () {
        final greetings = service.getIslamicGreetingTemplates('en');
        
        expect(greetings, isNotEmpty);
        expect(greetings.length, greaterThan(3));
        expect(greetings.any((g) => g.contains('Assalamu Alaikum')), isTrue);
        expect(greetings.any((g) => g.contains('Barakallahu')), isTrue);
      });

      test('should return Islamic greetings in Arabic', () {
        final greetings = service.getIslamicGreetingTemplates('ar');
        
        expect(greetings, isNotEmpty);
        expect(greetings.any((g) => g.contains('السلام عليكم')), isTrue);
        expect(greetings.any((g) => g.contains('بارك الله')), isTrue);
      });

      test('should include Quranic verses', () {
        final greetings = service.getIslamicGreetingTemplates('en');
        
        expect(greetings.any((g) => g.contains('Quran')), isTrue);
        expect(greetings.any((g) => g.contains('Prophet Muhammad')), isTrue);
      });
    });

    group('getReligiousAnniversaryTemplates', () {
      test('should return religious templates with Quranic references', () {
        final templates = service.getReligiousAnniversaryTemplates('en');
        
        expect(templates, isNotEmpty);
        expect(templates.any((t) => t.contains('Quran')), isTrue);
        expect(templates.any((t) => t.contains('Allah')), isTrue);
        expect(templates.any((t) => t.contains('blessed')), isTrue);
      });

      test('should return Arabic religious templates', () {
        final templates = service.getReligiousAnniversaryTemplates('ar');
        
        expect(templates, isNotEmpty);
        expect(templates.any((t) => t.contains('الله')), isTrue);
        expect(templates.any((t) => t.contains('المبارك')), isTrue);
      });
    });

    group('language support', () {
      test('should support all declared languages', () {
        for (final language in MessageTemplatesService.supportedLanguages) {
          final templates = service.getMessageTemplates(ReminderType.birthday, language);
          expect(templates, isNotEmpty, reason: 'Language $language should have templates');
        }
      });

      test('isLanguageSupported should return correct values', () {
        expect(service.isLanguageSupported('en'), isTrue);
        expect(service.isLanguageSupported('ar'), isTrue);
        expect(service.isLanguageSupported('id'), isTrue);
        expect(service.isLanguageSupported('ur'), isTrue);
        expect(service.isLanguageSupported('unsupported'), isFalse);
      });

      test('getDefaultLanguage should return English', () {
        expect(service.getDefaultLanguage(), equals('en'));
      });
    });

    group('relationship localization', () {
      test('should localize family relationships in different languages', () {
        const relationships = ['mother', 'father', 'brother', 'sister'];
        
        for (final relationship in relationships) {
          // Test English (should remain the same)
          final englishResult = service.generatePersonalizedMessage(
            'Hello {relationship}',
            'Test',
            relationship,
            'en',
          );
          expect(englishResult, contains(relationship));

          // Test Arabic (should be translated)
          final arabicResult = service.generatePersonalizedMessage(
            'مرحبا {relationship}',
            'اختبار',
            relationship,
            'ar',
          );
          expect(arabicResult, isNot(contains(relationship)));
          expect(arabicResult.length, greaterThan(0));
        }
      });
    });

    group('message content validation', () {
      test('birthday messages should contain appropriate Islamic elements', () {
        final templates = service.getMessageTemplates(ReminderType.birthday, 'en');
        
        for (final template in templates) {
          expect(
            template.contains('Allah') || 
            template.contains('bless') || 
            template.contains('Barakallahu'),
            isTrue,
            reason: 'Birthday template should contain Islamic elements: $template',
          );
        }
      });

      test('religious messages should be respectful and Islamic', () {
        final templates = service.getMessageTemplates(ReminderType.religious, 'en');
        
        for (final template in templates) {
          expect(
            template.contains('Allah') || 
            template.contains('mercy') || 
            template.contains('Jannah') ||
            template.contains('Inna lillahi'),
            isTrue,
            reason: 'Religious template should contain Islamic elements: $template',
          );
        }
      });

      test('Islamic greetings should contain authentic Islamic phrases', () {
        final greetings = service.getIslamicGreetingTemplates('en');
        
        expect(greetings.any((g) => g.contains('Assalamu Alaikum')), isTrue);
        expect(greetings.any((g) => g.contains('Barakallahu')), isTrue);
        expect(greetings.any((g) => g.contains('Subhanallah')), isTrue);
      });
    });

    group('template consistency', () {
      test('all templates should have placeholder support', () {
        for (final type in ReminderType.values) {
          for (final language in ['en', 'ar', 'id', 'ur']) {
            final templates = service.getMessageTemplates(type, language);
            
            // At least some templates should have name placeholder
            expect(
              templates.any((t) => t.contains('{name}')),
              isTrue,
              reason: 'Templates for $type in $language should support name placeholder',
            );
          }
        }
      });

      test('templates should not be empty or too short', () {
        for (final type in ReminderType.values) {
          for (final language in MessageTemplatesService.supportedLanguages) {
            final templates = service.getMessageTemplates(type, language);
            
            for (final template in templates) {
              expect(template.trim().length, greaterThan(10),
                reason: 'Template should not be too short: $template');
              expect(template.trim(), isNotEmpty,
                reason: 'Template should not be empty');
            }
          }
        }
      });
    });
  });
}