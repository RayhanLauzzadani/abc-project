import 'package:abc_e_mart/buyer/widgets/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/admin/widgets/admin_home_header.dart';
import 'package:abc_e_mart/admin/widgets/admin_summary_card.dart';
import 'package:abc_e_mart/admin/widgets/admin_abc_payment_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_store_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_product_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_bottom_navbar.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_page.dart';
import 'package:abc_e_mart/admin/features/approval/product/admin_product_approval_page.dart';
import 'package:abc_e_mart/admin/widgets/admin_ad_submission_section.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_page.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_detail_page.dart';
import 'package:abc_e_mart/buyer/features/auth/login_page.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart';
import 'package:abc_e_mart/admin/features/notification/notification_page_admin.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';
import 'package:intl/intl.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminClaim();
  }

  Future<void> _checkAdminClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _forceLogoutWithMsg('Anda belum login.');
      return;
    }
    try {
      final token = await user.getIdTokenResult(true);
      final claims = token.claims;
      if (claims == null || claims['admin'] != true) {
        _forceLogoutWithMsg('Akses admin diperlukan. Silakan login dengan akun admin.');
      }
    } catch (e) {
      _forceLogoutWithMsg('Terjadi error: $e');
    }
  }

  void _forceLogoutWithMsg(String message) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Akses Ditolak'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Hanya trigger, dialog akan dipanggil dari AdminHomeHeader via callback
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const LogoutConfirmationDialog(),
    );
    if (result == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    Widget mainBody;

    if (_currentIndex == 1) {
      mainBody = const AdminStoreApprovalPage();
    } else if (_currentIndex == 2) {
      mainBody = const AdminProductApprovalPage();
    } else if (_currentIndex == 3) {
      mainBody = const AdminAdApprovalPage();
    } else {
      mainBody = Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AdminHomeHeader(
              onNotif: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPageAdmin(),
                  ),
                );
              },
              onLogoutTap: _logout,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Admin Summary Card ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('shopApplications')
                          .snapshots(),
                      builder: (context, shopSnapshot) {
                        int tokoBaru = 0;
                        int tokoTerdaftar = 0;
                        if (shopSnapshot.hasData) {
                          final docs = shopSnapshot.data!.docs;
                          tokoBaru = docs.where((doc) =>
                              (doc['status'] ?? '').toString().toLowerCase() == 'pending'
                          ).length;
                          tokoTerdaftar = docs.where((doc) =>
                              (doc['status'] ?? '').toString().toLowerCase() == 'approved'
                          ).length;
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('productsApplication')
                              .snapshots(),
                          builder: (context, prodSnapshot) {
                            int produkBaru = 0;
                            int produkDisetujui = 0;
                            if (prodSnapshot.hasData) {
                              final prods = prodSnapshot.data!.docs;
                              produkBaru = prods.where((doc) {
                                final status = (doc['status'] ?? '').toString().toLowerCase();
                                return status == 'menunggu' || status == 'pending';
                              }).length;
                              produkDisetujui = prods.where((doc) {
                                final status = (doc['status'] ?? '').toString().toLowerCase();
                                return status == 'sukses' || status == 'approved';
                              }).length;
                            }
                            // --- QUERY IKLAN BARU & DISETUJUI (Real) ---
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('adsApplication')
                                  .snapshots(),
                              builder: (context, adSnap) {
                                int iklanBaru = 0;
                                int iklanDisetujui = 0;
                                if (adSnap.hasData) {
                                  final ads = adSnap.data!.docs;
                                  iklanBaru = ads.where((doc) =>
                                    (doc['status'] ?? '').toString().toLowerCase() == 'menunggu'
                                  ).length;
                                  iklanDisetujui = ads.where((doc) =>
                                    (doc['status'] ?? '').toString().toLowerCase() == 'disetujui'
                                  ).length;
                                }
                                return AdminSummaryCard(
                                  tokoBaru: tokoBaru,
                                  tokoTerdaftar: tokoTerdaftar,
                                  produkBaru: produkBaru,
                                  produkDisetujui: produkDisetujui,
                                  iklanBaru: iklanBaru,
                                  iklanAktif: iklanDisetujui,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminAbcPaymentSection(
                      items: [
                        AdminAbcPaymentData(
                          name: "Nippon Mart",
                          isSeller: true,
                          type: AbcPaymentType.withdraw,
                          amount: 25000,
                          createdAt: DateTime(2025, 4, 30, 16, 21),
                        ),
                        AdminAbcPaymentData(
                          name: "Rayhanmuzaki",
                          isSeller: false,
                          type: AbcPaymentType.topup,
                          amount: 25000,
                          createdAt: DateTime(2025, 4, 30, 16, 21),
                        ),
                      ],
                      onSeeAll: () {
                        // TODO: arahkan ke halaman daftar ABC Payment (nanti)
                      },
                      onDetail: (item) {
                        // TODO: buka detail ajuan (nanti)
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ====== STREAMBUILDER Ajuan Toko Terbaru ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('shopApplications')
                          .where('status', isEqualTo: 'pending')
                          .orderBy('submittedAt', descending: true)
                          .limit(2)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Terjadi kesalahan: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final submissions = (snapshot.data?.docs ?? []).map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return AdminStoreSubmissionData(
                            imagePath: data['logoUrl'] ?? '',
                            storeName: data['shopName'] ?? '-',
                            storeAddress: data['address'] ?? '-',
                            submitter: data['owner']?['nama'] ?? '-',
                            date: (data['submittedAt'] != null && data['submittedAt'] is Timestamp)
                                ? _formatDate((data['submittedAt'] as Timestamp).toDate())
                                : '-',
                            docId: doc.id,
                          );
                        }).toList();
                        return AdminStoreSubmissionSection(
                          submissions: submissions,
                          onSeeAll: () {
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                          onDetail: (submission) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminStoreApprovalDetailPage(
                                  docId: submission.docId,
                                  approvalData: null,
                                ),
                              ),
                            );
                          },
                          isNetworkImage: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ====== PRODUCT SECTION: produkApplication terbaru (pending) ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('productsApplication')
                          .where('status', whereIn: ['Menunggu', 'pending'])
                          .orderBy('createdAt', descending: true)
                          .limit(2)
                          .snapshots(),
                      builder: (context, prodSnap) {
                        if (prodSnap.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Terjadi kesalahan: ${prodSnap.error}'),
                          );
                        }
                        if (prodSnap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final submissions = (prodSnap.data?.docs ?? []).map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return AdminProductSubmissionData(
                            id: doc.id,
                            imagePath: data['imageUrl'] ?? '',
                            productName: data['name'] ?? '-',
                            categoryType: mapCategoryType(data['category']),
                            storeName: data['storeName'] ?? '-',
                            date: (data['createdAt'] != null && data['createdAt'] is Timestamp)
                                ? _formatDate((data['createdAt'] as Timestamp).toDate())
                                : '-',
                          );
                        }).toList();
                        return AdminProductSubmissionSection(
                          submissions: submissions,
                          onSeeAll: () {
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ====== IKLAN SECTION: REALTIME dari Firestore (Menunggu) ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('adsApplication')
                          .where('status', isEqualTo: 'Menunggu')
                          .orderBy('createdAt', descending: true)
                          .limit(2)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Terjadi kesalahan: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        final adSubmissions = docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final judul = data['judul'] ?? '-';
                          final durasiMulai = (data['durasiMulai'] is Timestamp)
                              ? (data['durasiMulai'] as Timestamp).toDate()
                              : DateTime.now();
                          final durasiSelesai = (data['durasiSelesai'] is Timestamp)
                              ? (data['durasiSelesai'] as Timestamp).toDate()
                              : DateTime.now();
                          final period = _formatPeriod(durasiMulai, durasiSelesai);
                          final createdAt = (data['createdAt'] is Timestamp)
                              ? (data['createdAt'] as Timestamp).toDate()
                              : DateTime.now();
                          final tglAjukan = DateFormat('dd/MM/yyyy, HH:mm').format(createdAt);

                          // Map ke AdApplication
                          final ad = AdApplication.fromFirestore(doc);

                          return AdminAdSubmissionData(
                            title: 'Iklan : $judul',
                            detailPeriod: period,
                            date: tglAjukan,
                            docId: doc.id,
                            ad: ad, // <--- PENTING
                          );
                        }).toList();

                        return AdminAdSubmissionSection(
                          submissions: adSubmissions,
                          onSeeAll: () {
                            setState(() {
                              _currentIndex = 3;
                            });
                          },
                          onDetail: (submission) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminAdApprovalDetailPage(ad: submission.ad),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: mainBody,
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // --- Helper period formatter ---
  String _formatPeriod(DateTime mulai, DateTime selesai) {
    final durasi = selesai.difference(mulai).inDays + 1;
    final locale = 'id_ID';
    final tglMulai = DateFormat('d MMMM', locale).format(mulai);
    final tglSelesai = DateFormat('d MMMM yyyy', locale).format(selesai);
    return "$durasi Hari • $tglMulai – $tglSelesai";
  }
}
