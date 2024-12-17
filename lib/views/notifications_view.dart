import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/notification_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Notifications',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: Consumer<NotificationViewModel>(
        builder: (context, model, child) {
          return model.notifications.isNotEmpty
              ? ListView.separated(
                  itemCount: model.notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = model.notifications[index];
                    return ListTile(
                      leading: Icon(
                        notification.seen
                            ? Icons.check_circle
                            : Icons.notifications,
                        color: notification.seen
                            ? AppColors.palmLeaf
                            : AppColors.deepMossGreen,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              notification.seen ? Colors.grey : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        notification.text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              notification.seen ? Colors.grey : Colors.black54,
                        ),
                      ),
                      onTap: () {
                        model.markNotificationAsReadAsync(index);
                        Navigator.pop(context); // Close the notifications page
                      },
                    );
                  },
                )
              : const Center(
                  child: ListTile(
                    leading: Icon(Icons.notifications_off, color: Colors.grey),
                    title: Text(
                      'No notifications',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
