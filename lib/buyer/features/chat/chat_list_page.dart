import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/widgets/chat_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String? _myStoreId; // toko milik user (kalau user juga seller)
  bool _isLoadingStoreId = true;

  @override
  void initState() {
    super.initState();
    _getMyStoreId();
  }

  Future<void> _getMyStoreId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingStoreId = false);
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _myStoreId = (doc.data()?['storeId'] as String?)?.trim();
      _isLoadingStoreId = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Heuristik: chat dianggap DM (buyer↔buyer) bila:
  /// - channel/type == 'dm', ATAU
  /// - shopId kosong/tidak ada
  bool _looksLikeDm(Map<String, dynamic> m) {
    final channel = (m['channel'] ?? m['type'] ?? '').toString().toLowerCase();
    final shopId = (m['shopId'] ?? m['storeId'] ?? '').toString();
    return channel == 'dm' || shopId.isEmpty;
  }

  /// Heuristik self-chat: user adalah buyer sekaligus owner toko tujuan.
  bool _isSelfChat(Map<String, dynamic> m, String? myStoreId, String myUid) {
    final shopId = (m['shopId'] ?? m['storeId'] ?? '').toString();
    final ownerId = (m['shopOwnerId'] ?? m['ownerId'] ?? m['sellerId'] ?? '').toString();
    if (myStoreId != null && myStoreId.isNotEmpty && shopId == myStoreId) return true;
    if (ownerId.isNotEmpty && ownerId == myUid) return true;
    return false;
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
                          // fokus list buyer ↔ seller dari sisi buyer
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

                        // --- FILTER client-side (agar aman untuk data lama) ---
                        final docs = snapshot.data!.docs.where((doc) {
                          final data = (doc.data() as Map<String, dynamic>);
                          // 1) hard filter: hanya chat buyer ↔ seller (bukan DM)
                          if (_looksLikeDm(data)) return false;

                          // 2) hide self-chat (kalau user juga seller)
                          if (_isSelfChat(data, _myStoreId, currentUser.uid)) return false;

                          // 3) search: berdasarkan nama toko atau id toko
                          final storeName = (data['shopName'] ?? '').toString().toLowerCase();
                          final storeId = (data['shopId'] ?? data['storeId'] ?? '').toString().toLowerCase();
                          if (searchQuery.isEmpty) return true;
                          final q = searchQuery.toLowerCase();
                          return storeName.contains(q) || storeId.contains(q);
                        }).toList();

                        if (docs.isEmpty) {
                          return _emptyChat();
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, idx) {
                            final chatData = docs[idx].data() as Map<String, dynamic>;
                            final chatId = docs[idx].id;

                            final storeName = (chatData['shopName'] ?? '').toString();
                            final storeId = (chatData['shopId'] ?? chatData['storeId'] ?? '').toString();
                            final lastMessage = (chatData['lastMessage'] ?? '').toString();
                            final lastTimestamp = chatData['lastTimestamp'];
                            final avatarUrl = (chatData['shopAvatar'] ?? chatData['logoUrl'] ?? '').toString();
                            final time = (lastTimestamp is Timestamp)
                                ? _formatTime(lastTimestamp.toDate())
                                : '';

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .where('isRead', isEqualTo: false)
                                  // unread dari toko (bukan pesan yang user kirim sendiri)
                                  .where('senderId', isNotEqualTo: currentUser.uid)
                                  .snapshots(),
                              builder: (context, msgSnap) {
                                int unreadCount = 0;
                                if (msgSnap.hasData) {
                                  unreadCount = msgSnap.data!.docs.length;
                                }

                                return ChatListCard(
                                  avatarUrl: avatarUrl,
                                  name: storeName.isNotEmpty ? storeName : 'Toko tanpa nama',
                                  lastMessage: lastMessage,
                                  time: time,
                                  unreadCount: unreadCount,
                                  onTap: () async {
                                    // Guard ekstra saat tap (kalau ada data lama lolos filter)
                                    if (_isSelfChat(chatData, _myStoreId, currentUser.uid)) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (_) => const AlertDialog(
                                          title: Text('Chat tidak valid'),
                                          content: Text('Anda tidak dapat membuka chat dengan toko Anda sendiri.'),
                                        ),
                                      );
                                      return;
                                    }

                                    // Tandai pesan toko sebagai read
                                    final unreadDocs = msgSnap.data?.docs ?? [];
                                    await Future.wait(
                                      unreadDocs.map((d) => d.reference.update({'isRead': true})),
                                    );

                                    if (!context.mounted) return;
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dt.day}/${dt.month}/${dt.year}";
    }
  }
}
