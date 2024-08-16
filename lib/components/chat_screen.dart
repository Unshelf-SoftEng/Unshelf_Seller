import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/views/chats_view.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // get instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9E57), // Green color as in the image
        elevation: 0,
        toolbarHeight: 60,
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color.fromARGB(
                255, 255, 255, 255), // Light green color for the text
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'buyer')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                          receiverName: data['name'],
                          receiverUserID: data.id,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(data['profileImageUrl']),
                  ),
                  title: Text(data['name']),
                );
              },
            );
          } else {
            return const Text('Ongoing');
          }
        },
      ),
    );
  }
}
