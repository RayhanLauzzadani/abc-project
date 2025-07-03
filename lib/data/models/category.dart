class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final int orderIndex;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.orderIndex,
    required this.isActive,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
      'isActive': isActive,
    };
  }
}
