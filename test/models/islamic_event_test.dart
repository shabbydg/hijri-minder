import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/islamic_event.dart';

void main() {
  group('IslamicEvent Model Tests', () {
    late IslamicEvent testEvent;

    setUp(() {
      testEvent = IslamicEvent(
        id: 'eid_fitr_2024',
        title: 'Eid al-Fitr',
        description: 'Festival of Breaking the Fast',
        category: EventCategory.eid,
        hijriDay: 1,
        hijriMonth: 9, // Shawwal
        isImportant: true,
        location: 'Global',
        localizedTitles: {
          'ar': 'عيد الفطر',
          'ur': 'عید الفطر',
        },
        localizedDescriptions: {
          'ar': 'عيد الفطر المبارك',
          'ur': 'عید الفطر مبارک',
        },
      );
    });

    test('should create IslamicEvent with all required fields', () {
      expect(testEvent.id, 'eid_fitr_2024');
      expect(testEvent.title, 'Eid al-Fitr');
      expect(testEvent.description, 'Festival of Breaking the Fast');
      expect(testEvent.category, EventCategory.eid);
      expect(testEvent.hijriDay, 1);
      expect(testEvent.hijriMonth, 9);
      expect(testEvent.hijriYear, isNull);
      expect(testEvent.isImportant, true);
      expect(testEvent.location, 'Global');
    });

    test('should serialize to JSON correctly', () {
      final json = testEvent.toJson();
      
      expect(json['id'], 'eid_fitr_2024');
      expect(json['title'], 'Eid al-Fitr');
      expect(json['description'], 'Festival of Breaking the Fast');
      expect(json['category'], 'eid');
      expect(json['hijriDay'], 1);
      expect(json['hijriMonth'], 9);
      expect(json['hijriYear'], isNull);
      expect(json['isImportant'], true);
      expect(json['location'], 'Global');
      expect(json['localizedTitles'], isA<Map<String, String>>());
      expect(json['localizedDescriptions'], isA<Map<String, String>>());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'eid_fitr_2024',
        'title': 'Eid al-Fitr',
        'description': 'Festival of Breaking the Fast',
        'category': 'eid',
        'hijriDay': 1,
        'hijriMonth': 9,
        'hijriYear': null,
        'isImportant': true,
        'location': 'Global',
        'localizedTitles': {
          'ar': 'عيد الفطر',
          'ur': 'عید الفطر',
        },
        'localizedDescriptions': {
          'ar': 'عيد الفطر المبارك',
          'ur': 'عید الفطر مبارک',
        },
      };

      final event = IslamicEvent.fromJson(json);
      
      expect(event.id, 'eid_fitr_2024');
      expect(event.title, 'Eid al-Fitr');
      expect(event.description, 'Festival of Breaking the Fast');
      expect(event.category, EventCategory.eid);
      expect(event.hijriDay, 1);
      expect(event.hijriMonth, 9);
      expect(event.hijriYear, isNull);
      expect(event.isImportant, true);
      expect(event.location, 'Global');
    });

    test('should get localized title correctly', () {
      expect(testEvent.getLocalizedTitle('ar'), 'عيد الفطر');
      expect(testEvent.getLocalizedTitle('ur'), 'عید الفطر');
      expect(testEvent.getLocalizedTitle('en'), 'Eid al-Fitr'); // Fallback to default
      expect(testEvent.getLocalizedTitle('fr'), 'Eid al-Fitr'); // Fallback to default
    });

    test('should get localized description correctly', () {
      expect(testEvent.getLocalizedDescription('ar'), 'عيد الفطر المبارك');
      expect(testEvent.getLocalizedDescription('ur'), 'عید الفطر مبارک');
      expect(testEvent.getLocalizedDescription('en'), 'Festival of Breaking the Fast'); // Fallback
      expect(testEvent.getLocalizedDescription('fr'), 'Festival of Breaking the Fast'); // Fallback
    });

    test('should get category display name correctly', () {
      expect(testEvent.getCategoryDisplayName(), 'Eid');
      
      final shahadatEvent = testEvent.copyWith(category: EventCategory.shahadat);
      expect(shahadatEvent.getCategoryDisplayName(), 'Shahadat');
      
      final ramadanEvent = testEvent.copyWith(category: EventCategory.ramadan);
      expect(ramadanEvent.getCategoryDisplayName(), 'Ramadan');
      
      final hajjEvent = testEvent.copyWith(category: EventCategory.hajj);
      expect(hajjEvent.getCategoryDisplayName(), 'Hajj');
      
      final miladEvent = testEvent.copyWith(category: EventCategory.milad);
      expect(miladEvent.getCategoryDisplayName(), 'Milad');
      
      final otherEvent = testEvent.copyWith(category: EventCategory.other);
      expect(otherEvent.getCategoryDisplayName(), 'Other');
    });

    test('should check if event occurs on specific date correctly', () {
      // Test recurring event (no specific year)
      expect(testEvent.occursOnDate(1, 9), true);
      expect(testEvent.occursOnDate(1, 9, 1445), true);
      expect(testEvent.occursOnDate(1, 9, 1446), true);
      expect(testEvent.occursOnDate(2, 9), false);
      expect(testEvent.occursOnDate(1, 8), false);
      
      // Test specific year event
      final specificYearEvent = testEvent.copyWith(hijriYear: 1445);
      expect(specificYearEvent.occursOnDate(1, 9, 1445), true);
      expect(specificYearEvent.occursOnDate(1, 9, 1446), false);
      expect(specificYearEvent.occursOnDate(1, 9), false); // No year provided
    });

    test('should check if event occurs in month correctly', () {
      expect(testEvent.occursInMonth(9), true);
      expect(testEvent.occursInMonth(8), false);
      expect(testEvent.occursInMonth(10), false);
    });

    test('should get importance level correctly', () {
      // Important Eid event
      expect(testEvent.getImportanceLevel(), 3);
      
      // Non-important Eid event
      final nonImportantEid = testEvent.copyWith(isImportant: false);
      expect(nonImportantEid.getImportanceLevel(), 2);
      
      // Shahadat event
      final shahadatEvent = testEvent.copyWith(category: EventCategory.shahadat, isImportant: false);
      expect(shahadatEvent.getImportanceLevel(), 1);
      
      // Milad event
      final miladEvent = testEvent.copyWith(category: EventCategory.milad, isImportant: false);
      expect(miladEvent.getImportanceLevel(), 1);
      
      // Ramadan event
      final ramadanEvent = testEvent.copyWith(category: EventCategory.ramadan, isImportant: false);
      expect(ramadanEvent.getImportanceLevel(), 0);
      
      // Hajj event
      final hajjEvent = testEvent.copyWith(category: EventCategory.hajj, isImportant: false);
      expect(hajjEvent.getImportanceLevel(), 0);
      
      // Other event
      final otherEvent = testEvent.copyWith(category: EventCategory.other, isImportant: false);
      expect(otherEvent.getImportanceLevel(), 0);
    });

    test('should create copy with updated fields correctly', () {
      final updatedEvent = testEvent.copyWith(
        title: 'Updated Eid al-Fitr',
        isImportant: false,
        hijriYear: 1445,
      );
      
      expect(updatedEvent.title, 'Updated Eid al-Fitr');
      expect(updatedEvent.isImportant, false);
      expect(updatedEvent.hijriYear, 1445);
      
      // Other fields should remain the same
      expect(updatedEvent.id, testEvent.id);
      expect(updatedEvent.description, testEvent.description);
      expect(updatedEvent.category, testEvent.category);
      expect(updatedEvent.hijriDay, testEvent.hijriDay);
      expect(updatedEvent.hijriMonth, testEvent.hijriMonth);
    });

    test('should implement equality correctly', () {
      final event1 = IslamicEvent(
        id: 'test_event',
        title: 'Test Event',
        description: 'Test Description',
        category: EventCategory.eid,
        hijriDay: 1,
        hijriMonth: 1,
      );

      final event2 = IslamicEvent(
        id: 'test_event',
        title: 'Test Event',
        description: 'Test Description',
        category: EventCategory.eid,
        hijriDay: 1,
        hijriMonth: 1,
      );

      final event3 = IslamicEvent(
        id: 'different_event',
        title: 'Test Event',
        description: 'Test Description',
        category: EventCategory.eid,
        hijriDay: 1,
        hijriMonth: 1,
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should have proper toString representation', () {
      final string = testEvent.toString();
      expect(string, contains('IslamicEvent'));
      expect(string, contains('eid_fitr_2024'));
      expect(string, contains('Eid al-Fitr'));
      expect(string, contains('eid'));
      expect(string, contains('1/9'));
    });

    group('EventCategory Extension Tests', () {
      test('should get correct color hex for each category', () {
        expect(EventCategory.eid.colorHex, '#4CAF50');
        expect(EventCategory.shahadat.colorHex, '#F44336');
        expect(EventCategory.ramadan.colorHex, '#9C27B0');
        expect(EventCategory.hajj.colorHex, '#FF9800');
        expect(EventCategory.milad.colorHex, '#2196F3');
        expect(EventCategory.other.colorHex, '#607D8B');
      });

      test('should get correct icon name for each category', () {
        expect(EventCategory.eid.iconName, 'celebration');
        expect(EventCategory.shahadat.iconName, 'favorite');
        expect(EventCategory.ramadan.iconName, 'nights_stay');
        expect(EventCategory.hajj.iconName, 'place');
        expect(EventCategory.milad.iconName, 'cake');
        expect(EventCategory.other.iconName, 'event');
      });
    });
  });
}