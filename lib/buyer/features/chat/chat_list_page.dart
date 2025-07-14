import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/widgets/chat_list_card.dart';
import 'package:abc_e_mart/buyer/data/dummy/dummy_data.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // Pakai dummyStores untuk avatar dan nama toko
  final List<Map<String, dynamic>> chatList = List.generate(5, (index) {
    final store = dummyStores[index % dummyStores.length];
    return {
      'avatarUrl': store['image'],
      'name': store['name'],
      'lastMessage': 'Of course, we just added that to your order and will deliver it soon.',
      'time': '3:40 PM',
      'unreadCount': index == 0 ? 2 : 0,
    };
  });

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter chat sesuai search
    final filteredChat = chatList.where((chat) =>
      chat['name'].toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

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
            // Search Bar (pakai SearchBar global, ganti hintText)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: custom_widgets.SearchBar(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                hintText: "Cari pesan....",
              ),
            ),
            const SizedBox(height: 8),
            // List Chat
            Expanded(
              child: ListView.builder(
                itemCount: filteredChat.length,
                itemBuilder: (context, idx) {
                  final chat = filteredChat[idx];
                  return ChatListCard(
                    avatarUrl: chat['avatarUrl'] ?? '',
                    name: chat['name'] ?? '',
                    lastMessage: chat['lastMessage'] ?? '',
                    time: chat['time'] ?? '',
                    unreadCount: chat['unreadCount'] ?? 0,
                    onTap: () {
                      // TODO: Navigasi ke halaman detail chat
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
}
