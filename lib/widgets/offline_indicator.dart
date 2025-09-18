import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/offline_manager.dart';

/// Widget that displays offline status indicator
/// Shows when the app is offline and provides sync options
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showSyncButton;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.showSyncButton = true,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineManager _offlineManager = OfflineManager();
  bool _isOnline = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _isSyncing = _offlineManager.isSyncing;
    
    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline) _buildOfflineIndicator(context),
        if (_isSyncing) _buildSyncIndicator(context),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Some features may be limited.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.showSyncButton)
            TextButton(
              onPressed: _isOnline ? null : () => _showOfflineOptions(context),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade100,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Syncing data...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => OfflineOptionsSheet(),
    );
  }
}

/// Bottom sheet with offline options and status
class OfflineOptionsSheet extends StatefulWidget {
  @override
  State<OfflineOptionsSheet> createState() => _OfflineOptionsSheetState();
}

class _OfflineOptionsSheetState extends State<OfflineOptionsSheet> {
  final OfflineManager _offlineManager = OfflineManager();
  Map<String, dynamic>? _offlineStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfflineStatus();
  }

  Future<void> _loadOfflineStatus() async {
    try {
      final status = await _offlineManager.getOfflineStatus();
      if (mounted) {
        setState(() {
          _offlineStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Offline Mode',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_offlineStatus != null)
            _buildStatusInfo(context)
          else
            const Text('Unable to load offline status'),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _offlineManager.prepareForOffline();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prepared for offline use'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Prepare for Offline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _offlineManager.clearAllCache();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache cleared'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Cache'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    final status = _offlineStatus!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('Connection', status['isOnline'] ? 'Online' : 'Offline'),
        _buildStatusRow('Cache Size', '${status['totalCacheSize']} entries'),
        _buildStatusRow('Syncing', status['isSyncing'] ? 'Yes' : 'No'),
        
        const SizedBox(height: 8),
        Text(
          'Available Offline:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        
        _buildFeatureStatus('Prayer Times', status['prayerTimes']?['memoryCacheSize'] ?? 0),
        _buildFeatureStatus('Islamic Events', status['events']?['eventsCount'] ?? 0),
        _buildFeatureStatus('Settings', status['settings']?['hasSettings'] ?? false),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(String feature, dynamic status) {
    final isAvailable = status is bool ? status : (status as num) > 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(feature),
          if (status is num && status > 0)
            Text(' (${status} cached)', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}