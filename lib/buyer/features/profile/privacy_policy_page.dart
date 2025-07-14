import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Kebijakan Privasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Pengumpulan Data Pribadi'),
            _PolicyText([
              'ABC e-mart mengumpulkan data pribadi pengguna pada saat:',
              [
                'Pendaftaran akun (sign up), yang dapat mencakup: nama lengkap, alamat email, nomor telepon, tanggal lahir, alamat, dan informasi pendukung lainnya.',
                'Penggunaan aplikasi, seperti pengisian alamat pengiriman, metode pembayaran, riwayat transaksi, serta interaksi pengguna di dalam aplikasi.',
                'Proses pengajuan menjadi seller, berupa data dokumen verifikasi seperti KTP (Kartu Tanda Penduduk).',
                'Informasi tambahan yang mungkin dibutuhkan untuk peningkatan layanan atau keamanan aplikasi.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('2. Penggunaan Data Pribadi'),
            _PolicyText([
              'Data pribadi pengguna digunakan untuk:',
              [
                'Keperluan pendaftaran, verifikasi, dan pengelolaan akun.',
                'Proses transaksi, pembayaran, pengiriman, dan komunikasi terkait layanan ABC e-mart.',
                'Peningkatan kualitas layanan, pengembangan fitur baru, dan analisis penggunaan aplikasi.',
                'Pengelolaan promosi, notifikasi, dan penawaran yang relevan bagi pengguna.',
                'Keperluan keamanan, audit internal, dan pencegahan penyalahgunaan aplikasi.',
                'Dalam rangka pengembangan aplikasi dan layanan, ABC e-mart dapat memproses serta menganalisis data pengguna, baik secara langsung maupun melalui mitra terpercaya dengan tetap menjaga kerahasiaan dan perlindungan data sesuai ketentuan yang berlaku.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('3. Penyimpanan dan Perlindungan Data'),
            _PolicyText([
              [
                'Data pribadi pengguna disimpan secara aman menggunakan sistem dan teknologi perlindungan data yang memadai.',
                'Data disimpan selama akun masih aktif atau selama dibutuhkan untuk memenuhi tujuan pengumpulan data, kecuali diatur lain oleh ketentuan hukum.',
                'Akses ke data pribadi dibatasi hanya untuk pihak yang berkepentingan dan berwenang.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('4. Pembagian Data ke Pihak Ketiga'),
            _PolicyText([
              [
                'Data pribadi pengguna tidak akan dijual atau dipublikasikan kepada pihak yang tidak berkepentingan.',
                'Dalam rangka peningkatan layanan, pengembangan aplikasi, atau kerja sama tertentu, data pengguna dapat diolah atau dibagikan kepada mitra pihak ketiga yang telah menjalani proses seleksi dan memiliki komitmen menjaga kerahasiaan data, sesuai dengan kebijakan privasi dan hukum yang berlaku.',
                'Setiap pembagian data dilakukan dengan prinsip perlindungan privasi dan seminimal mungkin untuk tujuan yang relevan.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('5. Hak Pengguna atas Data Pribadi'),
            _PolicyText([
              [
                'Pengguna dapat mengakses, memperbarui, atau menghapus data pribadi melalui aplikasi.',
                'Pengguna dapat mengajukan permintaan penghapusan akun dengan menghubungi layanan pelanggan ABC e-mart, kecuali data tertentu wajib disimpan berdasarkan ketentuan hukum.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('6. Penggunaan Cookies dan Teknologi Pelacakan'),
            _PolicyText([
              [
                'ABC e-mart menggunakan cookies atau teknologi serupa untuk meningkatkan kenyamanan, analisis performa, dan personalisasi layanan.',
                'Pengguna dapat mengatur preferensi cookies melalui pengaturan di aplikasi atau browser.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('7. Perubahan Kebijakan Privasi'),
            _PolicyText([
              [
                'ABC e-mart dapat memperbarui kebijakan privasi sewaktu-waktu. Pengguna disarankan untuk rutin membaca pembaruan kebijakan ini.',
              ],
            ]),
            const SizedBox(height: 18),
            _SectionTitle('8. Kontak dan Pengaduan'),
            _PolicyText([
              [
                'Untuk pertanyaan, keluhan, atau permintaan terkait data pribadi, silakan hubungi customer service melalui email resmi: brawijayaabcftp@gmail.com atau fitur bantuan aplikasi.',
              ],
            ]),
          ],
        ),
      ),
    );
  }
}

/// Widget judul section (angka & judul, bold, 16, #373E3C)
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF373E3C),
      ),
    );
  }
}

/// Widget isi, support paragraf dan bullet list
class _PolicyText extends StatelessWidget {
  final List<dynamic> content;
  const _PolicyText(this.content);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var item in content) {
      if (item is String) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 4),
            child: Text(
              item,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF373E3C),
                height: 1.5,
              ),
            ),
          ),
        );
      } else if (item is List) {
        for (var bullet in item) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 3, right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF373E3C),
                        height: 1.55,
                      )),
                  Expanded(
                    child: Text(
                      bullet,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
