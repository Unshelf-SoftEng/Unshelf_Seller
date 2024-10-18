import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/notification_viewmodel.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF6A994E),
      ),
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
                        color: notification.seen ? Colors.green : Colors.blue,
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
                        model.markNotificationAsRead(index);
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
