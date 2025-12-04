import 'package:flutter/material.dart';

class UserReportsScreen extends StatelessWidget {
  const UserReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'User Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage user reports here',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'User reports features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.report),
              title: Text('Pending Reports'),
              subtitle: Text('Review and action user reports'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Resolved Reports'),
              subtitle: Text('View history of resolved reports'),
            ),
            const ListTile(
              leading: Icon(Icons.person_off),
              title: Text('Banned Users'),
              subtitle: Text('Manage banned user accounts'),
            ),
            const ListTile(
              leading: Icon(Icons.warning),
              title: Text('Flagged Content'),
              subtitle: Text('Review flagged messages and profiles'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connect to backend API to enable full functionality',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
