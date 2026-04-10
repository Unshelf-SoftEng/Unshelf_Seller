import 'package:unshelf_seller/models/bundle_model.dart';

abstract class IBundleService {
  Future<BundleModel?> getBundle(String bundleId);
  Future<void> createBundle(BundleModel bundle);
  Future<void> updateBundle(BundleModel bundle);
}
