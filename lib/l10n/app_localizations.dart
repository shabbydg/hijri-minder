import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('fa'),
    Locale('id'),
    Locale('ms'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'HijriMinder'**
  String get appTitle;

  /// Calendar tab label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Prayer Times title
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// Reminders title
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Events label
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Hijri Date label
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get hijriDate;

  /// Gregorian Date label
  ///
  /// In en, this message translates to:
  /// **'Gregorian Date'**
  String get gregorianDate;

  /// First month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Moharram'**
  String get monthMoharram;

  /// Second month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get monthSafar;

  /// Third month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Awwal'**
  String get monthRabiAlAwwal;

  /// Fourth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-Thani'**
  String get monthRabiAlThani;

  /// Fifth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Awwal'**
  String get monthJumadaAlAwwal;

  /// Sixth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Thani'**
  String get monthJumadaAlThani;

  /// Seventh month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get monthRajab;

  /// Eighth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get monthShaban;

  /// Ninth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get monthRamadan;

  /// Tenth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get monthShawwal;

  /// Eleventh month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Dhul-Qa\'dah'**
  String get monthDhulQadah;

  /// Twelfth month of Hijri calendar
  ///
  /// In en, this message translates to:
  /// **'Dhul-Hijjah'**
  String get monthDhulHijjah;

  /// Sihori prayer time
  ///
  /// In en, this message translates to:
  /// **'Sihori'**
  String get sihori;

  /// Fajr prayer time
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// Sunrise time
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// Zawaal time
  ///
  /// In en, this message translates to:
  /// **'Zawaal'**
  String get zawaal;

  /// Zohr End prayer time
  ///
  /// In en, this message translates to:
  /// **'Zohr End'**
  String get zohrEnd;

  /// Asr End prayer time
  ///
  /// In en, this message translates to:
  /// **'Asr End'**
  String get asrEnd;

  /// Maghrib prayer time
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// Maghrib End prayer time
  ///
  /// In en, this message translates to:
  /// **'Maghrib End'**
  String get maghribEnd;

  /// Nisful Layl prayer time
  ///
  /// In en, this message translates to:
  /// **'Nisful Layl'**
  String get nisfulLayl;

  /// Nisful Layl End prayer time
  ///
  /// In en, this message translates to:
  /// **'Nisful Layl End'**
  String get nisfulLaylEnd;

  /// Next prayer label
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// Time remaining label
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Add Reminder button
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Reminder title field label
  ///
  /// In en, this message translates to:
  /// **'Reminder Title'**
  String get reminderTitle;

  /// Reminder description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reminderDescription;

  /// Reminder type field label
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// Birthday reminder type
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// Anniversary reminder type
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get anniversary;

  /// Death anniversary reminder type
  ///
  /// In en, this message translates to:
  /// **'Death Anniversary'**
  String get deathAnniversary;

  /// Select date button
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Islamic events title
  ///
  /// In en, this message translates to:
  /// **'Islamic Events'**
  String get islamicEvents;

  /// Search events placeholder
  ///
  /// In en, this message translates to:
  /// **'Search Events'**
  String get searchEvents;

  /// No events found message
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Prayer notifications setting
  ///
  /// In en, this message translates to:
  /// **'Prayer Notifications'**
  String get prayerNotifications;

  /// Adhan sounds setting
  ///
  /// In en, this message translates to:
  /// **'Adhan Sounds'**
  String get adhanSounds;

  /// Location services setting
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// Show Gregorian dates setting
  ///
  /// In en, this message translates to:
  /// **'Show Gregorian Dates'**
  String get showGregorianDates;

  /// Show event dots setting
  ///
  /// In en, this message translates to:
  /// **'Show Event Dots'**
  String get showEventDots;

  /// Prayer time format setting
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Format'**
  String get prayerTimeFormat;

  /// 12 hour format option
  ///
  /// In en, this message translates to:
  /// **'12 Hour'**
  String get format12Hour;

  /// 24 hour format option
  ///
  /// In en, this message translates to:
  /// **'24 Hour'**
  String get format24Hour;

  /// Notification advance setting
  ///
  /// In en, this message translates to:
  /// **'Notification Advance'**
  String get notificationAdvance;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Location permission required message
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for accurate prayer times'**
  String get locationPermissionRequired;

  /// Enable location button
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// Use default location button
  ///
  /// In en, this message translates to:
  /// **'Use Default Location'**
  String get useDefaultLocation;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// Islamic greeting
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum'**
  String get islamicGreeting;

  /// Islamic greeting response
  ///
  /// In en, this message translates to:
  /// **'Wa Alaikum Assalam'**
  String get islamicGreetingResponse;

  /// Islamic blessing
  ///
  /// In en, this message translates to:
  /// **'Barak Allahu feeki/feek'**
  String get barakAllahu;

  /// Islamic thank you
  ///
  /// In en, this message translates to:
  /// **'Jazak Allahu Khairan'**
  String get jazakAllahu;

  /// God willing
  ///
  /// In en, this message translates to:
  /// **'Insha\'Allah'**
  String get inshallah;

  /// What Allah has willed
  ///
  /// In en, this message translates to:
  /// **'Masha\'Allah'**
  String get mashallah;

  /// Glory be to Allah
  ///
  /// In en, this message translates to:
  /// **'Subhan\'Allah'**
  String get subhanallah;

  /// Praise be to Allah
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get alhamdulillah;

  /// Allah is the Greatest
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbar;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Create password field hint
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createStrongPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Valid email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Password requirements validation
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one letter and one number'**
  String get passwordRequirements;

  /// Password mismatch validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Confirm password validation
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Reset password title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password heading
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// Reset password instructions
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// Send reset email button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmail;

  /// Back to sign in button
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// Check email heading
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// Password reset email sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to:'**
  String get passwordResetSent;

  /// Check email instructions
  ///
  /// In en, this message translates to:
  /// **'Please check your email and follow the instructions to reset your password. If you don\'t see the email, check your spam folder.'**
  String get checkEmailInstructions;

  /// Didn't receive email link
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Try again'**
  String get didntReceiveEmail;

  /// Create account heading
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// Join HijriMinder description
  ///
  /// In en, this message translates to:
  /// **'Join HijriMinder to track your Islamic calendar and prayer times'**
  String get joinHijriMinder;

  /// Agree to terms text
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTerms;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// And connector
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Accept terms validation
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms of service and privacy policy'**
  String get acceptTermsRequired;

  /// Account created success message
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please check your email for verification.'**
  String get accountCreatedSuccessfully;

  /// Sign in to continue text
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// Authentication error title
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'There was an error initializing the authentication system. Please try again.'**
  String get authenticationErrorMessage;

  /// Continue to login button
  ///
  /// In en, this message translates to:
  /// **'Continue to Login'**
  String get continueToLogin;

  /// App subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Islamic Calendar Companion'**
  String get yourIslamicCalendarCompanion;

  /// Initializing message
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Google sign-in button text for login
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Apple sign-in button text for login
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Divider text between social sign-in and email/password form
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Google sign-in cancelled error message
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled'**
  String get googleSignInCancelled;

  /// Apple sign-in cancelled error message
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in was cancelled'**
  String get appleSignInCancelled;

  /// General social sign-in failure message
  ///
  /// In en, this message translates to:
  /// **'Social sign-in failed. Please try again.'**
  String get socialSignInFailed;

  /// Account already linked error message
  ///
  /// In en, this message translates to:
  /// **'This account is already linked to another sign-in method'**
  String get accountAlreadyLinked;

  /// Google Sign-In not available message
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In is not available on this platform'**
  String get googleSignInNotAvailable;

  /// Apple Sign-In not available message
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is not available on this platform'**
  String get appleSignInNotAvailable;

  /// Calendar type selection title
  ///
  /// In en, this message translates to:
  /// **'Select Calendar Types'**
  String get selectCalendarTypes;

  /// Hijri Calendar title
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijriCalendar;

  /// Gregorian calendar option
  ///
  /// In en, this message translates to:
  /// **'Gregorian Calendar'**
  String get gregorianCalendar;

  /// Both calendars option
  ///
  /// In en, this message translates to:
  /// **'Both Calendars'**
  String get bothCalendars;

  /// Advance notifications title
  ///
  /// In en, this message translates to:
  /// **'Advance Notifications'**
  String get advanceNotifications;

  /// Add notification button
  ///
  /// In en, this message translates to:
  /// **'Add Notification'**
  String get addNotification;

  /// Custom time option
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get customTime;

  /// Remove notification action
  ///
  /// In en, this message translates to:
  /// **'Remove Notification'**
  String get removeNotification;

  /// Premium feature label
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// Upgrade to premium button
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// Hijri reminders premium requirement message
  ///
  /// In en, this message translates to:
  /// **'Hijri reminders require premium subscription'**
  String get hijriRemindersRequirePremium;

  /// Calendar type selection validation
  ///
  /// In en, this message translates to:
  /// **'Please select at least one calendar type'**
  String get pleaseSelectCalendarType;

  /// Notification time selection validation
  ///
  /// In en, this message translates to:
  /// **'Please select at least one notification time'**
  String get pleaseSelectNotificationTime;

  /// Notification time selection guidance
  ///
  /// In en, this message translates to:
  /// **'Choose when to be notified'**
  String get chooseWhenToBeNotified;

  /// Calendar type selection guidance
  ///
  /// In en, this message translates to:
  /// **'Select calendar types for this reminder'**
  String get selectCalendarTypesForReminder;

  /// Quick notification options label
  ///
  /// In en, this message translates to:
  /// **'Quick Options'**
  String get quickOptions;

  /// Selected notifications label
  ///
  /// In en, this message translates to:
  /// **'Selected Notifications'**
  String get selectedNotifications;

  /// Add custom time button
  ///
  /// In en, this message translates to:
  /// **'Add Custom Time'**
  String get addCustomTime;

  /// Total time label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Week unit
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// Weeks unit
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// Minute unit
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// Hour unit
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// Day field label
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Premium label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Gregorian calendar description
  ///
  /// In en, this message translates to:
  /// **'Standard calendar'**
  String get standardCalendar;

  /// Hijri calendar description
  ///
  /// In en, this message translates to:
  /// **'Islamic calendar'**
  String get islamicCalendar;

  /// Reminder preferences title
  ///
  /// In en, this message translates to:
  /// **'Reminder Preferences'**
  String get reminderPreferences;

  /// Default calendar types setting
  ///
  /// In en, this message translates to:
  /// **'Default Calendar Types'**
  String get defaultCalendarTypes;

  /// Default advance notifications setting
  ///
  /// In en, this message translates to:
  /// **'Default Advance Notifications'**
  String get defaultAdvanceNotifications;

  /// Primary calendar setting
  ///
  /// In en, this message translates to:
  /// **'Primary Calendar'**
  String get primaryCalendar;

  /// Notification settings label
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Recurring reminder preferences label
  ///
  /// In en, this message translates to:
  /// **'Recurring Reminder Preferences'**
  String get recurringReminderPreferences;

  /// Message template preferences label
  ///
  /// In en, this message translates to:
  /// **'Message Template Preferences'**
  String get messageTemplatePreferences;

  /// Save preferences button
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// Reset to defaults button
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Preferences saved success message
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get preferencesSaved;

  /// Preferences reset success message
  ///
  /// In en, this message translates to:
  /// **'Preferences reset to defaults'**
  String get preferencesReset;

  /// Sync with cloud button
  ///
  /// In en, this message translates to:
  /// **'Sync with Cloud'**
  String get syncWithCloud;

  /// Cloud sync enabled message
  ///
  /// In en, this message translates to:
  /// **'Cloud sync enabled'**
  String get cloudSyncEnabled;

  /// Cloud sync disabled message
  ///
  /// In en, this message translates to:
  /// **'Cloud sync disabled'**
  String get cloudSyncDisabled;

  /// Sync in progress message
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncInProgress;

  /// Sync complete message
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// Sync failed message
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// Date selection section header
  ///
  /// In en, this message translates to:
  /// **'Date Selection'**
  String get dateSelection;

  /// Night sensitivity toggle title
  ///
  /// In en, this message translates to:
  /// **'Night Sensitive'**
  String get nightSensitive;

  /// Night sensitivity toggle subtitle/help text
  ///
  /// In en, this message translates to:
  /// **'Add +1 day to Hijri date for events after sunset'**
  String get nightSensitiveHelp;

  /// Recipient name field label
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientName;

  /// Relationship field label
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// Recurring reminder toggle title
  ///
  /// In en, this message translates to:
  /// **'Recurring Reminder'**
  String get recurringReminder;

  /// Recurring reminder toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Repeat every year'**
  String get repeatEveryYear;

  /// Hijri date picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Hijri Date'**
  String get selectHijriDate;

  /// Year field label for Hijri date picker
  ///
  /// In en, this message translates to:
  /// **'Year (AH)'**
  String get yearAH;

  /// Month field label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Select button
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Title field validation message
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Islamic theme label
  ///
  /// In en, this message translates to:
  /// **'Islamic Theme'**
  String get islamicTheme;

  /// Mandala pattern decorative element
  ///
  /// In en, this message translates to:
  /// **'Mandala Pattern'**
  String get mandalaPattern;

  /// Geometric border decorative element
  ///
  /// In en, this message translates to:
  /// **'Geometric Border'**
  String get geometricBorder;

  /// Islamic decoration element
  ///
  /// In en, this message translates to:
  /// **'Islamic Decoration'**
  String get islamicDecoration;

  /// Decorative corner element
  ///
  /// In en, this message translates to:
  /// **'Decorative Corner'**
  String get decorativeCorner;

  /// Star pattern decorative element
  ///
  /// In en, this message translates to:
  /// **'Star Pattern'**
  String get starPattern;

  /// Crescent pattern decorative element
  ///
  /// In en, this message translates to:
  /// **'Crescent Pattern'**
  String get crescentPattern;

  /// Islamic color scheme label
  ///
  /// In en, this message translates to:
  /// **'Islamic Colors'**
  String get islamicColors;

  /// Purple color theme option
  ///
  /// In en, this message translates to:
  /// **'Purple Theme'**
  String get purpleTheme;

  /// Cream accent color
  ///
  /// In en, this message translates to:
  /// **'Cream Accent'**
  String get creamAccent;

  /// Gold accent color
  ///
  /// In en, this message translates to:
  /// **'Gold Accent'**
  String get goldAccent;

  /// Islamic design system label
  ///
  /// In en, this message translates to:
  /// **'Islamic Design'**
  String get islamicDesign;

  /// Cultural aesthetic design approach
  ///
  /// In en, this message translates to:
  /// **'Cultural Aesthetic'**
  String get culturalAesthetic;

  /// Traditional Islamic patterns
  ///
  /// In en, this message translates to:
  /// **'Traditional Patterns'**
  String get traditionalPatterns;

  /// Sacred geometry design elements
  ///
  /// In en, this message translates to:
  /// **'Sacred Geometry'**
  String get sacredGeometry;

  /// Islamic art design elements
  ///
  /// In en, this message translates to:
  /// **'Islamic Art'**
  String get islamicArt;

  /// Spiritual design approach
  ///
  /// In en, this message translates to:
  /// **'Spiritual Design'**
  String get spiritualDesign;

  /// Blessed theme variant
  ///
  /// In en, this message translates to:
  /// **'Blessed Theme'**
  String get blessedTheme;

  /// Divine color palette
  ///
  /// In en, this message translates to:
  /// **'Divine Colors'**
  String get divineColors;

  /// Sacred purple color
  ///
  /// In en, this message translates to:
  /// **'Sacred Purple'**
  String get sacredPurple;

  /// Holy gold color
  ///
  /// In en, this message translates to:
  /// **'Holy Gold'**
  String get holyGold;

  /// Blessed cream color
  ///
  /// In en, this message translates to:
  /// **'Blessed Cream'**
  String get blessedCream;

  /// Error message when prayer times fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayer times'**
  String get unableToLoadPrayerTimes;

  /// Message when no events exist for selected date
  ///
  /// In en, this message translates to:
  /// **'No events on this date'**
  String get noEventsOnThisDate;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Go to Today tooltip
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get goToToday;

  /// Previous Month tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// Next Month tooltip
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// Refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Loading reminders message
  ///
  /// In en, this message translates to:
  /// **'Loading reminders...'**
  String get loadingReminders;

  /// Empty reminders state title
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersYet;

  /// Empty reminders state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first reminder'**
  String get tapToCreateFirstReminder;

  /// Create Reminder button
  ///
  /// In en, this message translates to:
  /// **'Create Reminder'**
  String get createReminder;

  /// Reminder created success message
  ///
  /// In en, this message translates to:
  /// **'Reminder created successfully'**
  String get reminderCreatedSuccessfully;

  /// Reminder deleted success message
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted successfully'**
  String get reminderDeletedSuccessfully;

  /// Reminder deletion failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reminder'**
  String get failedToDeleteReminder;

  /// Reminder update failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to update reminder'**
  String get failedToUpdateReminder;

  /// Next Occurrence label
  ///
  /// In en, this message translates to:
  /// **'Next Occurrence'**
  String get nextOccurrence;

  /// Year unit (singular)
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// Year unit (plural)
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Enable action
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Disable action
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Delete reminder dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminderTitle;

  /// Delete reminder confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteReminderConfirmation(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'fa',
    'id',
    'ms',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
