import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Light Mode Toggle
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light Mode'),
            trailing: Switch(
              value: false, // Dummy value, you can bind this to actual settings
              onChanged: (value) {
                // Implement functionality for toggling light mode
              },
            ),
          ),

          // Notifications Toggle
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true, // Dummy value
              onChanged: (value) {
                // Implement functionality for toggling notifications
              },
            ),
          ),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Implement logout functionality
            },
          ),

          // Delete Account Button
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            onTap: () {
              // Implement account deletion functionality
            },
          ),

          // Spacer to push items to the top
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
