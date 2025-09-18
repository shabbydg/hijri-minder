import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'location_service.dart';
import 'settings_service.dart';
import 'events_service.dart';
import 'prayer_times_service.dart';
import 'reminder_service.dart';
import 'notification_service.dart';
import 'message_templates_service.dart';
import 'sharing_service.dart';
import 'localization_service.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';
import 'cache_manager.dart';
import 'performance_service.dart';
import 'network_optimizer.dart';
import 'offline_manager.dart';
import '../utils/memory_manager.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'subscription_service.dart';

/// Service locator for dependency injection
/// Provides centralized access to all services in the application
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// Initialize all services and register them with GetIt
  /// Call this method during app initialization
  static Future<void> setupServices() async {
    // Register LocationService as singleton
    _getIt.registerLazySingleton<LocationService>(() => LocationService());

    // Register SettingsService as singleton
    _getIt.registerLazySingleton<SettingsService>(() => SettingsService());

    // Register EventsService as singleton
    _getIt.registerLazySingleton<EventsService>(() => EventsService());

    // Register PrayerTimesService as singleton
    _getIt.registerLazySingleton<PrayerTimesService>(() => PrayerTimesService());

    // Register ReminderService as singleton
    _getIt.registerLazySingleton<ReminderService>(() => ReminderService());

    // Register NotificationService as singleton
    _getIt.registerLazySingleton<NotificationService>(() => NotificationService());

    // Register MessageTemplatesService as singleton
    _getIt.registerLazySingleton<MessageTemplatesService>(() => MessageTemplatesService());

    // Register SharingService as singleton
    _getIt.registerLazySingleton<SharingService>(() => SharingService());

    // Register LocalizationService as singleton
    _getIt.registerLazySingleton<LocalizationService>(() => LocalizationService());

    // Register ConnectivityService as singleton
    _getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

    // Register CacheService as singleton
    _getIt.registerLazySingleton<CacheService>(() => CacheService());

    // Register OfflineManager as singleton
    _getIt.registerLazySingleton<OfflineManager>(() => OfflineManager());

    // Register performance services as singletons
    _getIt.registerLazySingleton<PerformanceService>(() => PerformanceService());
    _getIt.registerLazySingleton<CacheManager>(() => CacheManager());
    _getIt.registerLazySingleton<NetworkOptimizer>(() => NetworkOptimizer());
    _getIt.registerLazySingleton<MemoryManager>(() => MemoryManager());

    // Register AuthService as singleton
    _getIt.registerLazySingleton<AuthService>(() => AuthService());

    // Register FirestoreService as singleton
    _getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());

    // Register SubscriptionService as singleton
    _getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());

    // Initialize services that require setup
    await _initializeServices();
  }

  /// Initialize services that require async setup
  static Future<void> _initializeServices() async {
    try {
      // Initialize AuthService first
      final authService = _getIt<AuthService>();
      await authService.initialize();

      // Initialize FirestoreService
      final firestoreService = _getIt<FirestoreService>();
      await firestoreService.initialize();

      // Initialize SettingsService to load cached settings
      final settingsService = _getIt<SettingsService>();
      await settingsService.getSettings();

      // Initialize NotificationService
      final notificationService = _getIt<NotificationService>();
      await notificationService.initialize();

      // Request location permissions if enabled in settings (skip on web)
      final settings = await settingsService.getSettings();
      if (settings.enableLocationServices && !kIsWeb) {
        final locationService = _getIt<LocationService>();
        await locationService.requestLocationPermissionWithDialog();
      }

      // Request notification permissions if enabled in settings (skip on web)
      if (settings.enablePrayerNotifications && !kIsWeb) {
        await notificationService.requestPermissions();
      }

      // Initialize LocalizationService
      final localizationService = _getIt<LocalizationService>();
      await localizationService.initialize();

      // Initialize OfflineManager (this will also initialize ConnectivityService)
      final offlineManager = _getIt<OfflineManager>();
      await offlineManager.initialize();

      // Initialize performance services
      final performanceService = _getIt<PerformanceService>();
      await performanceService.initialize();

      final cacheManager = _getIt<CacheManager>();
      await cacheManager.initialize();

      final networkOptimizer = _getIt<NetworkOptimizer>();
      await networkOptimizer.initialize();

      final memoryManager = _getIt<MemoryManager>();
      await memoryManager.initialize();

      // Initialize SubscriptionService
      final subscriptionService = _getIt<SubscriptionService>();
      await subscriptionService.initialize();

      // Initialize ReminderService (enhanced with cloud sync)
      final reminderService = _getIt<ReminderService>();
      await reminderService.initialize();
    } catch (e) {
      // Log error but don't prevent app startup
      debugPrint('ServiceLocator: Error initializing services: $e');
    }
  }

  /// Get LocationService instance
  static LocationService get locationService => _getIt<LocationService>();

  /// Get SettingsService instance
  static SettingsService get settingsService => _getIt<SettingsService>();

  /// Get EventsService instance
  static EventsService get eventsService => _getIt<EventsService>();

  /// Get PrayerTimesService instance
  static PrayerTimesService get prayerTimesService => _getIt<PrayerTimesService>();

  /// Get ReminderService instance
  static ReminderService get reminderService => _getIt<ReminderService>();

  /// Get NotificationService instance
  static NotificationService get notificationService => _getIt<NotificationService>();

  /// Get MessageTemplatesService instance
  static MessageTemplatesService get messageTemplatesService => _getIt<MessageTemplatesService>();

  /// Get SharingService instance
  static SharingService get sharingService => _getIt<SharingService>();

  /// Get LocalizationService instance
  static LocalizationService get localizationService => _getIt<LocalizationService>();

  /// Get ConnectivityService instance
  static ConnectivityService get connectivityService => _getIt<ConnectivityService>();

  /// Get CacheService instance
  static CacheService get cacheService => _getIt<CacheService>();

  /// Get OfflineManager instance
  static OfflineManager get offlineManager => _getIt<OfflineManager>();

  /// Get PerformanceService instance
  static PerformanceService get performanceService => _getIt<PerformanceService>();

  /// Get CacheManager instance
  static CacheManager get cacheManager => _getIt<CacheManager>();

  /// Get NetworkOptimizer instance
  static NetworkOptimizer get networkOptimizer => _getIt<NetworkOptimizer>();

  /// Get MemoryManager instance
  static MemoryManager get memoryManager => _getIt<MemoryManager>();

  /// Get AuthService instance
  static AuthService get authService => _getIt<AuthService>();

  /// Get FirestoreService instance
  static FirestoreService get firestoreService => _getIt<FirestoreService>();

  /// Get SubscriptionService instance
  static SubscriptionService get subscriptionService => _getIt<SubscriptionService>();

  /// Reset all services (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }

  /// Check if services are registered
  static bool get isReady => _getIt.isRegistered<LocationService>() &&
                            _getIt.isRegistered<SettingsService>() &&
                            _getIt.isRegistered<EventsService>() &&
                            _getIt.isRegistered<PrayerTimesService>() &&
                            _getIt.isRegistered<NotificationService>() &&
                            _getIt.isRegistered<MessageTemplatesService>() &&
                            _getIt.isRegistered<SharingService>() &&
                            _getIt.isRegistered<LocalizationService>() &&
                            _getIt.isRegistered<ConnectivityService>() &&
                            _getIt.isRegistered<CacheService>() &&
                            _getIt.isRegistered<OfflineManager>() &&
                            _getIt.isRegistered<AuthService>() &&
                            _getIt.isRegistered<FirestoreService>() &&
                            _getIt.isRegistered<SubscriptionService>();
}

/// Extension methods for easy service access
extension ServiceLocatorExtension on Object {
  /// Get LocationService instance
  LocationService get locationService => ServiceLocator.locationService;

  /// Get SettingsService instance
  SettingsService get settingsService => ServiceLocator.settingsService;

  /// Get EventsService instance
  EventsService get eventsService => ServiceLocator.eventsService;

  /// Get PrayerTimesService instance
  PrayerTimesService get prayerTimesService => ServiceLocator.prayerTimesService;

  /// Get NotificationService instance
  NotificationService get notificationService => ServiceLocator.notificationService;

  /// Get MessageTemplatesService instance
  MessageTemplatesService get messageTemplatesService => ServiceLocator.messageTemplatesService;

  /// Get SharingService instance
  SharingService get sharingService => ServiceLocator.sharingService;

  /// Get LocalizationService instance
  LocalizationService get localizationService => ServiceLocator.localizationService;

  /// Get ConnectivityService instance
  ConnectivityService get connectivityService => ServiceLocator.connectivityService;

  /// Get CacheService instance
  CacheService get cacheService => ServiceLocator.cacheService;

  /// Get OfflineManager instance
  OfflineManager get offlineManager => ServiceLocator.offlineManager;

  /// Get AuthService instance
  AuthService get authService => ServiceLocator.authService;

  /// Get FirestoreService instance
  FirestoreService get firestoreService => ServiceLocator.firestoreService;

  /// Get SubscriptionService instance
  SubscriptionService get subscriptionService => ServiceLocator.subscriptionService;
}