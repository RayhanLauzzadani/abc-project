import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Syarat Penggunaan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Ketentuan Pengguna (Buyer Agreement)'),
            const SizedBox(height: 16),
            _SectionTitle('1. Definisi'),
            _PolicyText([
              [
                'User adalah setiap individu yang telah mendaftar dan memiliki akun di aplikasi ABC e-mart.',
                'Dalam konteks ini, user juga berperan sebagai buyer atau konsumen yang dapat melakukan pembelian produk/jasa di marketplace.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('2. Persetujuan Pengguna'),
            _PolicyText([
              [
                'Dengan mendaftar dan menggunakan aplikasi ABC e-mart, user dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan berikut:',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('3. Hak User (Buyer)'),
            _PolicyText([
              [
                'Mengakses seluruh katalog produk dan jasa yang tersedia di ABC e-mart.',
                'Melakukan transaksi pembelian melalui aplikasi.',
                'Memberikan ulasan atau penilaian terhadap produk/jasa yang dibeli.',
                'Mengajukan komplain atau permintaan pengembalian dana sesuai prosedur yang berlaku.',
                'Mendapatkan perlindungan data pribadi sebagaimana diatur dalam kebijakan privasi ABC e-mart.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('4. Kewajiban User (Buyer)'),
            _PolicyText([
              [
                'Mengisi data diri yang benar, lengkap, dan terbaru saat mendaftar maupun bertransaksi.',
                'Melakukan pembayaran sesuai dengan metode dan ketentuan yang berlaku.',
                'Memastikan data pengiriman, kontak, dan informasi lain yang diperlukan untuk transaksi sudah benar.',
                'Tidak melakukan tindakan penipuan, penyalahgunaan fitur, atau tindakan lain yang dapat merugikan pihak lain di dalam ABC e-mart.',
                'Menggunakan aplikasi sesuai dengan aturan dan tidak melanggar hukum yang berlaku.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('5. Pembatasan Tanggung Jawab'),
            _PolicyText([
              [
                'ABC e-mart tidak bertanggung jawab atas kerugian, kerusakan, atau kehilangan barang yang disebabkan oleh kelalaian user dalam melakukan transaksi, pengisian data, atau komunikasi dengan seller.',
                'Seluruh transaksi dan komunikasi antara user dan seller sepenuhnya menjadi tanggung jawab masing-masing pihak, kecuali jika terdapat kelalaian atau kesalahan sistem dari ABC e-mart.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('6. Penyalahgunaan Akun'),
            _PolicyText([
              [
                'User dilarang keras memindahtangankan, menjual, atau memberikan akses akun kepada pihak lain.',
                'Setiap aktivitas yang terjadi pada akun dianggap dilakukan oleh pemilik akun yang terdaftar.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('7. Larangan Konten dan Aktivitas'),
            _PolicyText([
              [
                'User dilarang mengunggah, mengirim, atau menyebarkan konten yang bersifat SARA, pornografi, penipuan, atau yang melanggar hukum dan peraturan perundang-undangan yang berlaku di Indonesia.',
                'Setiap pelanggaran atas larangan ini dapat menyebabkan penonaktifan akun secara permanen tanpa pemberitahuan sebelumnya.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('8. Perubahan Layanan'),
            _PolicyText([
              [
                'ABC e-mart berhak untuk melakukan perubahan, penambahan, atau penghapusan fitur pada aplikasi marketplace kapan saja demi meningkatkan kualitas layanan.',
                'User akan diinformasikan mengenai perubahan fitur atau layanan melalui aplikasi, email, atau media komunikasi resmi lainnya.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('9. Force Majeure'),
            _PolicyText([
              [
                'ABC e-mart tidak bertanggung jawab atas keterlambatan atau kegagalan dalam melaksanakan kewajibannya akibat kejadian di luar kendali, seperti bencana alam, gangguan sistem, atau kebijakan pemerintah (force majeure).',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('10. Penanganan Komplain dan Pengembalian Dana'),
            _PolicyText([
              [
                'Setiap permintaan komplain atau pengembalian dana hanya dapat dilakukan melalui fitur dan prosedur resmi di ABC e-mart.',
                'Pengajuan komplain wajib disertai bukti yang jelas dan dilakukan dalam jangka waktu yang ditentukan.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('11. Penonaktifan Akun'),
            _PolicyText([
              [
                'ABC e-mart berhak menonaktifkan atau menghapus akun user apabila ditemukan pelanggaran terhadap ketentuan pengguna, tindakan penipuan, atau aktivitas lain yang merugikan pihak lain.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('12. Perubahan Ketentuan'),
            _PolicyText([
              [
                'ABC e-mart dapat sewaktu-waktu melakukan perubahan atau pembaruan pada ketentuan ini. User diharapkan untuk selalu membaca dan memahami syarat terbaru yang berlaku.',
              ],
            ]),
            const SizedBox(height: 22),
            _SectionTitle('Ketentuan Pengguna (Seller Agreement) ABC e-mart'),
            const SizedBox(height: 12),
            _SectionTitle('1. Definisi'),
            _PolicyText([
              [
                'Seller adalah user terdaftar di ABC e-mart yang telah mengajukan permohonan dan mendapatkan persetujuan sebagai penjual, sehingga dapat menawarkan produk atau jasa di marketplace ABC e-mart.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('2. Persetujuan Seller'),
            _PolicyText([
              'Dengan mengajukan diri dan di-approve sebagai seller, user dianggap telah membaca, memahami, dan menyetujui seluruh syarat & ketentuan berikut:',
            ]),
            const SizedBox(height: 14),
            _SectionTitle('3. Proses Pengajuan Seller'),
            _PolicyText([
              [
                'Setiap user wajib melengkapi data diri, dokumen, serta informasi yang diperlukan sesuai dengan form pendaftaran seller yang disediakan ABC e-mart.',
                'Pengajuan sebagai seller akan melalui proses verifikasi dan approval oleh admin.',
                'ABC e-mart berhak menolak pengajuan seller apabila data tidak lengkap, tidak valid, atau tidak memenuhi standar yang ditentukan.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('4. Hak Seller'),
            _PolicyText([
              [
                'Menawarkan dan memasarkan produk/jasa di platform ABC e-mart setelah proses approval selesai.',
                'Mengakses fitur-fitur seller seperti pengelolaan produk, pengelolaan pesanan, laporan penjualan, dan lainnya sesuai ketentuan yang berlaku.',
                'Mendapatkan notifikasi terkait transaksi, promosi, atau pengumuman penting dari ABC e-mart.',
                'Berhak mendapatkan perlindungan data pribadi sesuai kebijakan privasi yang berlaku.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('5. Kewajiban Seller'),
            _PolicyText([
              [
                'Menyediakan data dan informasi produk/jasa secara akurat, jujur, dan tidak menyesatkan.',
                'Memastikan produk/jasa yang dijual legal dan tidak melanggar peraturan atau hak kekayaan intelektual pihak lain.',
                'Mengelola stok, harga, dan ketersediaan produk secara bertanggung jawab dan real-time.',
                'Menangani pesanan, pengiriman, serta keluhan dari buyer sesuai dengan standar layanan dan waktu yang ditentukan.',
                'Membayar biaya layanan, komisi, atau biaya lain (jika ada) yang telah ditetapkan oleh ABC e-mart.',
                'Tidak melakukan spam, penipuan, atau aktivitas terlarang lainnya di platform.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('6. Aturan Promosi dan Papan Iklan'),
            _PolicyText([
              [
                'Seller dapat mengajukan produk untuk tampil di papan iklan (banner/ads) yang tersedia di platform, sesuai prosedur dan biaya yang berlaku.',
                'Setelah pembayaran dan verifikasi, produk akan otomatis tampil di papan iklan tanpa campur tangan admin.',
                'Materi iklan wajib mematuhi ketentuan konten dan tidak melanggar hukum/peraturan yang berlaku.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('7. Penonaktifan dan Sanksi Seller'),
            _PolicyText([
              [
                'ABC e-mart berhak memberikan sanksi, menonaktifkan sementara, atau menghapus akun seller jika ditemukan pelanggaran terhadap syarat & ketentuan, penipuan, penyalahgunaan platform, atau aktivitas ilegal lainnya.',
                'Seller yang tidak aktif dalam jangka waktu tertentu dapat dikenakan status nonaktif sesuai kebijakan internal ABC e-mart.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('8. Perubahan Layanan dan Ketentuan'),
            _PolicyText([
              [
                'ABC e-mart berhak melakukan perubahan, penambahan, atau penghapusan fitur, biaya, dan syarat ketentuan kapan saja dengan pemberitahuan melalui media resmi.',
                'Seller diharapkan untuk selalu membaca dan memahami ketentuan terbaru yang berlaku.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('9. Pembatasan Tanggung Jawab'),
            _PolicyText([
              [
                'Seller bertanggung jawab penuh atas produk/jasa yang ditawarkan, pengiriman, dan kepuasan pelanggan.',
                'ABC e-mart tidak bertanggung jawab atas kerugian atau klaim yang timbul akibat pelanggaran yang dilakukan seller.',
              ],
            ]),
            const SizedBox(height: 14),
            _SectionTitle('10. Force Majeure'),
            _PolicyText([
              [
                'ABC e-mart dibebaskan dari kewajiban dan tanggung jawab atas keterlambatan atau gangguan layanan yang disebabkan oleh keadaan di luar kendali, seperti bencana alam, gangguan teknis, atau kebijakan pemerintah.',
              ],
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

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
