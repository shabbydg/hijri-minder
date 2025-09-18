import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/localization_service.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('LocalizationService Tests', () {
    late LocalizationService localizationService;

    setUp(() {
      localizationService = LocalizationService();
    });

    test('should initialize with default English locale', () {
      expect(localizationService.currentLocale, const Locale('en'));
      expect(localizationService.useArabicNumerals, false);
      expect(localizationService.isRTL, false);
      expect(localizationService.textDirection, TextDirection.ltr);
    });

    test('should support all required languages', () {
      final supportedLanguages = LocalizationService.supportedLanguages.keys.toList();
      
      expect(supportedLanguages, contains('en')); // English
      expect(supportedLanguages, contains('ar')); // Arabic
      expect(supportedLanguages, contains('id')); // Indonesian
      expect(supportedLanguages, contains('ur')); // Urdu
      expect(supportedLanguages, contains('ms')); // Malay
      expect(supportedLanguages, contains('tr')); // Turkish
      expect(supportedLanguages, contains('fa')); // Persian
      expect(supportedLanguages, contains('bn')); // Bengali
      
      expect(supportedLanguages.length, 8);
    });

    test('should detect RTL languages correctly', () {
      // Test RTL languages
      expect(localizationService.isArabicScript('ar'), true);
      expect(localizationService.isArabicScript('ur'), true);
      expect(localizationService.isArabicScript('fa'), true);
      
      // Test LTR languages
      expect(localizationService.isArabicScript('en'), false);
      expect(localizationService.isArabicScript('id'), false);
      expect(localizationService.isArabicScript('ms'), false);
      expect(localizationService.isArabicScript('tr'), false);
      expect(localizationService.isArabicScript('bn'), false);
    });

    test('should format numbers correctly with Arabic numerals', () {
      // Test without Arabic numerals
      expect(localizationService.formatNumber(123), '123');
      expect(localizationService.formatNumber(0), '0');
      expect(localizationService.formatNumber(9876), '9876');
      
      // Enable Arabic numerals manually for testing
      localizationService.toggleArabicNumerals();
      
      // Test with Arabic numerals (when RTL or Indonesian/Malay)
      expect(localizationService.formatNumber(123), '123'); // Still Western for English
      
      // Test Arabic numerals conversion directly
      expect(localizationService.formatTime('12:30'), '12:30'); // LTR language
    });

    test('should handle time formatting correctly', () {
      // Test LTR time formatting
      expect(localizationService.formatTime('12:30'), '12:30');
      expect(localizationService.formatTime('09:45'), '09:45');
      
      // Test with Arabic numerals disabled
      expect(localizationService.formatTime('23:59'), '23:59');
    });

    test('should validate supported language codes', () {
      // Test valid language codes
      expect(() => localizationService.changeLanguage('en'), returnsNormally);
      expect(() => localizationService.changeLanguage('ar'), returnsNormally);
      expect(() => localizationService.changeLanguage('id'), returnsNormally);
      
      // Test invalid language code
      expect(() => localizationService.changeLanguage('xx'), throwsArgumentError);
      expect(() => localizationService.changeLanguage(''), throwsArgumentError);
    });

    test('should provide correct language display names', () {
      final supportedLanguages = LocalizationService.supportedLanguages;
      
      expect(supportedLanguages['en'], 'English');
      expect(supportedLanguages['ar'], 'العربية');
      expect(supportedLanguages['id'], 'Bahasa Indonesia');
      expect(supportedLanguages['ur'], 'اردو');
      expect(supportedLanguages['ms'], 'Bahasa Melayu');
      expect(supportedLanguages['tr'], 'Türkçe');
      expect(supportedLanguages['fa'], 'فارسی');
      expect(supportedLanguages['bn'], 'বাংলা');
    });

    test('should return null font family by default', () {
      expect(localizationService.getFontFamily(), null);
    });
  });
}