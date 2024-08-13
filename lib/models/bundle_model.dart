import 'package:unshelf_seller/models/item_model.dart';

class BundleModel implements ItemModel {
  @override
  String get id => bundleId;
  final String bundleId;
  final String name;
  final List<String> productIds;
  final double price;
  final String mainImageUrl;

  BundleModel({
    required this.bundleId,
    required this.name,
    required this.productIds,
    required this.price,
    required this.mainImageUrl,
  });
}
