import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tambahkan const ini!
const colorInput = Color(0xFF404040);

class StoreRatingReview extends StatelessWidget {
  const StoreRatingReview({super.key});

  static const int descLimit = 160;

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final ratings = [
      {"star": 5, "total": 1765},
      {"star": 4, "total": 550},
      {"star": 3, "total": 203},
      {"star": 2, "total": 32},
      {"star": 1, "total": 11},
    ];
    final ulasan = List.generate(4, (i) => {
      "user": "username${i + 1}",
      "date": "1 tahun yang lalu",
      "star": 4 + (i % 2),
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam vitae ex consectetur, mollis dui et, vestibulum metus. Morbi ut vestibulum odio. Donec non ex quis orci laoreet volutpat. Cras quis neque feugiat, interdum diam id. (more)"
    });

    Color getBarColor(int star) {
      return const Color(0xFFFFC700);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Rating
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rating",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
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
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFC700), size: 37),
                            const SizedBox(width: 5),
                            Text("4,8", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 32)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 13, color: Color(0xFF9D9D9D)),
                            const SizedBox(width: 3),
                            Text("256,252", style: GoogleFonts.dmSans(fontSize: 12, color: Color(0xFF9D9D9D))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    // --- Rating Bar Responsive ---
                    Expanded(
                      child: _RatingBarColumn(ratings: ratings, getBarColor: getBarColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Section: Ulasan
          Container(
            width: double.infinity,
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
                ...ulasan.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar bulat dummy
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3E3E3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFFBBBBBB), size: 23),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${e["user"]} ",
                                        style: GoogleFonts.dmSans(
                                            color: colorInput, fontWeight: FontWeight.bold, fontSize: 13.5),
                                      ),
                                      TextSpan(
                                        text: "memberikan ",
                                        style: GoogleFonts.dmSans(
                                            color: colorInput, fontSize: 13.3),
                                      ),
                                      WidgetSpan(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                              5,
                                              (i) => Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: i < (e["star"] as int)
                                                        ? const Color(0xFFFFC700)
                                                        : const Color(0xFFE2E2E2),
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(e["date"] as String,
                                    style: GoogleFonts.dmSans(fontSize: 11.7, color: Color(0xFF979797))),
                                const SizedBox(height: 2),
                                _ReviewTextWithReadMore(text: e["review"] as String),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RatingBarColumn extends StatelessWidget {
  final List<Map<String, dynamic>> ratings;
  final Color Function(int) getBarColor;
  const _RatingBarColumn({required this.ratings, required this.getBarColor});

  @override
  Widget build(BuildContext context) {
    final int maxTotal = ratings.map((e) => e['total'] as int).reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double leftNumWidth = 15;
        const double rightNumWidth = 38;
        const double spacing1 = 8;
        const double spacing2 = 10;
        final double barWidth = constraints.maxWidth - leftNumWidth - rightNumWidth - spacing1 - spacing2;

        return Column(
          children: List.generate(ratings.length, (i) {
            final item = ratings[i];
            final star = item['star'] as int;
            final total = item['total'] as int;
            final double percent = total / maxTotal;

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
                          color: getBarColor(star),
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
    );
  }
}

// Widget untuk Review + Read More
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
