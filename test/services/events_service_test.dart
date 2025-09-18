import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/events_service.dart';

void main() {
  group('EventsService Tests', () {
    late EventsService eventsService;

    setUp(() {
      eventsService = EventsService();
    });

    test('should get events for specific date', () {
      // Test for Eid al-Fitr (1st Shawwal)
      final events = eventsService.getEventsForDate(1, 10);
      
      expect(events, isNotEmpty);
      expect(events.any((event) => event.title == 'Eid al-Fitr'), isTrue);
    });

    test('should get events for specific month', () {
      // Test for Ramadan (month 9)
      final events = eventsService.getEventsForMonth(9);
      
      expect(events, isNotEmpty);
      expect(events.any((event) => event.title.contains('Ramadan')), isTrue);
    });

    test('should get important events', () {
      final importantEvents = eventsService.getImportantEvents();
      
      expect(importantEvents, isNotEmpty);
      expect(importantEvents.every((event) => event.isImportant), isTrue);
    });

    test('should search events by query', () {
      final eidEvents = eventsService.searchEvents('Eid');
      
      expect(eidEvents, isNotEmpty);
      expect(eidEvents.every((event) => 
        event.title.toLowerCase().contains('eid') ||
        event.description.toLowerCase().contains('eid') ||
        event.category.toLowerCase().contains('eid')
      ), isTrue);
    });

    test('should return empty list for empty search query', () {
      final events = eventsService.searchEvents('');
      
      expect(events, isEmpty);
    });

    test('should get events by category', () {
      final eidEvents = eventsService.getEventsByCategory('Eid');
      
      expect(eidEvents, isNotEmpty);
      expect(eidEvents.every((event) => event.category == 'Eid'), isTrue);
    });

    test('should get all event categories', () {
      final categories = eventsService.getEventCategories();
      
      expect(categories, isNotEmpty);
      expect(categories, contains('Eid'));
      expect(categories, contains('Ramadan'));
      expect(categories, contains('Hajj'));
    });

    test('should check if date has events', () {
      // Test for Eid al-Fitr (1st Shawwal)
      final hasEvents = eventsService.hasEventsForDate(1, 10);
      
      expect(hasEvents, isTrue);
      
      // Test for a date without events
      final noEvents = eventsService.hasEventsForDate(15, 5);
      
      expect(noEvents, isFalse);
    });

    test('should get event by ID', () {
      final event = eventsService.getEventById('eid_fitr');
      
      expect(event, isNotNull);
      expect(event!.title, equals('Eid al-Fitr'));
    });

    test('should return null for non-existent event ID', () {
      final event = eventsService.getEventById('non_existent_id');
      
      expect(event, isNull);
    });

    test('should create IslamicEvent from map', () {
      final map = {
        'id': 'test_event',
        'title': 'Test Event',
        'description': 'Test Description',
        'hijriDay': 15,
        'hijriMonth': 6,
        'hijriYear': 1445,
        'category': 'Test',
        'isImportant': true,
        'location': 'Test Location',
      };

      final event = IslamicEvent.fromMap(map);
      
      expect(event.id, equals('test_event'));
      expect(event.title, equals('Test Event'));
      expect(event.description, equals('Test Description'));
      expect(event.hijriDay, equals(15));
      expect(event.hijriMonth, equals(6));
      expect(event.hijriYear, equals(1445));
      expect(event.category, equals('Test'));
      expect(event.isImportant, isTrue);
      expect(event.location, equals('Test Location'));
    });

    test('should convert IslamicEvent to map', () {
      const event = IslamicEvent(
        id: 'test_event',
        title: 'Test Event',
        description: 'Test Description',
        hijriDay: 15,
        hijriMonth: 6,
        hijriYear: 1445,
        category: 'Test',
        isImportant: true,
        location: 'Test Location',
      );

      final map = event.toMap();
      
      expect(map['id'], equals('test_event'));
      expect(map['title'], equals('Test Event'));
      expect(map['description'], equals('Test Description'));
      expect(map['hijriDay'], equals(15));
      expect(map['hijriMonth'], equals(6));
      expect(map['hijriYear'], equals(1445));
      expect(map['category'], equals('Test'));
      expect(map['isImportant'], isTrue);
      expect(map['location'], equals('Test Location'));
    });
  });
}