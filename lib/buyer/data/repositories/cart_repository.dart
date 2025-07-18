import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil keranjang berdasarkan userId.
  Future<List<StoreCart>> getCart(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('carts')
        .doc('main')
        .get();

    if (!doc.exists || doc.data() == null) return [];
    final data = doc.data()!;
    final storeCarts = data['storeCarts'] as List<dynamic>? ?? [];

    storeCarts.sort((a, b) {
      Timestamp aTime = a['addedAt'] ?? Timestamp.now();
      Timestamp bTime = b['addedAt'] ?? Timestamp.now();
      return aTime.compareTo(bTime);
    });

    return storeCarts
        .map((storeData) => StoreCart.fromMap(Map<String, dynamic>.from(storeData)))
        .toList();
  }

  /// Tambahkan/memperbarui produk dalam keranjang.
  Future<void> addOrUpdateCartItem({
    required String userId,
    required CartItem item,
    required String storeId,
    required String storeName,
    required String ownerId,
  }) async {
    final userDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('carts')
        .doc('main');

    final docSnap = await userDoc.get();
    Map<String, dynamic> cartData = docSnap.data() ?? {};
    List<dynamic> storeCarts = List.from(cartData['storeCarts'] ?? []);

    int storeIdx = storeCarts.indexWhere((s) => s['storeId'] == storeId);

    final itemMap = item.toMap()..remove('addedAt');

    if (storeIdx == -1) {
      // Jika belum ada cart untuk toko ini, buat baru
      storeCarts.add({
        'storeId': storeId,
        'storeName': storeName,
        'ownerId': ownerId,
        'addedAt': Timestamp.now(),
        'items': [itemMap],
      });
    } else {
      // Jika sudah ada, update/replace item jika ada, atau tambah kalau belum ada
      List<dynamic> items = List.from(storeCarts[storeIdx]['items'] ?? []);
      int itemIdx = items.indexWhere((it) => it['id'] == item.id);

      if (itemIdx == -1) {
        items.add(itemMap);
      } else {
        items[itemIdx] = itemMap;
      }
      storeCarts[storeIdx]['items'] = items;
      // Pastikan data toko & ownerId juga selalu terupdate jika berubah
      storeCarts[storeIdx]['storeName'] = storeName;
      storeCarts[storeIdx]['ownerId'] = ownerId;
    }

    await userDoc.set({'storeCarts': storeCarts}, SetOptions(merge: true));
  }

  /// Hapus produk dari keranjang (jika tidak ada item, hapus keranjang toko juga)
  Future<void> removeCartItem({
    required String userId,
    required String storeId,
    required String productId,
  }) async {
    final userDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('carts')
        .doc('main');
    final docSnap = await userDoc.get();

    Map<String, dynamic> cartData = docSnap.data() ?? {};
    List<dynamic> storeCarts = List.from(cartData['storeCarts'] ?? []);

    int storeIdx = storeCarts.indexWhere((s) => s['storeId'] == storeId);
    if (storeIdx == -1) return;

    List<dynamic> items = List.from(storeCarts[storeIdx]['items'] ?? []);
    items.removeWhere((it) => it['id'] == productId);

    if (items.isEmpty) {
      storeCarts.removeAt(storeIdx);
    } else {
      storeCarts[storeIdx]['items'] = items;
    }

    await userDoc.set({'storeCarts': storeCarts}, SetOptions(merge: true));
  }

  /// Update quantity item produk di cart
  Future<void> updateCartItemQuantity({
    required String userId,
    required String storeId,
    required String productId,
    required int quantity,
  }) async {
    final userDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('carts')
        .doc('main');
    final docSnap = await userDoc.get();

    Map<String, dynamic> cartData = docSnap.data() ?? {};
    List<dynamic> storeCarts = List.from(cartData['storeCarts'] ?? []);
    int storeIdx = storeCarts.indexWhere((s) => s['storeId'] == storeId);
    if (storeIdx == -1) return;

    List<dynamic> items = List.from(storeCarts[storeIdx]['items'] ?? []);
    int itemIdx = items.indexWhere((it) => it['id'] == productId);
    if (itemIdx == -1) return;

    items[itemIdx]['quantity'] = quantity;
    storeCarts[storeIdx]['items'] = items;

    await userDoc.set({'storeCarts': storeCarts}, SetOptions(merge: true));
  }
}

class StoreCart {
  final String storeId;
  final String storeName;
  final String ownerId;
  final List<CartItem> items;
  final DateTime addedAt;

  StoreCart({
    required this.storeId,
    required this.storeName,
    required this.ownerId,
    required this.items,
    required this.addedAt,
  });

  factory StoreCart.fromMap(Map<String, dynamic> data) {
    return StoreCart(
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      addedAt: (data['addedAt'] is Timestamp)
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'storeId': storeId,
        'storeName': storeName,
        'ownerId': ownerId,
        'addedAt': Timestamp.fromDate(addedAt),
        'items': items.map((e) => e.toMap()).toList(),
      };
}
