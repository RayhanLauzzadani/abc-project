import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/admin/data/models/admin_store_data.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:abc_e_mart/admin/features/approval/store/widgets/admin_store_approval_card.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart';

class AdminStoreApprovalPage extends StatefulWidget {
  const AdminStoreApprovalPage({super.key});

  @override
  State<AdminStoreApprovalPage> createState() => _AdminStoreApprovalPageState();
}

class _AdminStoreApprovalPageState extends State<AdminStoreApprovalPage> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 31),
              Text(
                'Persetujuan Toko',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 23),
              // Search Bar
              AdminSearchBar(
                hintText: "Cari Nama Toko / Pemilik",
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
              const SizedBox(height: 16),
              // === STREAMBUILDER DARI FIRESTORE ===
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('shopApplications')
                      .where('status', isEqualTo: 'pending')
                      .orderBy('submittedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Terjadi kesalahan: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada pengajuan toko yang masuk.",
                          style: TextStyle(
                            color: Color(0xFF9A9A9A),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    // Convert ke model
                    final allData = snapshot.data!.docs
                        .map((doc) => AdminStoreApprovalData.fromDoc(doc))
                        .toList();

                    // Filter by search query
                    final filteredData = _searchQuery.isEmpty
                        ? allData
                        : allData.where((data) {
                            final lowerQuery = _searchQuery.toLowerCase();
                            return data.storeName.toLowerCase().contains(lowerQuery) ||
                                data.submitter.toLowerCase().contains(lowerQuery);
                          }).toList();

                    // Kondisi kosong setelah search
                    if (filteredData.isEmpty) {
                      if (_searchQuery.isEmpty) {
                        return const Center(
                          child: Text(
                            "Belum ada pengajuan toko yang masuk.",
                            style: TextStyle(
                              color: Color(0xFF9A9A9A),
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Tidak ada hasil sesuai pencarian.",
                            style: TextStyle(
                              color: Color(0xFF9A9A9A),
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredData.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final approvalData = filteredData[index];
                        return AdminStoreApprovalCard(
                          data: approvalData,
                          isNetworkImage: true,
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminStoreApprovalDetailPage(
                                  docId: approvalData.docId,
                                  approvalData: approvalData,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
