import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/viewmodels/analytics_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/batch_history_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/settings_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/user_profile_viewmodel.dart';
import 'package:unshelf_seller/views/home_view.dart';
import 'package:unshelf_seller/authentication/views/login_view.dart';
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
import 'package:unshelf_seller/viewmodels/notification_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/batch_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/select_products_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/product_analytics_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/inventory_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCmzJYL0RqnGHP7OCu-8TyNVqWsSdATGf0",
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
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
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
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => BatchViewModel()),
        ChangeNotifierProvider(create: (_) => SelectProductsViewModel()),
        ChangeNotifierProvider(create: (_) => ProductAnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
        ChangeNotifierProvider(create: (_) => BatchHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
        textTheme: GoogleFonts.jostTextTheme(Theme.of(context).textTheme),
      ),
      home:
          FirebaseAuth.instance.currentUser != null ? HomeView() : LoginView(),
    );
  }
}
