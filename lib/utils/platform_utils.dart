import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class PlatformUtils {
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows);
  static bool get isMobile => isIOS || isAndroid;
  static String get platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS: return 'ios';
      case TargetPlatform.android: return 'android';
      case TargetPlatform.macOS: return 'macos';
      case TargetPlatform.linux: return 'linux';
      case TargetPlatform.windows: return 'windows';
      case TargetPlatform.fuchsia: return 'fuchsia';
    }
  }
}
