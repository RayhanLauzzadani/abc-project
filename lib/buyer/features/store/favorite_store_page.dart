import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/features/store/store_card.dart';

class FavoriteStorePage extends StatelessWidget {
  const FavoriteStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Silakan login untuk melihat favorit'));
    }

    final favStoresRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteStores');

    return StreamBuilder<QuerySnapshot>(
      stream: favStoresRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada toko favorit.'));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final favData = docs[index].data() as Map<String, dynamic>;
            // Simpan detail store lengkap ke dalam favorit saat add favorite, atau ambil dari koleksi store by id
            return StoreCard(
              imagePath: favData['image'] ?? '',
              storeName: favData['name'] ?? '',
              distance: favData['distance'] ?? '',
              duration: favData['duration'] ?? '',
              rating: (favData['rating'] as num?)?.toDouble() ?? 0,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
