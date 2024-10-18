class NotificationModel {
  final String title;
  final String text;
  final bool seen;

  NotificationModel({
    required this.title,
    required this.text,
    this.seen = false,
  });
}
