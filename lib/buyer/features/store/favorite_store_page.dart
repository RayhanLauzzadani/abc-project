import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/features/store/store_card.dart';
import 'package:abc_e_mart/buyer/features/store/store_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FavoriteStorePage extends StatelessWidget {
  const FavoriteStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 108,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              "Anda belum login",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "Silakan login untuk melihat toko favorit Anda.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.store,
                  size: 104,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 25),
                Text(
                  "Belum ada toko favorit",
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Toko yang Anda favoritkan akan muncul di sini.",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final favData = docs[index].data() as Map<String, dynamic>;
            return StoreCard(
              imageUrl: favData['logoUrl'] ?? '',
              storeName: favData['name'] ?? '',
              rating: (favData['rating'] as num?)?.toDouble() ?? 0,
              ratingCount: (favData['ratingCount'] as num?)?.toInt() ?? 0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoreDetailPage(store: favData),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
