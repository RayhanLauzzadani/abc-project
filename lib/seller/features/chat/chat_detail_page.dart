import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/widgets/chat_bubble.dart';
import 'package:abc_e_mart/widgets/edit_chat_dialog.dart';
import 'package:abc_e_mart/widgets/delete_chat_dialog.dart';
import 'package:abc_e_mart/data/services/notification_service.dart';
import 'package:abc_e_mart/widgets/unread_chat.dart';

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

class _SellerChatDetailPageState extends State<SellerChatDetailPage> with WidgetsBindingObserver {
  Map<String, dynamic>? buyerData;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  String _inputText = "";

  bool _scrolledToUnread = false;

  @override
  void initState() {
    super.initState();
    _fetchBuyerData();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addObserver(this); // <-- TAMBAHKAN INI

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      markChatNotificationAsRead(user.uid, widget.chatId);
    }
  }

  void _onTextChanged() {
    setState(() {
      _inputText = _controller.text;
    });
  }

  void _onLongPressMessage({
    required BuildContext context,
    required String messageId,
    required String currentText,
    required DateTime sentAt,
  }) {
    final canEdit = DateTime.now().difference(sentAt) < const Duration(minutes: 15);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF2056D3)),
                  title: const Text("Edit Pesan"),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final edited = await showEditChatDialog(
                      context: context,
                      currentText: currentText,
                    );
                    if (edited != null && edited != currentText && edited.isNotEmpty) {
                      final msgRef = FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId)
                          .collection('messages')
                          .doc(messageId);

                      await msgRef.update({
                        'text': edited,
                        'editedAt': FieldValue.serverTimestamp(),
                      });

                      // Update lastMessage di parent jika ini pesan terakhir
                      final messagesSnap = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId)
                          .collection('messages')
                          .orderBy('sentAt', descending: true)
                          .limit(1)
                          .get();

                      if (messagesSnap.docs.isNotEmpty &&
                          messagesSnap.docs.first.id == messageId) {
                        final lastMsgData = messagesSnap.docs.first.data();
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chatId)
                            .update({
                          'lastMessage': edited,
                          'lastTimestamp': lastMsgData['sentAt'],
                        });
                      }
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus Pesan"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDeleteChatDialog(
                    context: context,
                    messageText: currentText,
                  );
                  if (confirm == true) {
                    final messagesSnap = await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .orderBy('sentAt', descending: true)
                        .limit(2)
                        .get();

                    final isLast = messagesSnap.docs.isNotEmpty &&
                        messagesSnap.docs.first.id == messageId;

                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .doc(messageId)
                        .delete();

                    if (isLast) {
                      if (messagesSnap.docs.length > 1) {
                        final prevMsg = messagesSnap.docs[1].data();
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chatId)
                            .update({
                          'lastMessage': prevMsg['text'] ?? '',
                          'lastTimestamp': prevMsg['sentAt'],
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chatId)
                            .update({
                          'lastMessage': '',
                          'lastTimestamp': null,
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void jumpToFirstUnread(int index) {
    if (_scrollController.hasClients) {
      // Estimasi tinggi 1 bubble
      final itemHeight = 72.0;
      _scrollController.jumpTo(itemHeight * index);
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _fetchBuyerData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.buyerId).get();
    if (doc.exists) {
      setState(() {
        buyerData = doc.data();
      });
    }
  }

  Future<void> markChatNotificationAsRead(String userId, String chatId) async {
    final notifDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('chatId', isEqualTo: chatId)
        .where('type', isEqualTo: 'chat_message')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifDocs.docs) {
      await doc.reference.update({'isRead': true});
    }
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

      final sellerDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String sellerName = sellerDoc.data()?['name'] ?? '';

      await sendOrUpdateChatNotification(
        receiverId: widget.buyerId,
        chatId: widget.chatId,
        senderName: sellerName,
        lastMessage: text,
        senderRole: "seller",
      );

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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int? unreadIndex;

                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  final user = FirebaseAuth.instance.currentUser;

                  // Cari pesan pertama yang unread dari buyer (bukan seller sendiri)
                  for (int i = 0; i < messages.length; i++) {
                    final msg = messages[i].data() as Map<String, dynamic>;
                    if (msg['isRead'] == false && msg['senderId'] != user?.uid) {
                      unreadIndex = i;
                      break;
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_scrolledToUnread) {
                      if (unreadIndex != null) {
                        jumpToFirstUnread(unreadIndex);
                      } else if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                      _scrolledToUnread = true;
                    }
                  });

                  // Tandai pesan unread jadi read
                  Future.microtask(() async {
                    for (final doc in messages) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['isRead'] == false && data['senderId'] != user?.uid) {
                        await doc.reference.update({'isRead': true});
                      }
                    }
                  });

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
                      final isMe = msg['senderId'] == user?.uid;
                      final time = msg['sentAt'] is Timestamp ? _formatTime(msg['sentAt']) : '';
                      final isRead = msg['isRead'] == true;
                      final isEdited = msg.containsKey('editedAt') && msg['editedAt'] != null;

                      final showUnreadDivider = (unreadIndex != null && i == unreadIndex);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showUnreadDivider) const UnreadChatDivider(),
                          ChatBubble(
                            text: msg['text'] ?? '',
                            time: time,
                            isMe: isMe,
                            isRead: isMe ? isRead : false,
                            isEdited: isEdited,
                            onLongPress: isMe
                                ? () => _onLongPressMessage(
                                      context: context,
                                      messageId: snapshot.data!.docs[i].id,
                                      currentText: msg['text'] ?? '',
                                      sentAt: (msg['sentAt'] as Timestamp).toDate(),
                                    )
                                : null,
                          ),
                        ],
                      );
                    },
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(child: Text("Terjadi kesalahan"));
              },
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // vertical kecil
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
