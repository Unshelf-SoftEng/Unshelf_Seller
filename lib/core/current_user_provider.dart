import 'package:firebase_auth/firebase_auth.dart';

class CurrentUserProvider {
  final FirebaseAuth _auth;

  CurrentUserProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return user.uid;
  }

  String? get email => _auth.currentUser?.email;

  bool get isAuthenticated => _auth.currentUser != null;
}
