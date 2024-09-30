import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/settings_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/user_profile_viewmodel.dart';
import 'package:unshelf_seller/views/home_view.dart';
import 'package:unshelf_seller/views/login_view.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/product_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/store_location_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/listing_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/dashboard_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/product_summary_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: "1:733152787617:android:3c3e7b87d0cb7c59f544e0",
      messagingSenderId: "733152787617",
      projectId: "unshelf-d4567",
      storageBucket: "unshelf-d4567.appspot.com",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(productId: null),
        ),
        ChangeNotifierProvider(create: (_) => StoreViewModel()),
        ChangeNotifierProvider(create: (_) => StoreLocationViewModel()),
        ChangeNotifierProvider(create: (_) => RestockViewModel()),
        ChangeNotifierProvider(create: (_) => BundleViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
            create: (_) => UserProfileViewModel(userProfile: null)),
        ChangeNotifierProvider(create: (_) => ListingViewModel()),
        ChangeNotifierProvider(create: (_) => ProductSummaryViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unshelf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF386641)),
        useMaterial3: true,
        textTheme: GoogleFonts.jostTextTheme(Theme.of(context).textTheme),
      ),
      home:
          FirebaseAuth.instance.currentUser != null ? HomeView() : LoginView(),
    );
  }
}
