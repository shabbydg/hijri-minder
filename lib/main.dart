import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/service_locator.dart';
import 'services/localization_service.dart';
import 'services/logging_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/events_screen.dart';
import 'screens/settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'utils/error_handler.dart';
import 'utils/platform_config.dart';
import 'screens/auth/auth_wrapper.dart';
import 'theme/app_theme.dart';
import 'widgets/islamic_patterns.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling system
  ErrorHandler.initialize();
  
  // Initialize logging service
  await LoggingService.initialize();
  
  // Log app startup
  LoggingService.logInfo('HijriMinder app starting up');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggingService.logInfo('Firebase initialized successfully');
    
    // Initialize all services
    await ServiceLocator.setupServices();
    
    // Configure notification channels for Android
    await PlatformConfig.configureNotificationChannels();
    
    LoggingService.logInfo('All services initialized successfully');
  } catch (e, stackTrace) {
    LoggingService.logCritical(
      'Failed to initialize services',
      details: e.toString(),
      stackTrace: stackTrace.toString(),
    );
  }
  
  runApp(const HijriMinderApp());
}

class HijriMinderApp extends StatelessWidget {
  const HijriMinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalizationService>(
      create: (context) => ServiceLocator.localizationService,
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: 'HijriMinder',
            // Localization configuration
            locale: localizationService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ar'), // Arabic
              Locale('id'), // Indonesian
              Locale('ur'), // Urdu
              Locale('ms'), // Malay
              Locale('tr'), // Turkish
              Locale('fa'), // Persian
              Locale('bn'), // Bengali
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const CalendarScreen(),
    const PrayerTimesScreen(),
    const ReminderScreen(),
    const EventsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Debug: Print the number of screens
    debugPrint('Number of screens: ${_screens.length}');
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Ensure index is within bounds
    debugPrint('Current index: $_currentIndex, Screens length: ${_screens.length}');
    if (_currentIndex >= _screens.length) {
      debugPrint('Index out of bounds! Resetting to 0');
      _currentIndex = 0;
    }
    
    return Scaffold(
      body: GeometricBackground(
        color: AppTheme.primaryPurple,
        opacity: 0.03,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryPurple,
              AppTheme.darkPurple,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            debugPrint('Tapped index: $index');
            setState(() {
              if (index < _screens.length) {
                _currentIndex = index;
              } else {
                debugPrint('Index $index is out of bounds for ${_screens.length} screens');
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month),
              label: AppLocalizations.of(context)!.calendar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time),
              label: AppLocalizations.of(context)!.prayerTimes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event_note),
              label: AppLocalizations.of(context)!.reminders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event),
              label: AppLocalizations.of(context)!.events,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
        ),
      ),
    );
  }
}
