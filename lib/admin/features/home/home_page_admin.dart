import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/admin/widgets/admin_home_header.dart';
import 'package:abc_e_mart/admin/widgets/admin_summary_card.dart';
import 'package:abc_e_mart/admin/widgets/admin_store_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_product_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_bottom_navbar.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_page.dart';
import 'package:abc_e_mart/admin/features/approval/product/admin_product_approval_page.dart';
import 'package:abc_e_mart/admin/widgets/admin_ad_submission_section.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_page.dart';
import 'package:abc_e_mart/buyer/features/auth/login_page.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart';
import 'package:abc_e_mart/admin/features/notification/notification_page_admin.dart';

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
      final token = await user.getIdTokenResult(true); // refresh token
      final claims = token.claims;
      print('>>> CUSTOM CLAIMS: $claims');

      // Jika bukan admin, force logout!
      if (claims == null || claims['admin'] != true) {
        _forceLogoutWithMsg(
          'Akses admin diperlukan. Silakan login dengan akun admin.',
        );
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
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
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
          const SizedBox(height: 15),
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
                          tokoBaru = docs
                              .where(
                                (doc) =>
                                    (doc['status'] ?? '')
                                        .toString()
                                        .toLowerCase() ==
                                    'pending',
                              )
                              .length;
                          tokoTerdaftar = docs
                              .where(
                                (doc) =>
                                    (doc['status'] ?? '')
                                        .toString()
                                        .toLowerCase() ==
                                    'approved',
                              )
                              .length;
                        }
                        // Stream produk application (untuk summary produk baru/disetujui)
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
                                final status = (doc['status'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return status == 'menunggu' ||
                                    status == 'pending';
                              }).length;
                              produkDisetujui = prods.where((doc) {
                                final status = (doc['status'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return status == 'sukses' ||
                                    status == 'approved';
                              }).length;
                            }

                            // TODO: Untuk iklan, implementasi mirip (belum diambil Firestore)
                            int iklanBaru = 0;
                            int iklanAktif = 0;

                            return AdminSummaryCard(
                              tokoBaru: tokoBaru,
                              tokoTerdaftar: tokoTerdaftar,
                              produkBaru: produkBaru,
                              produkDisetujui: produkDisetujui,
                              iklanBaru: iklanBaru,
                              iklanAktif: iklanAktif,
                            );
                          },
                        );
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
                          print(
                            'Firestore StreamBuilder error: ${snapshot.error}',
                          );
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Terjadi kesalahan: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final submissions = (snapshot.data?.docs ?? []).map((
                          doc,
                        ) {
                          final data = doc.data() as Map<String, dynamic>;
                          return AdminStoreSubmissionData(
                            imagePath: data['logoUrl'] ?? '',
                            storeName: data['shopName'] ?? '-',
                            storeAddress: data['address'] ?? '-',
                            submitter: data['owner']?['nama'] ?? '-',
                            date:
                                (data['submittedAt'] != null &&
                                    data['submittedAt'] is Timestamp)
                                ? _formatDate(
                                    (data['submittedAt'] as Timestamp).toDate(),
                                  )
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
                                  approvalData: null, // ambil dari Firestore
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
                        if (prodSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final submissions = (prodSnap.data?.docs ?? []).map((
                          doc,
                        ) {
                          final data = doc.data() as Map<String, dynamic>;
                          return AdminProductSubmissionData(
                            id: doc.id, // <--- Tambahkan ini!
                            imagePath: data['imageUrl'] ?? '',
                            productName: data['name'] ?? '-',
                            category: data['category'] ?? '-',
                            categoryType: _parseCategoryType(data['category']),
                            storeName: data['storeName'] ?? '-',
                            date:
                                (data['createdAt'] != null &&
                                    data['createdAt'] is Timestamp)
                                ? _formatDate(
                                    (data['createdAt'] as Timestamp).toDate(),
                                  )
                                : '-',
                          );
                        }).toList();

                        return AdminProductSubmissionSection(
                          submissions: submissions, // <-- Ini HARUS ADA!
                          onSeeAll: () {
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                          onDetail: (submission) {
                            // TODO: Navigasi ke detail produk approval
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ====== IKLAN SECTION (dummy/hardcoded) ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminAdSubmissionSection(
                      submissions: [
                        AdminAdSubmissionData(
                          title: 'Iklan : Ayam Geprek',
                          detailPeriod: '3 Hari • 21 Juli – 23 Juli 2025',
                          date: '30/06/2024, 4:15 PM',
                        ),
                        AdminAdSubmissionData(
                          title: 'Iklan : Ayam Geprek',
                          detailPeriod: '3 Hari • 21 Juli – 23 Juli 2025',
                          date: '30/06/2024, 4:15 PM',
                        ),
                      ],
                      onSeeAll: () {
                        setState(() {
                          _currentIndex = 3;
                        });
                      },
                      onDetail: (submission) {},
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
      body: SafeArea(child: mainBody),
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
}

/// Helper: auto-mapping kategori string ke CategoryType enum
CategoryType _parseCategoryType(String? cat) {
  switch ((cat ?? '').toLowerCase()) {
    case 'makanan':
      return CategoryType.makanan;
    case 'minuman':
      return CategoryType.minuman;
    case 'snacks':
      return CategoryType.snacks;
    case 'merchandise':
      return CategoryType.merchandise;
    default:
      return CategoryType.makanan;
  }
}
