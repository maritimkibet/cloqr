import 'package:flutter/material.dart';

class ScanQRScreen extends StatelessWidget {
  const ScanQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'QR Scanner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Scan a room QR code to join'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement QR scanner
                Navigator.pop(context);
              },
              child: const Text('Start Scanning'),
            ),
          ],
        ),
      ),
    );
  }
}
