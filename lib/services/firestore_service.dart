import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/reminder.dart';
import '../models/islamic_event.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// Custom Firestore exceptions
class FirestoreException implements Exception {
  final String message;
  final String? code;
  
  FirestoreException(this.message, [this.code]);
  
  @override
  String toString() => 'FirestoreException: $message';
}

/// Service for managing Firestore database operations
/// Provides cloud storage for user data with offline support
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  /// Initialize the Firestore service
  Future<void> initialize() async {
    try {
      // Enable offline persistence
      await _firestore.enablePersistence();
      debugPrint('FirestoreService: Initialized with offline persistence');
    } catch (e) {
      debugPrint('FirestoreService: Initialization error: $e');
      // Continue without offline persistence if it fails
    }
  }
  
  /// Get current user ID
  String? get _currentUserId => _authService.getCurrentUserId();
  
  /// Check if user is authenticated
  bool get _isAuthenticated => _authService.isUserSignedIn();
  
  /// Save user settings to Firestore
  Future<bool> saveUserSettings(AppSettings settings) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save settings');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .set(settings.toJson());
      
      debugPrint('FirestoreService: Settings saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving settings: $e');
      throw FirestoreException('Failed to save settings: ${e.toString()}');
    }
  }
  
  /// Load user settings from Firestore
  Future<AppSettings?> loadUserSettings() async {
    if (!_isAuthenticated) {
      return null;
    }
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .get();
      
      if (doc.exists) {
        final settings = AppSettings.fromJson(doc.data()!);
        debugPrint('FirestoreService: Settings loaded successfully');
        return settings;
      }
      
      debugPrint('FirestoreService: No settings found for user');
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Error loading settings: $e');
      throw FirestoreException('Failed to load settings: ${e.toString()}');
    }
  }
  
  /// Save user reminders to Firestore
  Future<bool> saveReminders(List<Reminder> reminders) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save reminders');
    }
    
    try {
      final batch = _firestore.batch();
      
      // Clear existing reminders
      final existingReminders = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .get();
      
      for (final doc in existingReminders.docs) {
        batch.delete(doc.reference);
      }
      
      // Add new reminders
      for (final reminder in reminders) {
        final docRef = _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('reminders')
            .doc(reminder.id);
        
        batch.set(docRef, {
          ...reminder.toJson(),
          'userId': _currentUserId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('FirestoreService: ${reminders.length} reminders saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving reminders: $e');
      throw FirestoreException('Failed to save reminders: ${e.toString()}');
    }
  }
  
  /// Load user reminders from Firestore
  Future<List<Reminder>> loadReminders() async {
    if (!_isAuthenticated) {
      return [];
    }
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .orderBy('createdAt', descending: true)
          .get();
      
      final reminders = querySnapshot.docs
          .map((doc) => Reminder.fromJson(doc.data()))
          .toList();
      
      debugPrint('FirestoreService: ${reminders.length} reminders loaded successfully');
      return reminders;
    } catch (e) {
      debugPrint('FirestoreService: Error loading reminders: $e');
      throw FirestoreException('Failed to load reminders: ${e.toString()}');
    }
  }
  
  /// Save user events to Firestore
  Future<bool> saveEvents(List<IslamicEvent> events) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save events');
    }
    
    try {
      final batch = _firestore.batch();
      
      // Clear existing events
      final existingEvents = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .get();
      
      for (final doc in existingEvents.docs) {
        batch.delete(doc.reference);
      }
      
      // Add new events
      for (final event in events) {
        final docRef = _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('events')
            .doc(event.id);
        
        batch.set(docRef, {
          ...event.toJson(),
          'userId': _currentUserId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('FirestoreService: ${events.length} events saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving events: $e');
      throw FirestoreException('Failed to save events: ${e.toString()}');
    }
  }
  
  /// Load user events from Firestore
  Future<List<IslamicEvent>> loadEvents() async {
    if (!_isAuthenticated) {
      return [];
    }
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .orderBy('date', descending: false)
          .get();
      
      final events = querySnapshot.docs
          .map((doc) => IslamicEvent.fromJson(doc.data()))
          .toList();
      
      debugPrint('FirestoreService: ${events.length} events loaded successfully');
      return events;
    } catch (e) {
      debugPrint('FirestoreService: Error loading events: $e');
      throw FirestoreException('Failed to load events: ${e.toString()}');
    }
  }
  
  /// Get real-time updates for reminders
  Stream<List<Reminder>> getRemindersStream() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('reminders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reminder.fromJson(doc.data()))
            .toList());
  }

  /// Backwards-compat alias used by ReminderService
  Stream<List<Reminder>> getReminderUpdates() {
    return getRemindersStream();
  }
  
  /// Get real-time updates for events
  Stream<List<IslamicEvent>> getEventsStream() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IslamicEvent.fromJson(doc.data()))
            .toList());
  }
  
  /// Save a single reminder
  Future<bool> saveReminder(Reminder reminder) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save reminder');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .doc(reminder.id)
          .set({
        ...reminder.toJson(),
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('FirestoreService: Reminder saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving reminder: $e');
      throw FirestoreException('Failed to save reminder: ${e.toString()}');
    }
  }
  
  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to delete reminder');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .doc(reminderId)
          .delete();
      
      debugPrint('FirestoreService: Reminder deleted successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting reminder: $e');
      throw FirestoreException('Failed to delete reminder: ${e.toString()}');
    }
  }
  
  /// Save a single event
  Future<bool> saveEvent(IslamicEvent event) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save event');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .doc(event.id)
          .set({
        ...event.toJson(),
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('FirestoreService: Event saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving event: $e');
      throw FirestoreException('Failed to save event: ${e.toString()}');
    }
  }
  
  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to delete event');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .doc(eventId)
          .delete();
      
      debugPrint('FirestoreService: Event deleted successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting event: $e');
      throw FirestoreException('Failed to delete event: ${e.toString()}');
    }
  }
  
  /// Sync all user data to Firestore
  Future<bool> syncUserData({
    AppSettings? settings,
    List<Reminder>? reminders,
    List<IslamicEvent>? events,
  }) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to sync data');
    }
    
    try {
      final batch = _firestore.batch();
      
      // Sync settings
      if (settings != null) {
        final settingsRef = _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('settings')
            .doc('app_settings');
        batch.set(settingsRef, settings.toJson());
      }
      
      // Sync reminders
      if (reminders != null) {
        // Clear existing reminders
        final existingReminders = await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('reminders')
            .get();
        
        for (final doc in existingReminders.docs) {
          batch.delete(doc.reference);
        }
        
        // Add new reminders
        for (final reminder in reminders) {
          final reminderRef = _firestore
              .collection('users')
              .doc(_currentUserId)
              .collection('reminders')
              .doc(reminder.id);
          
          batch.set(reminderRef, {
            ...reminder.toJson(),
            'userId': _currentUserId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      // Sync events
      if (events != null) {
        // Clear existing events
        final existingEvents = await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('events')
            .get();
        
        for (final doc in existingEvents.docs) {
          batch.delete(doc.reference);
        }
        
        // Add new events
        for (final event in events) {
          final eventRef = _firestore
              .collection('users')
              .doc(_currentUserId)
              .collection('events')
              .doc(event.id);
          
          batch.set(eventRef, {
            ...event.toJson(),
            'userId': _currentUserId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();
      debugPrint('FirestoreService: User data synced successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error syncing user data: $e');
      throw FirestoreException('Failed to sync user data: ${e.toString()}');
    }
  }
  
  /// Load all user data from Firestore
  Future<Map<String, dynamic>> loadAllUserData() async {
    if (!_isAuthenticated) {
      return {};
    }
    
    try {
      final settings = await loadUserSettings();
      final reminders = await loadReminders();
      final events = await loadEvents();
      
      return {
        'settings': settings,
        'reminders': reminders,
        'events': events,
      };
    } catch (e) {
      debugPrint('FirestoreService: Error loading all user data: $e');
      throw FirestoreException('Failed to load user data: ${e.toString()}');
    }
  }
  
  /// Check if user has any data in Firestore
  Future<bool> hasUserData() async {
    if (!_isAuthenticated) {
      return false;
    }
    
    try {
      final settingsSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings')
          .get();
      
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .limit(1)
          .get();
      
      final eventsSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .limit(1)
          .get();
      
      return settingsSnapshot.exists || 
             remindersSnapshot.docs.isNotEmpty || 
             eventsSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('FirestoreService: Error checking user data: $e');
      return false;
    }
  }
  
  /// Clear all user data from Firestore
  Future<bool> clearAllUserData() async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to clear data');
    }
    
    try {
      final batch = _firestore.batch();
      
      // Delete settings
      final settingsRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('settings')
          .doc('app_settings');
      batch.delete(settingsRef);
      
      // Delete reminders
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reminders')
          .get();
      
      for (final doc in remindersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete events
      final eventsSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events')
          .get();
      
      for (final doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('FirestoreService: All user data cleared successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error clearing user data: $e');
      throw FirestoreException('Failed to clear user data: ${e.toString()}');
    }
  }

  // User Profile Management Methods

  /// Save user profile to Firestore
  Future<bool> saveUserProfile(UserProfile profile) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to save profile');
    }
    
    try {
      final profileData = profile.toFirestore();
      
      // Set server timestamp for createdAt if it's a new profile
      if (profile.createdAt == profile.updatedAt) {
        profileData['createdAt'] = FieldValue.serverTimestamp();
      }
      profileData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('user_profile')
          .set(profileData);
      
      debugPrint('FirestoreService: User profile saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving user profile: $e');
      throw FirestoreException('Failed to save user profile: ${e.toString()}');
    }
  }

  /// Load user profile from Firestore
  Future<UserProfile?> loadUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('user_profile')
          .get();
      
      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc.data()!);
        debugPrint('FirestoreService: User profile loaded successfully');
        return profile;
      }
      
      debugPrint('FirestoreService: No user profile found');
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Error loading user profile: $e');
      throw FirestoreException('Failed to load user profile: ${e.toString()}');
    }
  }

  /// Update user profile in Firestore
  Future<bool> updateUserProfile(UserProfile profile) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to update profile');
    }
    
    try {
      final profileData = profile.toFirestore();
      profileData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('user_profile')
          .update(profileData);
      
      debugPrint('FirestoreService: User profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error updating user profile: $e');
      throw FirestoreException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Delete user profile from Firestore
  Future<bool> deleteUserProfile(String userId) async {
    if (!_isAuthenticated) {
      throw FirestoreException('User must be authenticated to delete profile');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('user_profile')
          .delete();
      
      debugPrint('FirestoreService: User profile deleted successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error deleting user profile: $e');
      throw FirestoreException('Failed to delete user profile: ${e.toString()}');
    }
  }

  /// Get real-time updates for user profile
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('user_profile')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot.data()!);
      }
      return null;
    });
  }

  /// Save subscription data to Firestore
  Future<bool> saveSubscriptionData({
    required String userId,
    required Map<String, dynamic> subscriptionData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('subscription_data')
          .set({
        ...subscriptionData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('FirestoreService: Subscription data saved successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error saving subscription data: $e');
      throw FirestoreException('Failed to save subscription data: ${e.toString()}');
    }
  }

  /// Load subscription data from Firestore
  Future<Map<String, dynamic>?> loadSubscriptionData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('subscription_data')
          .get();
      
      if (doc.exists) {
        debugPrint('FirestoreService: Subscription data loaded successfully');
        return doc.data();
      }
      
      debugPrint('FirestoreService: No subscription data found');
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Error loading subscription data: $e');
      throw FirestoreException('Failed to load subscription data: ${e.toString()}');
    }
  }

  /// Get real-time updates for subscription data
  Stream<Map<String, dynamic>?> getSubscriptionDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('subscription')
        .doc('subscription_data')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  /// Batch operations for user data migration
  Future<bool> migrateUserData({
    required String fromUserId,
    required String toUserId,
    bool includeProfile = true,
    bool includeSettings = true,
    bool includeReminders = true,
    bool includeEvents = true,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Migrate profile
      if (includeProfile) {
        final profileDoc = await _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('profile')
            .doc('user_profile')
            .get();
        
        if (profileDoc.exists) {
          final profileRef = _firestore
              .collection('users')
              .doc(toUserId)
              .collection('profile')
              .doc('user_profile');
          batch.set(profileRef, profileDoc.data()!);
        }
      }
      
      // Migrate settings
      if (includeSettings) {
        final settingsDoc = await _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('settings')
            .doc('app_settings')
            .get();
        
        if (settingsDoc.exists) {
          final settingsRef = _firestore
              .collection('users')
              .doc(toUserId)
              .collection('settings')
              .doc('app_settings');
          batch.set(settingsRef, settingsDoc.data()!);
        }
      }
      
      // Migrate reminders
      if (includeReminders) {
        final remindersSnapshot = await _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('reminders')
            .get();
        
        for (final doc in remindersSnapshot.docs) {
          final reminderRef = _firestore
              .collection('users')
              .doc(toUserId)
              .collection('reminders')
              .doc(doc.id);
          batch.set(reminderRef, doc.data());
        }
      }
      
      // Migrate events
      if (includeEvents) {
        final eventsSnapshot = await _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('events')
            .get();
        
        for (final doc in eventsSnapshot.docs) {
          final eventRef = _firestore
              .collection('users')
              .doc(toUserId)
              .collection('events')
              .doc(doc.id);
          batch.set(eventRef, doc.data());
        }
      }
      
      await batch.commit();
      debugPrint('FirestoreService: User data migrated successfully');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error migrating user data: $e');
      throw FirestoreException('Failed to migrate user data: ${e.toString()}');
    }
  }

  /// Check if user profile exists
  Future<bool> hasUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('user_profile')
          .get();
      
      return doc.exists;
    } catch (e) {
      debugPrint('FirestoreService: Error checking user profile: $e');
      return false;
    }
  }

  /// Get user profile collection reference
  CollectionReference getUserProfileCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile');
  }

  /// Get user settings collection reference
  CollectionReference getUserSettingsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings');
  }

  /// Get user reminders collection reference
  CollectionReference getUserRemindersCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders');
  }

  /// Get user events collection reference
  CollectionReference getUserEventsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events');
  }
}
