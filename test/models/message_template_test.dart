import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/models.dart';

void main() {
  group('MessageTemplate', () {
    late MessageTemplate testTemplate;

    setUp(() {
      testTemplate = const MessageTemplate(
        id: 'test_1',
        content: 'Happy birthday, {name}! May Allah bless you.',
        language: 'en',
        type: ReminderType.birthday,
        tags: ['birthday', 'blessing'],
        isReligious: true,
        quranicVerse: 'Quran 2:286',
        hadith: 'Sahih Bukhari 1234',
      );
    });

    group('constructor', () {
      test('should create MessageTemplate with all properties', () {
        expect(testTemplate.id, equals('test_1'));
        expect(testTemplate.content, equals('Happy birthday, {name}! May Allah bless you.'));
        expect(testTemplate.language, equals('en'));
        expect(testTemplate.type, equals(ReminderType.birthday));
        expect(testTemplate.tags, equals(['birthday', 'blessing']));
        expect(testTemplate.isReligious, isTrue);
        expect(testTemplate.quranicVerse, equals('Quran 2:286'));
        expect(testTemplate.hadith, equals('Sahih Bukhari 1234'));
      });

      test('should create MessageTemplate with default values', () {
        const template = MessageTemplate(
          id: 'simple',
          content: 'Simple message',
          language: 'en',
          type: ReminderType.birthday,
        );

        expect(template.tags, isEmpty);
        expect(template.isReligious, isFalse);
        expect(template.quranicVerse, isNull);
        expect(template.hadith, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final copy = testTemplate.copyWith(
          content: 'Modified content',
          language: 'ar',
          isReligious: false,
        );

        expect(copy.id, equals(testTemplate.id)); // Unchanged
        expect(copy.content, equals('Modified content')); // Changed
        expect(copy.language, equals('ar')); // Changed
        expect(copy.type, equals(testTemplate.type)); // Unchanged
        expect(copy.tags, equals(testTemplate.tags)); // Unchanged
        expect(copy.isReligious, isFalse); // Changed
        expect(copy.quranicVerse, equals(testTemplate.quranicVerse)); // Unchanged
        expect(copy.hadith, equals(testTemplate.hadith)); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copy = testTemplate.copyWith();

        expect(copy.id, equals(testTemplate.id));
        expect(copy.content, equals(testTemplate.content));
        expect(copy.language, equals(testTemplate.language));
        expect(copy.type, equals(testTemplate.type));
        expect(copy.tags, equals(testTemplate.tags));
        expect(copy.isReligious, equals(testTemplate.isReligious));
        expect(copy.quranicVerse, equals(testTemplate.quranicVerse));
        expect(copy.hadith, equals(testTemplate.hadith));
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON correctly', () {
        final json = testTemplate.toJson();

        expect(json['id'], equals('test_1'));
        expect(json['content'], equals('Happy birthday, {name}! May Allah bless you.'));
        expect(json['language'], equals('en'));
        expect(json['type'], equals('ReminderType.birthday'));
        expect(json['tags'], equals(['birthday', 'blessing']));
        expect(json['isReligious'], isTrue);
        expect(json['quranicVerse'], equals('Quran 2:286'));
        expect(json['hadith'], equals('Sahih Bukhari 1234'));
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'json_test',
          'content': 'Test message from JSON',
          'language': 'ar',
          'type': 'ReminderType.anniversary',
          'tags': ['test', 'json'],
          'isReligious': false,
          'quranicVerse': null,
          'hadith': null,
        };

        final template = MessageTemplate.fromJson(json);

        expect(template.id, equals('json_test'));
        expect(template.content, equals('Test message from JSON'));
        expect(template.language, equals('ar'));
        expect(template.type, equals(ReminderType.anniversary));
        expect(template.tags, equals(['test', 'json']));
        expect(template.isReligious, isFalse);
        expect(template.quranicVerse, isNull);
        expect(template.hadith, isNull);
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 'minimal',
          'content': 'Minimal message',
          'language': 'en',
          'type': 'ReminderType.birthday',
        };

        final template = MessageTemplate.fromJson(json);

        expect(template.id, equals('minimal'));
        expect(template.content, equals('Minimal message'));
        expect(template.language, equals('en'));
        expect(template.type, equals(ReminderType.birthday));
        expect(template.tags, isEmpty);
        expect(template.isReligious, isFalse);
        expect(template.quranicVerse, isNull);
        expect(template.hadith, isNull);
      });

      test('should handle invalid reminder type gracefully', () {
        final json = {
          'id': 'invalid_type',
          'content': 'Test message',
          'language': 'en',
          'type': 'InvalidType',
        };

        final template = MessageTemplate.fromJson(json);

        expect(template.type, equals(ReminderType.birthday)); // Default fallback
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all key properties match', () {
        const template1 = MessageTemplate(
          id: 'same',
          content: 'Same content',
          language: 'en',
          type: ReminderType.birthday,
        );

        const template2 = MessageTemplate(
          id: 'same',
          content: 'Same content',
          language: 'en',
          type: ReminderType.birthday,
          tags: ['different'], // Different tags shouldn't affect equality
        );

        expect(template1, equals(template2));
        expect(template1.hashCode, equals(template2.hashCode));
      });

      test('should not be equal when key properties differ', () {
        const template1 = MessageTemplate(
          id: 'different1',
          content: 'Content',
          language: 'en',
          type: ReminderType.birthday,
        );

        const template2 = MessageTemplate(
          id: 'different2',
          content: 'Content',
          language: 'en',
          type: ReminderType.birthday,
        );

        expect(template1, isNot(equals(template2)));
        expect(template1.hashCode, isNot(equals(template2.hashCode)));
      });
    });

    group('toString', () {
      test('should provide meaningful string representation', () {
        final string = testTemplate.toString();

        expect(string, contains('MessageTemplate'));
        expect(string, contains('test_1'));
        expect(string, contains('en'));
        expect(string, contains('ReminderType.birthday'));
        expect(string, contains('true')); // isReligious
      });
    });
  });

  group('PersonalizedMessage', () {
    late PersonalizedMessage testMessage;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testMessage = PersonalizedMessage(
        content: 'Happy birthday, Ahmad! May Allah bless you.',
        recipientName: 'Ahmad',
        relationship: 'brother',
        language: 'en',
        type: ReminderType.birthday,
        createdAt: testDate,
      );
    });

    group('constructor', () {
      test('should create PersonalizedMessage with all properties', () {
        expect(testMessage.content, equals('Happy birthday, Ahmad! May Allah bless you.'));
        expect(testMessage.recipientName, equals('Ahmad'));
        expect(testMessage.relationship, equals('brother'));
        expect(testMessage.language, equals('en'));
        expect(testMessage.type, equals(ReminderType.birthday));
        expect(testMessage.createdAt, equals(testDate));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final copy = testMessage.copyWith(
          recipientName: 'Fatima',
          relationship: 'sister',
          language: 'ar',
        );

        expect(copy.content, equals(testMessage.content)); // Unchanged
        expect(copy.recipientName, equals('Fatima')); // Changed
        expect(copy.relationship, equals('sister')); // Changed
        expect(copy.language, equals('ar')); // Changed
        expect(copy.type, equals(testMessage.type)); // Unchanged
        expect(copy.createdAt, equals(testMessage.createdAt)); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copy = testMessage.copyWith();

        expect(copy.content, equals(testMessage.content));
        expect(copy.recipientName, equals(testMessage.recipientName));
        expect(copy.relationship, equals(testMessage.relationship));
        expect(copy.language, equals(testMessage.language));
        expect(copy.type, equals(testMessage.type));
        expect(copy.createdAt, equals(testMessage.createdAt));
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON correctly', () {
        final json = testMessage.toJson();

        expect(json['content'], equals('Happy birthday, Ahmad! May Allah bless you.'));
        expect(json['recipientName'], equals('Ahmad'));
        expect(json['relationship'], equals('brother'));
        expect(json['language'], equals('en'));
        expect(json['type'], equals('ReminderType.birthday'));
        expect(json['createdAt'], equals(testDate.toIso8601String()));
      });

      test('should create from JSON correctly', () {
        final json = {
          'content': 'Anniversary wishes',
          'recipientName': 'Sarah',
          'relationship': 'wife',
          'language': 'id',
          'type': 'ReminderType.anniversary',
          'createdAt': '2024-02-20T15:45:00.000Z',
        };

        final message = PersonalizedMessage.fromJson(json);

        expect(message.content, equals('Anniversary wishes'));
        expect(message.recipientName, equals('Sarah'));
        expect(message.relationship, equals('wife'));
        expect(message.language, equals('id'));
        expect(message.type, equals(ReminderType.anniversary));
        expect(message.createdAt, equals(DateTime.parse('2024-02-20T15:45:00.000Z')));
      });

      test('should handle invalid reminder type gracefully', () {
        final json = {
          'content': 'Test message',
          'recipientName': 'Test',
          'relationship': 'friend',
          'language': 'en',
          'type': 'InvalidType',
          'createdAt': testDate.toIso8601String(),
        };

        final message = PersonalizedMessage.fromJson(json);

        expect(message.type, equals(ReminderType.birthday)); // Default fallback
      });
    });

    group('toString', () {
      test('should provide meaningful string representation', () {
        final string = testMessage.toString();

        expect(string, contains('PersonalizedMessage'));
        expect(string, contains('Ahmad'));
        expect(string, contains('ReminderType.birthday'));
        expect(string, contains('en'));
      });
    });
  });
}