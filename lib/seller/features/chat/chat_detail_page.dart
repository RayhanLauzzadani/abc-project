import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/widgets/chat_bubble.dart';

class SellerChatDetailPage extends StatefulWidget {
  final String chatId;
  final String buyerId;
  final String buyerName;

  const SellerChatDetailPage({
    super.key,
    required this.chatId,
    required this.buyerId,
    required this.buyerName,
  });

  @override
  State<SellerChatDetailPage> createState() => _SellerChatDetailPageState();
}

class _SellerChatDetailPageState extends State<SellerChatDetailPage> {
  Map<String, dynamic>? buyerData;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  String _inputText = "";

  @override
  void initState() {
    super.initState();
    _fetchBuyerData();
    _controller.addListener(_onTextChanged);
    _markAllMessagesAsRead(); // Tambahkan di sini!
  }

  void _onTextChanged() {
    setState(() {
      _inputText = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBuyerData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.buyerId).get();
    if (doc.exists) {
      setState(() {
        buyerData = doc.data();
      });
    }
  }

  Future<void> _markAllMessagesAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: user.uid)
          .get();
      for (final doc in query.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {}
  }


  String _getBuyerStatus() {
    if (buyerData == null) return '';
    final isOnline = buyerData?['isOnline'] ?? false;
    if (isOnline) {
      return 'Online';
    } else {
      final lastLogin = buyerData?['lastLogin'];
      if (lastLogin is Timestamp) {
        final now = DateTime.now();
        final diff = now.difference(lastLogin.toDate());

        if (diff.inMinutes < 1) {
          return 'Terakhir dilihat baru saja';
        } else if (diff.inMinutes < 60) {
          return 'Terakhir dilihat ${diff.inMinutes} menit yang lalu';
        } else if (diff.inHours < 24) {
          return 'Terakhir dilihat ${diff.inHours} jam yang lalu';
        } else {
          final days = diff.inDays > 7 ? 7 : diff.inDays;
          return 'Terakhir dilihat $days hari yang lalu';
        }
      } else {
        return 'Offline';
      }
    }
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda belum login. Silakan login dulu!")),
      );
      return;
    }
    if (_sending) return;

    setState(() {
      _sending = true;
    });

    try {
      final now = DateTime.now();

      final msgRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc();

      await msgRef.set({
        'senderId': user.uid,
        'text': text,
        'sentAt': Timestamp.fromDate(now),
        'isRead': false,
        'type': 'text',
      });

      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'lastTimestamp': Timestamp.fromDate(now),
      });

      _controller.clear();

      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim pesan: $e")),
      );
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  String _formatTime(Timestamp sentAt) {
    final dt = sentAt.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final buyerAvatar = buyerData?['avatar'] ?? '';
    final buyerName = buyerData?['name'] ?? widget.buyerName;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, right: 0, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C55C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar buyer dengan dot status online/offline
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: buyerAvatar != ''
                          ? Image.network(
                              buyerAvatar,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 42,
                              height: 42,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, color: Color(0xFF1C55C0), size: 26),
                            ),
                    ),
                    if (buyerData != null)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: (buyerData?['isOnline'] == true)
                                ? const Color(0xFF00C168)
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.3),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Nama pembeli dan status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        buyerName,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _getBuyerStatus(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: (buyerData?['isOnline'] == true)
                              ? const Color(0xFF00C168)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- List pesan bubble chat
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada percakapan.\nMulai chat sekarang.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[600]),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == userId;
                    final time = msg['sentAt'] is Timestamp ? _formatTime(msg['sentAt']) : '';
                    final isRead = msg['isRead'] == true;
                    return ChatBubble(
                      text: msg['text'] ?? '',
                      time: time,
                      isMe: isMe,
                      isRead: isMe ? isRead : false,
                    );
                  },
                );
              },
            ),
          ),
          // --- Input pesan bawah
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.dmSans(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Ketik Pesanmu...",
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 15),
                        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      enabled: !_sending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: (_inputText.trim().isEmpty || _sending) ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_inputText.trim().isEmpty || _sending)
                            ? Colors.grey[300]
                            : const Color(0xFF2056D3),
                        shape: BoxShape.circle,
                      ),
                      child: _sending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
