import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unshelf_seller/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCmzJYL0RqnGHP7OCu-8TyNVqWsSdATGf0",
      appId: "1:733152787617:android:3c3e7b87d0cb7c59f544e0",
      messagingSenderId: "733152787617",
      projectId: "unshelf-d4567",
      storageBucket: "unshelf-d4567.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unshelf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignInPage(),
    );
  }
}
