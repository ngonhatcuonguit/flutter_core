import 'package:flutter/material.dart';
import 'package:flutter_core_project/utils/network_test_helper.dart';

/// Debug page for testing network connectivity
class NetworkDebugPage extends StatefulWidget {
  const NetworkDebugPage({super.key});

  @override
  State<NetworkDebugPage> createState() => _NetworkDebugPageState();
}

class _NetworkDebugPageState extends State<NetworkDebugPage> {
  bool _isRunning = false;
  Map<String, dynamic>? _diagnostics;

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _diagnostics = null;
    });

    try {
      final result = await NetworkTestHelper.runNetworkDiagnostics();
      setState(() {
        _diagnostics = result;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _diagnostics = {
          'error': true,
          'message': e.toString(),
        };
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Connection Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will test if your device can reach:\n'
                      '1. google.com (baseline test)\n'
                      '2. newsapi.org (API server)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRunning ? null : _runDiagnostics,
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Running Diagnostics...'),
                      ],
                    )
                  : const Text('Run Diagnostics'),
            ),
            const SizedBox(height: 24),
            if (_diagnostics != null) ...[
              Card(
                color: _diagnostics!['error'] == true
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _diagnostics!['error'] == true
                                ? Icons.error
                                : Icons.check_circle,
                            color: _diagnostics!['error'] == true
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Diagnostics Results',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (_diagnostics!['error'] == true) ...[
                        Text('Error: ${_diagnostics!['message']}'),
                      ] else ...[
                        _buildTestResult(
                          'Google.com',
                          _diagnostics!['canResolveGoogle'] ?? false,
                        ),
                        const SizedBox(height: 12),
                        _buildTestResult(
                          'NewsAPI.org',
                          _diagnostics!['canResolveNewsApi'] ?? false,
                        ),
                        const Divider(height: 24),
                        Text(
                          'Diagnosis:',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _diagnostics!['diagnosis'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_diagnostics!['canResolveGoogle'] == true &&
                  _diagnostics!['canResolveNewsApi'] == false) ...[
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Troubleshooting Tips',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '1. Check if you are using a VPN\n'
                          '2. Check firewall settings\n'
                          '3. Try changing DNS servers (8.8.8.8, 1.1.1.1)\n'
                          '4. Disable any proxy settings\n'
                          '5. Try on a different network',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestResult(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: passed ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
        const Spacer(),
        Text(
          passed ? 'PASS' : 'FAIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: passed ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
