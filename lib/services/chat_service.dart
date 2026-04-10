import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/interfaces/i_chat_service.dart';
import 'package:unshelf_seller/models/message_model.dart';

class ChatService implements IChatService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  ChatService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _currentUser.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: _currentUser.email ?? '',
        receiverId: receiverId,
        timestamp: timestamp,
        message: message);

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection(FirestoreConstants.chatRooms)
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  @override
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection(FirestoreConstants.chatRooms)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
