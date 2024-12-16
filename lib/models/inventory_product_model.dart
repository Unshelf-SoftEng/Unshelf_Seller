import 'package:unshelf_seller/models/batch_model.dart';

class InventoryProductModel {
  String id;
  String name;
  int? totalStock;
  String? quantifier;
  DateTime? expiryDate;
  int? discount;
  double? price;
  List<BatchModel> batches;
  String mainImageUrl;

  InventoryProductModel({
    required this.id,
    required this.name,
    required this.mainImageUrl,
    this.totalStock,
    this.quantifier,
    this.expiryDate,
    this.price,
    this.discount,
    required this.batches,
  });
}
