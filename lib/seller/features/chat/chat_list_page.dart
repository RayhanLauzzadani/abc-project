import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/widgets/chat_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'chat_detail_page.dart';

class SellerChatListPage extends StatefulWidget {
  const SellerChatListPage({super.key});

  @override
  State<SellerChatListPage> createState() => _SellerChatListPageState();
}

class _SellerChatListPageState extends State<SellerChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String? _myStoreId;
  bool _isLoadingStoreId = true;

  @override
  void initState() {
    super.initState();
    _getMyStoreId();
  }

  Future<void> _getMyStoreId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingStoreId = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _myStoreId = doc.data()?['storeId'];
      _isLoadingStoreId = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                    "Obrolan",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: custom_widgets.SearchBar(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                hintText: "Cari pembeli....",
              ),
            ),
            const SizedBox(height: 8),

            // Firestore Chat List
            Expanded(
              child: _isLoadingStoreId || currentUser == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: (_myStoreId == null)
                          ? null
                          : FirebaseFirestore.instance
                              .collection('chats')
                              .where('shopId', isEqualTo: _myStoreId)
                              .orderBy('lastTimestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return _emptyChat();
                        }
                        // --- FILTER untuk seller ---
                        final docs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final buyerName = (data['buyerName'] ?? '').toString().toLowerCase();
                          final buyerId = data['buyerId'] ?? '';
                          // Kalau search, cari by name atau buyer id
                          if (searchQuery.isEmpty) return true;
                          return buyerName.contains(searchQuery.toLowerCase()) ||
                              buyerId.toString().toLowerCase().contains(searchQuery.toLowerCase());
                        }).toList();

                        if (docs.isEmpty) {
                          return _emptyChat();
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, idx) {
                            final chatData = docs[idx].data() as Map<String, dynamic>;
                            final chatId = docs[idx].id;
                            final buyerName = chatData['buyerName'] ?? '';
                            final buyerId = chatData['buyerId'] ?? '';
                            final lastMessage = chatData['lastMessage'] ?? '';
                            final lastTimestamp = chatData['lastTimestamp'];
                            final avatarUrl = chatData['buyerAvatar'] ?? '';
                            final time = (lastTimestamp is Timestamp)
                                ? _formatTime(lastTimestamp.toDate())
                                : '';

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatId)
                                .collection('messages')
                                .where('isRead', isEqualTo: false)
                                .where('senderId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                              builder: (context, snapshot) {
                                int unreadCount = 0;
                                if (snapshot.hasData) {
                                  unreadCount = snapshot.data!.docs.length;
                                }
                                return ChatListCard(
                                  avatarUrl: avatarUrl,
                                  name: buyerName.isNotEmpty ? buyerName : 'Pembeli tanpa nama',
                                  lastMessage: lastMessage,
                                  time: time,
                                  unreadCount: unreadCount,
                                  onTap: () async {
                                    // Ambil semua dokumen pesan yang unread
                                    final unreadDocs = snapshot.data?.docs ?? [];
                                    final currentUid = FirebaseAuth.instance.currentUser!.uid;

                                    // Jalankan update secara paralel (lebih cepat!)
                                    await Future.wait(unreadDocs.map((doc) async {
                                      final data = doc.data() as Map<String, dynamic>?;
                                      if (data == null) return;
                                      if (data['senderId'] == currentUid) return; // skip update jika pesan dari diri sendiri
                                      await doc.reference.update({'isRead': true});
                                    }));

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SellerChatDetailPage(
                                          chatId: chatId,
                                          buyerId: buyerId,
                                          buyerName: buyerName,
                                        ),
                                      ),
                                    );
                                  },
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
    );
  }

  Widget _emptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messagesSquare, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 18),
          Text(
            "Obrolan anda masih kosong",
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            "Belum ada pesan dari pembeli ke toko anda.",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Format waktu sesuai kebutuhan
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dt.day}/${dt.month}/${dt.year}";
    }
  }
}
