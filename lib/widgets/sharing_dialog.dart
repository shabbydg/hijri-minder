import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/service_locator.dart';

/// Dialog for sharing personalized messages through various platforms
class SharingDialog extends StatefulWidget {
  final PersonalizedMessage message;

  const SharingDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<SharingDialog> createState() => _SharingDialogState();
}

class _SharingDialogState extends State<SharingDialog> {
  final SharingService _sharingService = ServiceLocator.sharingService;
  List<SharingApp> _availableApps = [];
  bool _isLoading = true;
  bool _includeAppInvitation = true;
  bool _includeHashtags = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableApps();
  }

  Future<void> _loadAvailableApps() async {
    try {
      final apps = await _sharingService.getAvailableSharingApps();
      setState(() {
        _availableApps = apps.where((app) => app.isInstalled).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareToApp(String packageName) async {
    try {
      PersonalizedMessage messageToShare = widget.message;
      
      if (_includeAppInvitation) {
        final content = await _sharingService.createSocialMediaContent(
          widget.message,
          includeHashtags: _includeHashtags,
        );
        messageToShare = widget.message.copyWith(content: content);
      }

      final success = await _sharingService.shareToApp(messageToShare, packageName);
      
      if (success) {
        Navigator.of(context).pop();
        _showSuccessSnackBar();
      } else {
        _showErrorSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  Future<void> _shareGeneral() async {
    try {
      PersonalizedMessage messageToShare = widget.message;
      
      if (_includeAppInvitation) {
        await _sharingService.shareWithAppInvitation(widget.message);
      } else {
        await _sharingService.shareMessage(widget.message);
      }
      
      Navigator.of(context).pop();
      _showSuccessSnackBar();
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      String content = widget.message.content;
      
      if (_includeAppInvitation) {
        content = await _sharingService.createSocialMediaContent(
          widget.message,
          includeHashtags: _includeHashtags,
        );
      }

      final success = await _sharingService.copyToClipboard(content);
      
      if (success) {
        Navigator.of(context).pop();
        _showCopiedSnackBar();
      } else {
        _showErrorSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getSuccessMessage(widget.message.language)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCopiedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getCopiedMessage(widget.message.language)),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getErrorMessage(widget.message.language)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _getShareTitle(widget.message.language),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Message preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                widget.message.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),

            // Sharing options
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      _getIncludeInvitationLabel(widget.message.language),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _includeAppInvitation,
                    onChanged: (value) {
                      setState(() {
                        _includeAppInvitation = value ?? true;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (_includeAppInvitation)
              CheckboxListTile(
                title: Text(
                  _getIncludeHashtagsLabel(widget.message.language),
                  style: const TextStyle(fontSize: 12),
                ),
                value: _includeHashtags,
                onChanged: (value) {
                  setState(() {
                    _includeHashtags = value ?? true;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

            const SizedBox(height: 16),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareGeneral,
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      _getShareLabel(widget.message.language),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text(
                      _getCopyLabel(widget.message.language),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Available apps
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_availableApps.isNotEmpty) ...[
              Text(
                _getShareToAppLabel(widget.message.language),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableApps.map((app) {
                  return InkWell(
                    onTap: () => _shareToApp(app.packageName),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAppIcon(app.packageName),
                            size: 32,
                            color: _getAppColor(app.packageName),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.name,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getAppIcon(String packageName) {
    switch (packageName) {
      case 'com.whatsapp':
        return Icons.chat;
      case 'org.telegram.messenger':
        return Icons.send;
      case 'com.facebook.orca':
        return Icons.message;
      case 'com.instagram.android':
        return Icons.camera_alt;
      case 'com.twitter.android':
        return Icons.alternate_email;
      case 'com.facebook.katana':
        return Icons.facebook;
      default:
        return Icons.share;
    }
  }

  Color _getAppColor(String packageName) {
    switch (packageName) {
      case 'com.whatsapp':
        return Colors.green;
      case 'org.telegram.messenger':
        return Colors.blue;
      case 'com.facebook.orca':
        return Colors.blue[700]!;
      case 'com.instagram.android':
        return Colors.purple;
      case 'com.twitter.android':
        return Colors.lightBlue;
      case 'com.facebook.katana':
        return Colors.blue[800]!;
      default:
        return Colors.grey;
    }
  }

  String _getShareTitle(String language) {
    final titles = {
      'en': 'Share Message',
      'ar': 'مشاركة الرسالة',
      'id': 'Bagikan Pesan',
      'ur': 'پیغام شیئر کریں',
    };
    return titles[language] ?? titles['en']!;
  }

  String _getIncludeInvitationLabel(String language) {
    final labels = {
      'en': 'Include app invitation',
      'ar': 'تضمين دعوة التطبيق',
      'id': 'Sertakan undangan aplikasi',
      'ur': 'ایپ کی دعوت شامل کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getIncludeHashtagsLabel(String language) {
    final labels = {
      'en': 'Include hashtags',
      'ar': 'تضمين الهاشتاغ',
      'id': 'Sertakan hashtag',
      'ur': 'ہیش ٹیگ شامل کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getShareLabel(String language) {
    final labels = {
      'en': 'Share',
      'ar': 'مشاركة',
      'id': 'Bagikan',
      'ur': 'شیئر کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getCopyLabel(String language) {
    final labels = {
      'en': 'Copy',
      'ar': 'نسخ',
      'id': 'Salin',
      'ur': 'کاپی کریں',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getShareToAppLabel(String language) {
    final labels = {
      'en': 'Share to:',
      'ar': 'مشاركة إلى:',
      'id': 'Bagikan ke:',
      'ur': 'شیئر کریں:',
    };
    return labels[language] ?? labels['en']!;
  }

  String _getSuccessMessage(String language) {
    final messages = {
      'en': 'Message shared successfully!',
      'ar': 'تم مشاركة الرسالة بنجاح!',
      'id': 'Pesan berhasil dibagikan!',
      'ur': 'پیغام کامیابی سے شیئر ہوا!',
    };
    return messages[language] ?? messages['en']!;
  }

  String _getCopiedMessage(String language) {
    final messages = {
      'en': 'Message copied to clipboard!',
      'ar': 'تم نسخ الرسالة إلى الحافظة!',
      'id': 'Pesan disalin ke clipboard!',
      'ur': 'پیغام کلپ بورڈ میں کاپی ہوا!',
    };
    return messages[language] ?? messages['en']!;
  }

  String _getErrorMessage(String language) {
    final messages = {
      'en': 'Failed to share message',
      'ar': 'فشل في مشاركة الرسالة',
      'id': 'Gagal membagikan pesan',
      'ur': 'پیغام شیئر کرنے میں ناکام',
    };
    return messages[language] ?? messages['en']!;
  }
}