class NotificationModel {
  final String id;
  final String title;
  final String text;
  bool seen;

  NotificationModel({
    required this.id,
    required this.title,
    required this.text,
    this.seen = false,
  });

  factory NotificationModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      text: data['message'] ?? '',
      seen: data['seen'] ?? false,
    );
  }
}
