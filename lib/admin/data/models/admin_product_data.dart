import 'package:abc_e_mart/data/models/category_type.dart';

class AdminProductData {
  final String imagePath;
  final String productName;
  final CategoryType categoryType;
  final String storeName;
  final String date;

  const AdminProductData({
    required this.imagePath,
    required this.productName,
    required this.categoryType,
    required this.storeName,
    required this.date,
  });
}
