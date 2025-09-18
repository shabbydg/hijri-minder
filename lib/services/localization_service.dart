import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/arabic_numerals.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _useArabicNumeralsKey = 'use_arabic_numerals';
  
  Locale _currentLocale = const Locale('en');
  bool _useArabicNumerals = false;
  
  Locale get currentLocale => _currentLocale;
  bool get useArabicNumerals => _useArabicNumerals;
  
  /// Check if current locale uses RTL text direction
  bool get isRTL => _currentLocale.languageCode == 'ar' || 
                   _currentLocale.languageCode == 'ur' || 
                   _currentLocale.languageCode == 'fa';
  
  /// Get text direction based on current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
  
  /// Supported locales with their display names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'id': 'Bahasa Indonesia',
    'ur': 'اردو',
    'ms': 'Bahasa Melayu',
    'tr': 'Türkçe',
    'fa': 'فارسی',
    'bn': 'বাংলা',
  };
  
  /// Initialize the service and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved language
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null && supportedLanguages.containsKey(savedLanguage)) {
      _currentLocale = Locale(savedLanguage);
    }
    
    // Load Arabic numerals preference
    _useArabicNumerals = prefs.getBool(_useArabicNumeralsKey) ?? false;
    
    notifyListeners();
  }
  
  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      throw ArgumentError('Unsupported language: $languageCode');
    }
    
    _currentLocale = Locale(languageCode);
    
    // Auto-enable Arabic numerals for Arabic script languages
    if (languageCode == 'ar' || languageCode == 'ur' || languageCode == 'fa') {
      _useArabicNumerals = true;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    await prefs.setBool(_useArabicNumeralsKey, _useArabicNumerals);
    
    notifyListeners();
  }
  
  /// Toggle Arabic numerals usage
  Future<void> toggleArabicNumerals() async {
    _useArabicNumerals = !_useArabicNumerals;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useArabicNumeralsKey, _useArabicNumerals);
    
    notifyListeners();
  }
  
  /// Format number based on current locale and preferences
  String formatNumber(int number) {
    if (_useArabicNumerals && (isRTL || _currentLocale.languageCode == 'id' || _currentLocale.languageCode == 'ms')) {
      return ArabicNumerals.convertToArabicSafe(number);
    }
    return number.toString();
  }
  
  /// Format time string with appropriate numerals
  String formatTime(String timeString) {
    if (!_useArabicNumerals || !isRTL) {
      return timeString;
    }
    
    // Convert digits in time string to Arabic numerals
    String result = timeString;
    for (int i = 0; i <= 9; i++) {
      result = result.replaceAll(i.toString(), ArabicNumerals.arabicNumerals[i]);
    }
    return result;
  }
  
  /// Get month name in current locale
  String getHijriMonthName(int month, BuildContext context) {
    // This would typically use the localization system
    // For now, return a basic implementation
    const monthNames = {
      1: 'monthMoharram',
      2: 'monthSafar',
      3: 'monthRabiAlAwwal',
      4: 'monthRabiAlThani',
      5: 'monthJumadaAlAwwal',
      6: 'monthJumadaAlThani',
      7: 'monthRajab',
      8: 'monthShaban',
      9: 'monthRamadan',
      10: 'monthShawwal',
      11: 'monthDhulQadah',
      12: 'monthDhulHijjah',
    };
    
    // In a real implementation, this would use AppLocalizations
    // For now, return the key name
    return monthNames[month] ?? 'Unknown';
  }
  
  /// Check if a language uses Arabic script
  bool isArabicScript(String languageCode) {
    return languageCode == 'ar' || languageCode == 'ur' || languageCode == 'fa';
  }
  
  /// Get appropriate font family for current locale
  String? getFontFamily() {
    if (isArabicScript(_currentLocale.languageCode)) {
      // Return Arabic font family if available
      return null; // Use system default for now
    }
    return null; // Use system default
  }
}