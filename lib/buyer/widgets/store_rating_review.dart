import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

const colorInput = Color(0xFF404040);

String formatShortName(String userName) {
  if (userName.trim().isEmpty) return "Pengguna";
  final parts = userName.trim().split(RegExp(r"\s+"));
  if (parts.length == 1) return parts.first;
  final firstName = parts.first;
  final lastInitial = parts.last.isNotEmpty ? parts.last[0].toUpperCase() + '.' : '';
  return "$firstName $lastInitial";
}

class StoreRatingReview extends StatelessWidget {
  final String storeId;
  final String storeName;

  const StoreRatingReview({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
        builder: (context, storeSnapshot) {
          if (!storeSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final storeData = storeSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final double avgRating = (storeData['rating'] ?? 0).toDouble();
          final int ratingCount = storeData['ratingCount'] ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RatingSummaryBox(
                avgRating: avgRating,
                totalReview: ratingCount,
                storeId: storeId,
              ),
              const SizedBox(height: 20),
              _ReviewListBox(storeId: storeId),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ================== RATING SUMMARY BOX ===================
class _RatingSummaryBox extends StatelessWidget {
  final double avgRating;
  final int totalReview;
  final String storeId;

  const _RatingSummaryBox({
    required this.avgRating,
    required this.totalReview,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    const Color barColor = Color(0xFFFFC700);

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .get(),
      builder: (context, snapshot) {
        final ratings = [0, 0, 0, 0, 0]; // Index 0: 1-star, 4: 5-star
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final int star = data['rating'] ?? 0;
            if (star >= 1 && star <= 5) ratings[star - 1]++;
          }
        }
        final int maxTotal = ratings.isNotEmpty ? ratings.reduce((a, b) => a > b ? a : b) : 1;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Rating", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                "Rating toko tersedia di sini. Cek dulu sebelum belanja, supaya Anda makin yakin dengan pilihan Anda.",
                style: GoogleFonts.dmSans(fontSize: 13.3, color: const Color(0xFF5D5D5D)),
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded, color: barColor, size: 37),
                          const SizedBox(width: 5),
                          Text(
                            avgRating.toStringAsFixed(1).replaceAll('.', ','),
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 13, color: Color(0xFF9D9D9D)),
                          const SizedBox(width: 3),
                          Text(
                            totalReview.toString(),
                            style: GoogleFonts.dmSans(fontSize: 12, color: Color(0xFF9D9D9D)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double totalWidth = constraints.maxWidth;
                        const double leftNumWidth = 15;
                        const double rightNumWidth = 38;
                        const double spacing1 = 8;
                        const double spacing2 = 10;
                        final double barWidth = totalWidth - leftNumWidth - rightNumWidth - spacing1 - spacing2;

                        return Column(
                          children: List.generate(5, (i) {
                            final star = 5 - i;
                            final total = ratings[star - 1];
                            final double percent = maxTotal > 0 ? total / maxTotal : 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: leftNumWidth,
                                    child: Text(
                                      '$star',
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: spacing1),
                                  Stack(
                                    children: [
                                      Container(
                                        width: barWidth,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F3F3),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      Container(
                                        width: (barWidth * percent).clamp(4, barWidth),
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: spacing2),
                                  SizedBox(
                                    width: rightNumWidth,
                                    child: Text(
                                      total.toString(),
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF9D9D9D)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================== REVIEW LIST BOX ===================
class _ReviewListBox extends StatelessWidget {
  final String storeId;
  const _ReviewListBox({required this.storeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.messagesSquare, size: 55, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  "Belum ada ulasan untuk toko ini",
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                Text(
                  "Jadilah yang pertama memberikan rating & ulasan untuk membantu pembeli lain!",
                  style: GoogleFonts.dmSans(fontSize: 13.5, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ulasan Pelanggan",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Lihat bagaimana pembeli lain menilai toko ini sebelum Anda memutuskan untuk membeli produk mereka",
                style: GoogleFonts.dmSans(fontSize: 13.3, color: const Color(0xFF5D5D5D)),
              ),
              const SizedBox(height: 15),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: reviews.length,
                separatorBuilder: (context, idx) => Divider(
                  color: Colors.black12,
                  thickness: 1,
                  height: 30,
                ),
                itemBuilder: (context, idx) {
                  final data = reviews[idx].data() as Map<String, dynamic>;
                  final Timestamp? createdAt = data['createdAt'] as Timestamp?;
                  DateTime? date = createdAt?.toDate();
                  return _ReviewItem(
                    userName: data['userName'] ?? 'Pengguna',
                    userPhotoUrl: data['userPhotoUrl'] ?? '',
                    date: date,
                    star: data['rating'] ?? 0,
                    review: data['review'] ?? '',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String userName;
  final String userPhotoUrl;
  final DateTime? date;
  final int star;
  final String review;

  const _ReviewItem({
    required this.userName,
    required this.userPhotoUrl,
    required this.date,
    required this.star,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = date != null
        ? "${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}"
        : "-";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto profil
        userPhotoUrl.isNotEmpty
            ? CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(userPhotoUrl),
                backgroundColor: const Color(0xFFE3E3E3),
              )
            : const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE3E3E3),
                child: Icon(Icons.person, color: Color(0xFFBBBBBB), size: 23),
              ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama user di atas, bintang dan text di bawah (tidak akan overflow)
              Text(
                formatShortName(userName),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "memberikan",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.2,
                      color: const Color(0xFF595959),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(5, (i) => Icon(
                    Icons.star,
                    size: 13,
                    color: i < star ? const Color(0xFFFFC700) : const Color(0xFFE2E2E2),
                  )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Text(
                  formattedDate,
                  style: GoogleFonts.dmSans(fontSize: 11.7, color: Color(0xFF979797)),
                ),
              ),
              _ReviewTextWithReadMore(text: review),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewTextWithReadMore extends StatefulWidget {
  final String text;
  const _ReviewTextWithReadMore({required this.text});

  @override
  State<_ReviewTextWithReadMore> createState() => _ReviewTextWithReadMoreState();
}

class _ReviewTextWithReadMoreState extends State<_ReviewTextWithReadMore> {
  static const int descLimit = 160;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > descLimit;
    final descShort = isLong ? widget.text.substring(0, descLimit) + '...' : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expanded ? widget.text : descShort,
          style: GoogleFonts.dmSans(fontSize: 13.3, color: colorInput),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                expanded ? "Tutup" : "Read More",
                style: GoogleFonts.dmSans(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.4,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
