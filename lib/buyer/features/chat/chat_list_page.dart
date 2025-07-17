import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/widgets/chat_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart'; // pakai icon lucide
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Obrolan',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
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
                hintText: "Cari pesan....",
              ),
            ),
            const SizedBox(height: 8),

            // Firestore Chat List
            Expanded(
              child: _isLoadingStoreId || currentUser == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('buyerId', isEqualTo: currentUser.uid)
                        .orderBy('lastTimestamp', descending: true)
                        .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return _emptyChat();
                        }
                        // --- FILTER ---
                        final docs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          // --- filter chat untuk buyer (pov buyer) ---
                          final storeName = (data['shopName'] ?? '').toString().toLowerCase();
                          final storeId = data['shopId'] ?? data['storeId'] ?? '';
                          // --- hide chat ke toko sendiri (jika user juga seller) ---
                          if (_myStoreId != null && storeId == _myStoreId) return false;
                          // --- search: fallback ke id jika shopName kosong ---
                          if (searchQuery.isEmpty) return true;
                          return storeName.contains(searchQuery.toLowerCase()) ||
                                storeId.toString().toLowerCase().contains(searchQuery.toLowerCase());
                        }).toList();

                        if (docs.isEmpty) {
                          return _emptyChat();
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, idx) {
                            final chatData = docs[idx].data() as Map<String, dynamic>;
                            final chatId = docs[idx].id;
                            final storeName = chatData['shopName'] ?? '';
                            final storeId = chatData['shopId'] ?? chatData['storeId'] ?? '';
                            final lastMessage = chatData['lastMessage'] ?? '';
                            final lastTimestamp = chatData['lastTimestamp'];
                            final avatarUrl = chatData['shopAvatar'] ?? chatData['logoUrl'] ?? '';
                            final time = (lastTimestamp is Timestamp)
                                ? _formatTime(lastTimestamp.toDate())
                                : '';

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .where('isRead', isEqualTo: false)
                                  .where('senderId', isNotEqualTo: currentUser.uid) // unread dr toko
                                  .snapshots(),
                              builder: (context, snapshot) {
                                int unreadCount = 0;
                                if (snapshot.hasData) {
                                  unreadCount = snapshot.data!.docs.length;
                                }
                                return ChatListCard(
                                  avatarUrl: avatarUrl,
                                  name: storeName.isNotEmpty ? storeName : 'Toko tanpa nama',
                                  lastMessage: lastMessage,
                                  time: time,
                                  unreadCount: unreadCount,
                                  onTap: () async {
                                    // Saat buka chat, set semua isRead jadi true (jika pesan dari toko)
                                    final unreadDocs = snapshot.data?.docs ?? [];
                                    await Future.wait(
                                      unreadDocs.map((doc) => doc.reference.update({'isRead': true}))
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ChatDetailPage(
                                          chatId: chatId,
                                          shopId: storeId,
                                          shopName: storeName,
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
            "Cari toko dan mulai chat untuk pengalaman belanja yang lebih mudah.",
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
