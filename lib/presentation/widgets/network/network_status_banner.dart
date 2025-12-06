import 'package:flutter/material.dart';
import 'package:flutter_core_project/services/network_service.dart';

/// Widget to display network status banner
class NetworkStatusBanner extends StatelessWidget {
  final Widget child;

  const NetworkStatusBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NetworkStatus>(
      valueListenable: NetworkService().networkStatus,
      builder: (context, networkStatus, _) {
        return Stack(
          children: [
            child,
            if (networkStatus == NetworkStatus.offline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No Internet Connection',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Dialog to show when network is offline
class NoInternetDialog extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetDialog({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        Icons.cloud_off,
        color: Colors.red.shade600,
        size: 64,
      ),
      title: const Text('No Internet Connection'),
      content: const Text(
        'Please check your internet connection and try again.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onRetry?.call();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
