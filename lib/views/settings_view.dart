import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/settings_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Settings',
          onBackPressed: () {
            Navigator.pop(context);
          }),
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
