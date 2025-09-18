import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/widgets/message_template_selector.dart';
import 'package:hijri_minder/models/message_template.dart';

void main() {
  group('MessageTemplateSelector Widget Tests', () {
    final testTemplates = [
      MessageTemplate(
        id: '1',
        title: 'Birthday Template',
        content: 'Happy Birthday! {name}',
        category: MessageCategory.birthday,
        language: 'en',
      ),
      MessageTemplate(
        id: '2',
        title: 'Anniversary Template',
        content: 'Happy Anniversary! {name}',
        category: MessageCategory.anniversary,
        language: 'en',
      ),
    ];

    testWidgets('should display all templates', (WidgetTester tester) async {
      MessageTemplate? selectedTemplate;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {
                selectedTemplate = template;
              },
            ),
          ),
        ),
      );

      expect(find.text('Birthday Template'), findsOneWidget);
      expect(find.text('Anniversary Template'), findsOneWidget);
    });

    testWidgets('should call onTemplateSelected when template is tapped', (WidgetTester tester) async {
      MessageTemplate? selectedTemplate;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {
                selectedTemplate = template;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Birthday Template'));
      await tester.pump();

      expect(selectedTemplate, equals(testTemplates[0]));
    });

    testWidgets('should highlight selected template', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              selectedTemplate: testTemplates[0],
              onTemplateSelected: (template) {},
            ),
          ),
        ),
      );

      final selectedCard = tester.widget<Card>(find.byType(Card).first);
      expect(selectedCard.color, isNotNull);
    });

    testWidgets('should display template content preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {},
              showPreview: true,
            ),
          ),
        ),
      );

      expect(find.text('Happy Birthday! {name}'), findsOneWidget);
      expect(find.text('Happy Anniversary! {name}'), findsOneWidget);
    });

    testWidgets('should filter templates by category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {},
              filterCategory: MessageCategory.birthday,
            ),
          ),
        ),
      );

      expect(find.text('Birthday Template'), findsOneWidget);
      expect(find.text('Anniversary Template'), findsNothing);
    });

    testWidgets('should handle empty template list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: const [],
              onTemplateSelected: (template) {},
            ),
          ),
        ),
      );

      expect(find.text('No templates available'), findsOneWidget);
    });

    testWidgets('should display template category badges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {},
              showCategoryBadges: true,
            ),
          ),
        ),
      );

      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Anniversary'), findsOneWidget);
    });

    testWidgets('should support custom template builder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: testTemplates,
              onTemplateSelected: (template) {},
              templateBuilder: (context, template, isSelected) {
                return ListTile(
                  title: Text('Custom: ${template.title}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Custom: Birthday Template'), findsOneWidget);
      expect(find.text('Custom: Anniversary Template'), findsOneWidget);
    });

    testWidgets('should handle long template lists with scrolling', (WidgetTester tester) async {
      final longTemplateList = List.generate(20, (index) => 
        MessageTemplate(
          id: '$index',
          title: 'Template $index',
          content: 'Content $index',
          category: MessageCategory.birthday,
          language: 'en',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTemplateSelector(
              templates: longTemplateList,
              onTemplateSelected: (template) {},
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Template 0'), findsOneWidget);
      
      // Scroll to find later templates
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      
      expect(find.text('Template 19'), findsOneWidget);
    });
  });
}