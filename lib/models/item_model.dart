abstract class ItemModel {
  final String id;
  String name;
  String mainImageUrl;
  String category;

  ItemModel({
    required this.id,
    required this.name,
    required this.mainImageUrl,
    required this.category,
  });
}
