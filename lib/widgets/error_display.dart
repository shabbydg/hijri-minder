import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../services/logging_service.dart';

/// Widget for displaying user-friendly error messages
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? details;
  final ErrorType? errorType;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.details,
    this.errorType,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userFriendlyMessage = errorType != null 
        ? ErrorHandler.getUserFriendlyMessage(errorType!, message)
        : message;

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getErrorIcon(errorType),
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userFriendlyMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (showDetails && details != null) ...[
              const SizedBox(height: 8),
              Text(
                'Details: $details',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer.withOpacity(0.8),
                ),
              ),
            ],
            if (onRetry != null || onDismiss != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  if (onDismiss != null)
                    TextButton(
                      onPressed: onDismiss,
                      child: const Text('Dismiss'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType? type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.location:
        return Icons.location_off;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.api:
        return Icons.cloud_off;
      case ErrorType.notification:
        return Icons.notifications_off;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.parsing:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}

/// Snackbar for showing error messages
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    ErrorType? errorType,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final userFriendlyMessage = errorType != null 
        ? ErrorHandler.getUserFriendlyMessage(errorType, message)
        : message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(errorType),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(userFriendlyMessage),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(ErrorType? type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.location:
        return Icons.location_off;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.api:
        return Icons.cloud_off;
      case ErrorType.notification:
        return Icons.notifications_off;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.parsing:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}

/// Dialog for showing detailed error information
class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? details;
  final ErrorType? errorType;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.errorType,
    this.onRetry,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
    ErrorType? errorType,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        details: details,
        errorType: errorType,
        onRetry: onRetry,
      ),
    );
  }
}

class _ErrorDialogState extends State<ErrorDialog> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userFriendlyMessage = widget.errorType != null 
        ? ErrorHandler.getUserFriendlyMessage(widget.errorType!, widget.message)
        : widget.message;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getErrorIcon(widget.errorType),
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(userFriendlyMessage),
          if (widget.details != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Technical Details',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.details!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        if (widget.onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRetry!();
            },
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  IconData _getErrorIcon(ErrorType? type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.location:
        return Icons.location_off;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.api:
        return Icons.cloud_off;
      case ErrorType.notification:
        return Icons.notifications_off;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.parsing:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}

/// Widget for handling and displaying async operation errors
class AsyncErrorHandler extends StatelessWidget {
  final Future<Widget> future;
  final Widget Function(BuildContext context, Object error) errorBuilder;
  final Widget? loadingWidget;

  const AsyncErrorHandler({
    super.key,
    required this.future,
    required this.errorBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          // Log the error
          LoggingService.logError(
            'AsyncErrorHandler caught error',
            details: snapshot.error.toString(),
            stackTrace: snapshot.stackTrace.toString(),
          );
          
          return errorBuilder(context, snapshot.error!);
        }
        
        return snapshot.data ?? const SizedBox.shrink();
      },
    );
  }
}

/// Mixin for handling errors in StatefulWidgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  void handleError(
    Object error, {
    String? operation,
    ErrorType? errorType,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    // Log the error
    LoggingService.logError(
      operation != null ? 'Error in $operation: $error' : error.toString(),
      stackTrace: StackTrace.current.toString(),
    );

    if (showSnackBar && mounted) {
      ErrorSnackBar.show(
        context,
        error.toString(),
        errorType: errorType,
        onRetry: onRetry,
      );
    }
  }

  void showErrorDialog(
    String title,
    Object error, {
    ErrorType? errorType,
    VoidCallback? onRetry,
  }) {
    if (mounted) {
      ErrorDialog.show(
        context,
        title: title,
        message: error.toString(),
        errorType: errorType,
        onRetry: onRetry,
      );
    }
  }
}