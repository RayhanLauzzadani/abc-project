import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/features/product/product_card.dart';

class FavoriteProductPage extends StatelessWidget {
  const FavoriteProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Kalau user belum login, bisa tampilkan empty state
      return const Center(child: Text('Silakan login untuk melihat favorit'));
    }

    final favProductsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteProducts');

    return StreamBuilder<QuerySnapshot>(
      stream: favProductsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada produk favorit.'));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final favData = docs[index].data() as Map<String, dynamic>;
            // Simpan detail produk lengkap ke dalam favorit saat add favorite, atau ambil dari koleksi produk by id
            // Asumsi data favorit menyimpan field: image, name, price, rating (atau id produk untuk fetch detail)
            return ProductCard(
              imagePath: favData['image'] ?? '', // Sesuaikan dengan field di Firestore
              name: favData['name'] ?? '',
              price: favData['price'] ?? 0,
              rating: (favData['rating'] as num?)?.toDouble() ?? 0,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
