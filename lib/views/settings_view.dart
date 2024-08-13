import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: viewModel.settings.notificationsEnabled,
                onChanged: (bool value) {
                  viewModel.toggleNotifications(value);
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help & Feedback'),
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
