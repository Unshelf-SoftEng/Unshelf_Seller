import 'package:get_it/get_it.dart';

import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/interfaces/i_auth_service.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_bundle_service.dart';
import 'package:unshelf_seller/core/interfaces/i_chat_service.dart';
import 'package:unshelf_seller/core/interfaces/i_order_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/services/authentication_service.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/services/bundle_service.dart';
import 'package:unshelf_seller/services/chat_service.dart';
import 'package:unshelf_seller/services/order_service.dart';
import 'package:unshelf_seller/services/product_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Core
  locator.registerLazySingleton<CurrentUserProvider>(
    () => CurrentUserProvider(),
  );

  // Services
  locator.registerLazySingleton<IAuthService>(
    () => AuthService(),
  );

  locator.registerLazySingleton<IProductService>(
    () => ProductService(
      currentUser: locator<CurrentUserProvider>(),
    ),
  );

  locator.registerLazySingleton<IBundleService>(
    () => BundleService(
      currentUser: locator<CurrentUserProvider>(),
    ),
  );

  locator.registerLazySingleton<IBatchService>(
    () => BatchService(
      currentUser: locator<CurrentUserProvider>(),
      productService: locator<IProductService>(),
    ),
  );

  locator.registerLazySingleton<IOrderService>(
    () => OrderService(
      currentUser: locator<CurrentUserProvider>(),
      batchService: locator<IBatchService>(),
      bundleService: locator<IBundleService>(),
    ),
  );

  locator.registerLazySingleton<IChatService>(
    () => ChatService(
      currentUser: locator<CurrentUserProvider>(),
    ),
  );
}
