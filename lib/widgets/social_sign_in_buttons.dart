import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';
import '../l10n/app_localizations.dart';

/// Reusable Google Sign-In button widget
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(
              color: Color(0xFFDADCE0),
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4285F4)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Google 'G' logo
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.continueWithGoogle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable Apple Sign-In button widget
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const AppleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Apple',
  });

  @override
  Widget build(BuildContext context) {
    return IslamicBorder(
      color: AppTheme.islamicTextDark,
      opacity: 0.1,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.islamicTextDark,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppTheme.islamicTextDark.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apple logo with Islamic accent
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Platform-aware social sign-in buttons container
class SocialSignInButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final String? googleText;
  final String? appleText;

  const SocialSignInButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.googleText,
    this.appleText,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = [];

    // Determine button order based on platform
    if (PlatformUtils.isIOS) {
      // iOS: Apple first, Google second
      if (onApplePressed != null) {
        buttons.add(AppleSignInButton(
          onPressed: onApplePressed,
          isLoading: isAppleLoading,
          text: appleText ?? 'Continue with Apple',
        ));
      }
      if (onGooglePressed != null) {
        buttons.add(const SizedBox(height: 12));
        buttons.add(GoogleSignInButton(
          onPressed: onGooglePressed,
          isLoading: isGoogleLoading,
          text: googleText ?? 'Continue with Google',
        ));
      }
    } else {
      // Android/Web: Google first, Apple second
      if (onGooglePressed != null) {
        buttons.add(GoogleSignInButton(
          onPressed: onGooglePressed,
          isLoading: isGoogleLoading,
          text: googleText ?? 'Continue with Google',
        ));
      }
      if (onApplePressed != null) {
        buttons.add(const SizedBox(height: 12));
        buttons.add(AppleSignInButton(
          onPressed: onApplePressed,
          isLoading: isAppleLoading,
          text: appleText ?? 'Continue with Apple',
        ));
      }
    }

    return Column(
      children: buttons,
    );
  }
}

/// Divider widget for separating social sign-in from email/password form
class SocialSignInDivider extends StatelessWidget {
  final String text;

  const SocialSignInDivider({
    super.key,
    this.text = 'OR',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.lightPurple.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.creamSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightPurple.withOpacity(0.3),
                ),
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.islamicTextLight,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.lightPurple.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
