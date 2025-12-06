import 'package:flutter/material.dart';

/// No Internet Connection UI Component
/// This replaces the dialog with an in-screen UI component
class NoInternetUI extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const NoInternetUI({
    Key? key,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cloud off icon with animation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off,
                  color: Colors.red.shade600,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'Please check your internet connection to load articles.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry ??
                      () {
                        debugPrint('⚠️ onRetry is null');
                      },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onDismiss ??
                      () {
                        debugPrint('⚠️ onDismiss is null');
                      },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
