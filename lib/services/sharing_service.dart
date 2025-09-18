import 'dart:io';
import 'package:flutter/services.dart';
import '../models/message_template.dart';
import '../models/reminder.dart';

/// Service for sharing messages through various platforms
class SharingService {
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  SharingService._internal();

  static const MethodChannel _channel = MethodChannel('hijri_minder/sharing');

  /// Share a personalized message through the system share dialog
  Future<bool> shareMessage(PersonalizedMessage message) async {
    try {
      final result = await _channel.invokeMethod('shareText', {
        'text': message.content,
        'subject': _getShareSubject(message.type, message.language),
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      print('Error sharing message: ${e.message}');
      return false;
    }
  }

  /// Share message to a specific app (WhatsApp, Telegram, etc.)
  Future<bool> shareToApp(PersonalizedMessage message, String appPackage) async {
    try {
      final result = await _channel.invokeMethod('shareToApp', {
        'text': message.content,
        'package': appPackage,
        'subject': _getShareSubject(message.type, message.language),
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      print('Error sharing to app: ${e.message}');
      return false;
    }
  }

  /// Copy message to clipboard
  Future<bool> copyToClipboard(String message) async {
    try {
      await Clipboard.setData(ClipboardData(text: message));
      return true;
    } catch (e) {
      print('Error copying to clipboard: $e');
      return false;
    }
  }

  /// Get available sharing apps on the device
  Future<List<SharingApp>> getAvailableSharingApps() async {
    try {
      final result = await _channel.invokeMethod('getAvailableApps');
      final List<dynamic> apps = result as List<dynamic>? ?? [];
      
      return apps.map((app) => SharingApp.fromMap(Map<String, dynamic>.from(app as Map))).toList();
    } on PlatformException catch (e) {
      print('Error getting available apps: ${e.message}');
      return [];
    }
  }

  /// Share with Islamic app branding and invitation
  Future<bool> shareWithAppInvitation(PersonalizedMessage message) async {
    final invitationText = _getAppInvitationText(message.language);
    final fullMessage = '${message.content}\n\n$invitationText';
    
    final invitationMessage = message.copyWith(content: fullMessage);
    return await shareMessage(invitationMessage);
  }

  /// Create shareable content for social media with Islamic design elements
  Future<String> createSocialMediaContent(
    PersonalizedMessage message,
    {bool includeHashtags = true}
  ) async {
    final hashtags = includeHashtags ? _getIslamicHashtags(message.language) : '';
    final decoratedMessage = _decorateMessageForSocial(message.content);
    
    return '$decoratedMessage\n\n$hashtags';
  }

  /// Get share subject based on reminder type and language
  String _getShareSubject(ReminderType type, String language) {
    final subjects = {
      'en': {
        ReminderType.birthday: 'Birthday Wishes',
        ReminderType.anniversary: 'Anniversary Greetings',
        ReminderType.religious: 'In Loving Memory',
      },
      'ar': {
        ReminderType.birthday: 'تهنئة بالمولد',
        ReminderType.anniversary: 'تهنئة بالذكرى',
        ReminderType.religious: 'في الذكرى',
      },
      'id': {
        ReminderType.birthday: 'Ucapan Ulang Tahun',
        ReminderType.anniversary: 'Ucapan Anniversary',
        ReminderType.religious: 'Dalam Kenangan',
      },
      'ur': {
        ReminderType.birthday: 'سالگرہ کی مبارکباد',
        ReminderType.anniversary: 'سالگرہ کی مبارکباد',
        ReminderType.religious: 'یاد میں',
      },
    };

    return subjects[language]?[type] ?? subjects['en']![type]!;
  }

  /// Get app invitation text in different languages
  String _getAppInvitationText(String language) {
    final invitations = {
      'en': '📱 Sent with love using HijriMinder - The Islamic Calendar App\n'
            '🌙 Download now to never miss important Islamic dates!\n'
            '🔗 [App Store Link]',
      'ar': '📱 أرسل بالحب باستخدام تطبيق التقويم الهجري\n'
            '🌙 حمل الآن لتتذكر التواريخ الإسلامية المهمة!\n'
            '🔗 [رابط المتجر]',
      'id': '📱 Dikirim dengan cinta menggunakan HijriMinder - Aplikasi Kalender Islam\n'
            '🌙 Download sekarang agar tidak melewatkan tanggal-tanggal penting Islam!\n'
            '🔗 [Link App Store]',
      'ur': '📱 محبت کے ساتھ ہجری کیلنڈر ایپ سے بھیجا گیا\n'
            '🌙 اہم اسلامی تاریخوں کو یاد رکھنے کے لیے ابھی ڈاؤن لوڈ کریں!\n'
            '🔗 [ایپ اسٹور لنک]',
    };

    return invitations[language] ?? invitations['en']!;
  }

  /// Get Islamic hashtags for social media
  String _getIslamicHashtags(String language) {
    final hashtags = {
      'en': '#IslamicCalendar #HijriDate #MuslimFamily #IslamicGreetings #Barakallah #HijriMinder',
      'ar': '#التقويم_الهجري #التاريخ_الهجري #العائلة_المسلمة #التهاني_الإسلامية #بارك_الله',
      'id': '#KalenderIslam #TanggalHijriah #KeluargaMuslim #UcapanIslami #Barakallah',
      'ur': '#اسلامی_کیلنڈر #ہجری_تاریخ #مسلم_خاندان #اسلامی_مبارکباد #برک_اللہ',
    };

    return hashtags[language] ?? hashtags['en']!;
  }

  /// Decorate message for social media with Islamic design elements
  String _decorateMessageForSocial(String message) {
    return '🌙✨ $message ✨🌙';
  }

  /// Get popular messaging app packages
  static const Map<String, String> popularApps = {
    'whatsapp': 'com.whatsapp',
    'telegram': 'org.telegram.messenger',
    'messenger': 'com.facebook.orca',
    'instagram': 'com.instagram.android',
    'twitter': 'com.twitter.android',
    'facebook': 'com.facebook.katana',
  };

  /// Check if a specific app is available
  Future<bool> isAppAvailable(String packageName) async {
    try {
      final result = await _channel.invokeMethod('isAppAvailable', {
        'package': packageName,
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      print('Error checking app availability: ${e.message}');
      return false;
    }
  }
}

/// Represents a sharing app available on the device
class SharingApp {
  final String name;
  final String packageName;
  final String iconPath;
  final bool isInstalled;

  const SharingApp({
    required this.name,
    required this.packageName,
    required this.iconPath,
    required this.isInstalled,
  });

  factory SharingApp.fromMap(Map<String, dynamic> map) {
    return SharingApp(
      name: map['name'] as String,
      packageName: map['packageName'] as String,
      iconPath: map['iconPath'] as String,
      isInstalled: map['isInstalled'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageName': packageName,
      'iconPath': iconPath,
      'isInstalled': isInstalled,
    };
  }

  @override
  String toString() {
    return 'SharingApp(name: $name, packageName: $packageName, isInstalled: $isInstalled)';
  }
}