import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/service_locator.dart';

/// Widget for selecting and customizing message templates
class MessageTemplateSelector extends StatefulWidget {
  final ReminderType reminderType;
  final String language;
  final String recipientName;
  final String relationship;
  final Function(PersonalizedMessage) onMessageSelected;

  const MessageTemplateSelector({
    Key? key,
    required this.reminderType,
    required this.language,
    required this.recipientName,
    required this.relationship,
    required this.onMessageSelected,
  }) : super(key: key);

  @override
  State<MessageTemplateSelector> createState() => _MessageTemplateSelectorState();
}

class _MessageTemplateSelectorState extends State<MessageTemplateSelector> {
  // final MessageTemplatesService _messageService = ServiceLocator.messageTemplatesService; // Temporarily disabled
  List<String> _templates = [];
  List<String> _islamicGreetings = [];
  String? _selectedTemplate;
  bool _showIslamicGreetings = false;
  final TextEditingController _customMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    setState(() {
      // Temporarily disabled due to service unavailability
      _templates = ['Default template 1', 'Default template 2']; // _messageService.getMessageTemplates(widget.reminderType, widget.language);
      _islamicGreetings = ['As-salamu alaikum', 'Barakallahu feeki']; // _messageService.getIslamicGreetingTemplates(widget.language);
    });
  }

  @override
  void didUpdateWidget(MessageTemplateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminderType != widget.reminderType || 
        oldWidget.language != widget.language) {
      _loadTemplates();
      _selectedTemplate = null;
    }
  }

  void _selectTemplate(String template) {
    setState(() {
      _selectedTemplate = template;
      _customMessageController.text = template; // Temporarily simplified
    });
  }

  void _createPersonalizedMessage() {
    if (_customMessageController.text.trim().isEmpty) return;

    final personalizedMessage = PersonalizedMessage(
      content: _customMessageController.text.trim(),
      recipientName: widget.recipientName,
      relationship: widget.relationship,
      language: widget.language,
      type: widget.reminderType,
      createdAt: DateTime.now(),
    );

    widget.onMessageSelected(personalizedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Template category selector
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _showIslamicGreetings = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showIslamicGreetings 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                ),
                child: Text(
                  _getTemplateCategoryName(widget.reminderType, widget.language),
                  style: TextStyle(
                    color: !_showIslamicGreetings ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _showIslamicGreetings = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showIslamicGreetings 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                ),
                child: Text(
                  _getIslamicGreetingsLabel(widget.language),
                  style: TextStyle(
                    color: _showIslamicGreetings ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Template list
        Text(
          _getSelectTemplateLabel(widget.language),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _showIslamicGreetings ? _islamicGreetings.length : _templates.length,
            itemBuilder: (context, index) {
              final template = _showIslamicGreetings ? _islamicGreetings[index] : _templates[index];
              final isSelected = _selectedTemplate == template;
              
              return ListTile(
                title: Text(
                  template,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: isSelected,
                selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                onTap: () => _selectTemplate(template),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Custom message editor
        Text(
          _getCustomizeMessageLabel(widget.language),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customMessageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _getMessageHint(widget.language),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to update button state
          },
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _customMessageController.text.trim().isNotEmpty
                  ? _createPersonalizedMessage
                  : null,
                icon: const Icon(Icons.check),
                label: Text(_getUseMessageLabel(widget.language)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _customMessageController.clear();
                  _selectedTemplate = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: Text(_getClearLabel(widget.language)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTemplateCategoryName(ReminderType type, String language) {
    final names = {
      'en': {
        ReminderType.birthday: 'Birthday Messages',
        ReminderType.anniversary: 'Anniversary Messages',
        ReminderType.religious: 'Memorial Messages',
      },
      'ar': {
        ReminderType.birthday: 'رسائل المولد',
        ReminderType.anniversary: 'رسائل الذكرى',
        ReminderType.religious: 'رسائل التأبين',
      },
      'id': {
        ReminderType.birthday: 'Pesan Ulang Tahun',
        ReminderType.anniversary: 'Pesan Anniversary',
        ReminderType.religious: 'Pesan Kenangan',
      },
      'ur': {
        ReminderType.birthday: 'سالگرہ کے پیغامات',
        ReminderType.anniversary: 'سالگرہ کے پیغامات',
        ReminderType.religious: 'یادگاری پیغامات',
      },
    };

    return names[language]?[type] ?? names['en']![type]!;
  }

  String _getIslamicGreetingsLabel(String language) {
    final labels = {
      'en': 'Islamic Greetings',
      'ar': 'التحيات الإسلامية',
      'id': 'Salam Islam',
      'ur': 'اسلامی سلام',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getSelectTemplateLabel(String language) {
    final labels = {
      'en': 'Select a Template:',
      'ar': 'اختر قالباً:',
      'id': 'Pilih Template:',
      'ur': 'ٹیمپلیٹ منتخب کریں:',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getCustomizeMessageLabel(String language) {
    final labels = {
      'en': 'Customize Your Message:',
      'ar': 'خصص رسالتك:',
      'id': 'Sesuaikan Pesan Anda:',
      'ur': 'اپنا پیغام تیار کریں:',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getMessageHint(String language) {
    final hints = {
      'en': 'Type your personalized message here...',
      'ar': 'اكتب رسالتك الشخصية هنا...',
      'id': 'Ketik pesan personal Anda di sini...',
      'ur': 'یہاں اپنا ذاتی پیغام لکھیں...',
    };
    return hints[language] ?? hints['en']!;
  }

  String _getUseMessageLabel(String language) {
    final labels = {
      'en': 'Use Message',
      'ar': 'استخدم الرسالة',
      'id': 'Gunakan Pesan',
      'ur': 'پیغام استعمال کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getClearLabel(String language) {
    final labels = {
      'en': 'Clear',
      'ar': 'مسح',
      'id': 'Hapus',
      'ur': 'صاف کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }
}