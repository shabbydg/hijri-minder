import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/subscription_types.dart';
import '../models/reminder_preferences.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'service_locator.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  late final AuthService _authService;
  late final FirestoreService _firestoreService;
  
  UserProfile? _currentUserProfile;
  StreamController<UserProfile?>? _userProfileController;
  Timer? _trialCheckTimer;

  /// Initialize the subscription service
  Future<void> initialize() async {
    try {
      // Get services from service locator
      _authService = ServiceLocator.authService;
      _firestoreService = ServiceLocator.firestoreService;
      
      _userProfileController = StreamController<UserProfile?>.broadcast();
      
      // Listen to auth state changes
      _authService.authStateChanges().listen((user) {
        if (user != null) {
          _loadUserProfile();
        } else {
          _clearUserProfile();
        }
      });

      // Load current user profile if authenticated
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _loadUserProfile();
      }

      // Start trial check timer
      _startTrialCheckTimer();
      
      debugPrint('SubscriptionService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing SubscriptionService: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _trialCheckTimer?.cancel();
    _userProfileController?.close();
  }

  /// Get current user profile
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// Get user profile stream
  Stream<UserProfile?> get userProfileStream => 
      _userProfileController?.stream ?? Stream.value(null);

  /// Start trial for new user
  Future<UserProfile?> startTrial({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      // Auth guard - require user to be signed in
      if (!_authService.isUserSignedIn()) {
        debugPrint('Error starting trial: User must be authenticated');
        return null;
      }

      final reminderPreferences = ReminderPreferences.trialUserSettings();
      final userProfile = UserProfile.createNew(
        userId: userId,
        email: email,
        displayName: displayName,
        defaultReminderSettings: reminderPreferences,
      );

      await _firestoreService.saveUserProfile(userProfile);
      _currentUserProfile = userProfile;
      _userProfileController?.add(userProfile);

      debugPrint('Trial started for user: $userId');
      return userProfile;
    } catch (e) {
      debugPrint('Error starting trial: $e');
      return null;
    }
  }

  /// Check trial status and handle expiration
  Future<void> checkTrialStatus() async {
    if (_currentUserProfile == null) return;

    final profile = _currentUserProfile!;
    
    if (profile.isTrialExpired && profile.subscriptionStatus == SubscriptionStatus.trial) {
      // Trial expired, downgrade to free
      final updatedProfile = profile.expireSubscription();
      await updateUserProfile(updatedProfile);
      
      debugPrint('Trial expired for user: ${profile.userId}');
    }
  }

  /// Get remaining trial days
  int getRemainingTrialDays() {
    return _currentUserProfile?.remainingTrialDays ?? 0;
  }

  /// Activate subscription
  Future<bool> activateSubscription({
    required SubscriptionType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_currentUserProfile == null) return false;

    try {
      final updatedProfile = _currentUserProfile!.activateSubscription(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      await updateUserProfile(updatedProfile);
      debugPrint('Subscription activated for user: ${_currentUserProfile!.userId}');
      return true;
    } catch (e) {
      debugPrint('Error activating subscription: $e');
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    if (_currentUserProfile == null) return false;

    try {
      final updatedProfile = _currentUserProfile!.cancelSubscription();
      await updateUserProfile(updatedProfile);
      debugPrint('Subscription cancelled for user: ${_currentUserProfile!.userId}');
      return true;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return false;
    }
  }

  /// Check subscription status
  SubscriptionStatus checkSubscriptionStatus() {
    return _currentUserProfile?.subscriptionStatus ?? SubscriptionStatus.free;
  }

  /// Check if user has access to Hijri reminders
  bool hasAccessToHijriReminders() {
    return _currentUserProfile?.canCreateHijriReminders ?? false;
  }

  /// Returns true if the user has an active trial or premium subscription
  Future<bool> hasActiveSubscription() async {
    try {
      // Ensure initialization attempted
      if (_currentUserProfile == null) {
        await _loadUserProfile();
      }
      final profile = _currentUserProfile;
      if (profile == null) return false;
      return profile.hasPremiumAccess;
    } catch (_) {
      return false;
    }
  }

  /// Check if user has access to messaging features
  bool hasAccessToMessaging() {
    return _currentUserProfile?.canUseMessagingFeatures ?? false;
  }

  /// Check if user can create reminders (within limits)
  bool canCreateReminder({int? currentReminderCount}) {
    if (_currentUserProfile == null) return false;
    
    final status = _currentUserProfile!.subscriptionStatus;
    final limit = SubscriptionConstants.getReminderLimit(status);
    
    // For unlimited (premium), always allow
    if (limit == -1) return true;
    
    // For limited plans, check current count
    // TODO: Implement proper reminder count fetching from FirestoreService
    // For now, use passed-in count or assume limit not reached
    if (currentReminderCount != null) {
      return currentReminderCount < limit;
    }
    
    // Placeholder: assume user can create reminders until proper count is implemented
    debugPrint('SubscriptionService: canCreateReminder - reminder count not available, allowing creation');
    return true;
  }

  /// Check if user has access to a specific premium feature
  bool hasAccessToFeature(PremiumFeature feature) {
    if (_currentUserProfile == null) return false;
    return SubscriptionConstants.hasFeatureAccess(
      _currentUserProfile!.subscriptionStatus,
      feature,
    );
  }

  /// Create user profile
  Future<UserProfile?> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    ReminderPreferences? reminderPreferences,
  }) async {
    try {
      final profile = UserProfile.createNew(
        userId: userId,
        email: email,
        displayName: displayName,
        defaultReminderSettings: reminderPreferences ?? ReminderPreferences.defaultSettings(),
      );

      await _firestoreService.saveUserProfile(profile);
      _currentUserProfile = profile;
      _userProfileController?.add(profile);

      debugPrint('User profile created: $userId');
      return profile;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateUserProfile(updatedProfile);
      _currentUserProfile = updatedProfile;
      _userProfileController?.add(updatedProfile);

      debugPrint('User profile updated: ${profile.userId}');
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final profile = await _firestoreService.loadUserProfile(userId);
      if (profile != null) {
        _currentUserProfile = profile;
        _userProfileController?.add(profile);
      }
      return profile;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin() async {
    if (_currentUserProfile == null) return;

    try {
      final updatedProfile = _currentUserProfile!.updateLastLogin();
      await updateUserProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  /// Get default reminder settings for current user
  ReminderPreferences getDefaultReminderSettings() {
    return _currentUserProfile?.defaultReminderSettings ?? 
           ReminderPreferences.freeUserSettings();
  }

  /// Update default reminder settings
  Future<bool> updateDefaultReminderSettings(ReminderPreferences settings) async {
    if (_currentUserProfile == null) return false;

    try {
      final updatedProfile = _currentUserProfile!.copyWith(
        defaultReminderSettings: settings,
        updatedAt: DateTime.now(),
      );
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error updating reminder settings: $e');
      return false;
    }
  }

  /// Check if user needs to see paywall
  bool shouldShowPaywall(PremiumFeature feature) {
    return !hasAccessToFeature(feature);
  }

  /// Get subscription info for display
  Map<String, dynamic> getSubscriptionInfo() {
    if (_currentUserProfile == null) {
      return {
        'status': 'free',
        'type': null,
        'remainingDays': 0,
        'hasAccess': false,
      };
    }

    final profile = _currentUserProfile!;
    return {
      'status': profile.subscriptionStatus.name,
      'type': profile.subscriptionType?.name,
      'remainingDays': profile.remainingTrialDays,
      'hasAccess': profile.hasPremiumAccess,
      'trialActive': profile.isTrialActive,
      'premiumActive': profile.isPremiumActive,
    };
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final profile = await _firestoreService.loadUserProfile(currentUser.uid);
      if (profile != null) {
        _currentUserProfile = profile;
        _userProfileController?.add(profile);
      } else {
        // Create new profile for existing user
        await createUserProfile(
          userId: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName,
        );
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Clear user profile
  void _clearUserProfile() {
    _currentUserProfile = null;
    _userProfileController?.add(null);
  }

  /// Start trial check timer
  void _startTrialCheckTimer() {
    _trialCheckTimer?.cancel();
    _trialCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      checkTrialStatus();
    });
  }
}
