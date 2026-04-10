import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IChatService {
  Future<void> sendMessage(String receiverId, String message);
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId);
}
