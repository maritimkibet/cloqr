import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'User Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage all users here',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'User management features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.search),
              title: Text('Search Users'),
              subtitle: Text('Find users by email, username, or campus'),
            ),
            const ListTile(
              leading: Icon(Icons.block),
              title: Text('Ban/Unban Users'),
              subtitle: Text('Manage user access to the platform'),
            ),
            const ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Verify Users'),
              subtitle: Text('Manually verify user accounts'),
            ),
            const ListTile(
              leading: Icon(Icons.analytics),
              title: Text('View User Activity'),
              subtitle: Text('Monitor user behavior and engagement'),
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
