import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: viewModel.settings.notificationsEnabled,
                onChanged: (bool value) {
                  viewModel.toggleNotifications(value);
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: const Text('Help & Feedback'),
                onTap: () {
                  // Navigate to Help & Feedback
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
