import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreRatingPage extends StatelessWidget {
  const StoreRatingPage({super.key});

  // Dummy data rating & ulasan
  final ratings = const [
    {"star": 5, "total": 1765},
    {"star": 4, "total": 550},
    {"star": 3, "total": 203},
    {"star": 2, "total": 32},
    {"star": 1, "total": 11},
  ];

  final ulasan = const [
    {
      "user": "userhebat",
      "date": "1 tahun yang lalu",
      "star": 5,
      "review": "Pelayanan tokonya ramah banget, barang cepat sampai dan kualitasnya oke! Recommended buat mahasiswa."
    },
    {
      "user": "tokopelanggan",
      "date": "1 tahun yang lalu",
      "star": 4,
      "review": "Barang sesuai deskripsi, tapi kemasan agak penyok. Overall tetap puas, terima kasih."
    },
    {
      "user": "adminteknik",
      "date": "11 bulan yang lalu",
      "star": 5,
      "review": "Langganan di sini terus karena admin fast response dan produknya lengkap. Akan order lagi!"
    },
    {
      "user": "makanmulu",
      "date": "8 bulan yang lalu",
      "star": 5,
      "review": "Ayam geprek dan jusnya mantap. Harganya juga pas di kantong mahasiswa. Sukses terus, Nihon Mart! Ayamnya selalu hangat, porsi besar, pelayanan ramah. Rekan saya juga suka banget, sudah beberapa kali order di sini. Thanks yaa!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 18),
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Rating Toko",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _RatingSummaryBox(ratings: ratings),
                    const SizedBox(height: 20),
                    _ReviewListBox(ulasan: ulasan),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummaryBox extends StatelessWidget {
  final List<Map<String, dynamic>> ratings;

  const _RatingSummaryBox({required this.ratings});

  @override
  Widget build(BuildContext context) {
    const double avgRating = 4.8;
    const String totalReview = "256,252";
    const Color barColor = Color(0xFFFFC700);

    int maxTotal = ratings.map((e) => e['total'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
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
            "Rating",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rating toko Anda bisa dilihat di sini. Pastikan untuk selalu memberikan pengalaman terbaik bagi pelanggan.",
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
                        totalReview,
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
  }
}

class _ReviewListBox extends StatelessWidget {
  final List<Map<String, dynamic>> ulasan;

  const _ReviewListBox({required this.ulasan});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Lihat ulasan pelanggan Anda di sini. Terus berikan pelayanan terbaik agar mereka selalu puas!",
            style: GoogleFonts.dmSans(fontSize: 13.3, color: const Color(0xFF5D5D5D)),
          ),
          const SizedBox(height: 15),
          ...ulasan.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _ReviewItem(e: e),
          )),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Map<String, dynamic> e;
  const _ReviewItem({required this.e});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          color: const Color(0xFF404040), fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    TextSpan(
                      text: "memberikan ",
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF404040), fontSize: 13.3),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          if (i < (e["star"] as int)) {
                            return const Icon(Icons.star, size: 14, color: Color(0xFFFFC700));
                          } else {
                            return const Icon(Icons.star, size: 14, color: Color(0xFFE2E2E2));
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Text(e["date"] as String,
                  style: GoogleFonts.dmSans(fontSize: 11.7, color: const Color(0xFF979797))),
              const SizedBox(height: 2),
              _ReviewTextWithReadMore(text: e["review"] as String),
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
          style: GoogleFonts.dmSans(fontSize: 13.3, color: const Color(0xFF404040)),
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
