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
    final token = await user?.getIdTokenResult(true);
    // Log only for debugging, can remove this line if not needed
    print('>>> CUSTOM CLAIMS: ${token?.claims}');
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('shopApplications')
                          .snapshots(),
                      builder: (context, snapshot) {
                        int tokoBaru = 0;
                        int tokoTerdaftar = 0;
                        if (snapshot.hasData) {
                          final docs = snapshot.data!.docs;
                          tokoBaru = docs
                              .where(
                                (doc) => (doc['status'] ?? '') == 'approved',
                              )
                              .length;
                          tokoTerdaftar = docs
                              .where(
                                (doc) => (doc['status'] ?? '') != 'approved',
                              )
                              .length;
                        }
                        return AdminSummaryCard(
                          tokoBaru: tokoBaru,
                          tokoTerdaftar: tokoTerdaftar,
                          produkBaru: 5, // TODO: Integrasi produk baru
                          iklanBaru: 30, // TODO: Integrasi iklan baru
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
                  // PRODUCT SECTION (dummy/hardcoded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminProductSubmissionSection(
                      submissions: [
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Makanan',
                          categoryType: CategoryType.makanan,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Minuman',
                          categoryType: CategoryType.minuman,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                      ],
                      onSeeAll: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      onDetail: (submission) {},
                      // isNetworkImage: jangan dikasih! hanya untuk logo toko!
                    ),
                  ),
                  const SizedBox(height: 20),
                  // IKLAN SECTION (dummy/hardcoded)
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
