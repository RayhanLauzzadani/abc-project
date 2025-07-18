import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<List<ProductModel>> getProductsByStore(String shopId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList();
  }
}
