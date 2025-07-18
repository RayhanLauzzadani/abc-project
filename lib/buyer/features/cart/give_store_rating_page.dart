import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../buyer/data/models/rating_model.dart';
import 'package:abc_e_mart/buyer/data/repositories/rating_repository.dart';
import 'package:abc_e_mart/buyer/widgets/success_rating_popup.dart';

class GiveStoreRatingPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String? storeImageUrl;

  const GiveStoreRatingPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    this.storeImageUrl,
  });

  @override
  State<GiveStoreRatingPage> createState() => _GiveStoreRatingPageState();
}

class _GiveStoreRatingPageState extends State<GiveStoreRatingPage> {
  int _rating = 0;
  String _review = '';
  bool _loading = false;

  final TextEditingController _reviewController = TextEditingController();

  Future<void> _submitRating() async {
    if (_rating == 0 || _loading) return;
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'dummyUser';

    // Fetch name & photoUrl user
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final userName = userData['name'] ?? 'Pengguna';
    final userPhotoUrl = userData['photoUrl'] ?? '';

    final rating = RatingModel(
      id: '',
      storeId: widget.storeId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      rating: _rating,
      review: _review,
      createdAt: DateTime.now(),
    );
    await RatingService.addRating(rating);

    setState(() => _loading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessRatingPopup(
        message: "Penilaian Anda Berhasil Disimpan",
        lottiePath: "assets/lottie/success_check.json",
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).maybePop(); // Back to previous page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2056D3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "Beri Penilaian Toko",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: const Color(0xFF232323),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  children: [
                    // --- BOX UTAMA ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.89),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Identitas toko
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: widget.storeImageUrl != null
                                  ? Image.network(
                                      widget.storeImageUrl!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.store, color: Colors.white, size: 38),
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.store, color: Colors.white, size: 38),
                                    ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.storeName,
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.5,
                                        color: const Color(0xFF232323),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      widget.storeAddress,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: const Color(0xFF888888),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Divider(color: const Color(0xFFE6E6E6), thickness: 1),
                          const SizedBox(height: 15),

                          // Rating Toko (judul kiri, bintang center)
                          Text(
                            "Rating Toko",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: const Color(0xFF232323),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) => GestureDetector(
                                onTap: () => setState(() => _rating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    _rating > i
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                    color: _rating > i ? const Color(0xFFFFC700) : const Color(0xFFE0E0E0),
                                    size: 42,
                                  ),
                                ),
                              )),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Ulasan
                          Text(
                            "Ulasan",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: const Color(0xFF232323),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFDADADA)),
                              borderRadius: BorderRadius.circular(13),
                              color: Colors.white,
                            ),
                            child: TextField(
                              controller: _reviewController,
                              minLines: 3,
                              maxLines: 4,
                              onChanged: (v) => _review = v,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                border: InputBorder.none,
                                hintText: "Ketik ulasan anda untuk toko di sini....",
                                hintStyle: GoogleFonts.dmSans(
                                  color: const Color(0xFFADADAD), fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- BUTTON SIMPAN ---
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _rating > 0 && !_loading ? _submitRating : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2056D3),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFCDE6),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 28, width: 28,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Simpan"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
