import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart'; // Import the category type
import 'package:abc_e_mart/widgets/category_selector.dart'; // Import CategorySelector
import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_search_bar; // Use custom search bar

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // Initialize category types for filtering
  final List<CategoryType> categories = [
    CategoryType.merchandise,
    CategoryType.alatTulis,
    CategoryType.alatLab,
    CategoryType.produkDaurUlang,
    CategoryType.produkKesehatan,
    CategoryType.makanan,
    CategoryType.minuman,
    CategoryType.snacks,
    CategoryType.lainnya,
  ];

  int _selectedCategory = 0; // Default selected category is "Semua"
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for transactions
  final List<Map<String, dynamic>> transactions = [
    {
      'invoiceId': 'NPN001',
      'status': 'Sukses',
      'total': 75000,
      'items': [
        {'name': 'Ayam Geprek', 'note': 'Pedas', 'qty': 1},
        {'name': 'Ayam Geprek', 'note': 'Sedang', 'qty': 1},
      ]
    },
    {
      'invoiceId': 'NPN002',
      'status': 'Gagal',
      'total': 50000,
      'items': [
        {'name': 'Nasi Goreng', 'note': '', 'qty': 1},
        {'name': 'Es Teh', 'note': '', 'qty': 2},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20, top: 40),
          child: Text(
            'Transaksi',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: const Color(0xFF373E3C),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 23),
            // Search Bar integration
            custom_search_bar.SearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() {
                _searchText = val;
              }),
            ),
            const SizedBox(height: 21),
            // Category Type Selector
            CategorySelector(
              categories: categories,
              selectedIndex: _selectedCategory,
              onSelected: (i) => setState(() => _selectedCategory = i),
            ),
            const SizedBox(height: 21),
            // Transactions List (Dummy Data)
            ListView.builder(
              shrinkWrap: true,
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final invoiceId = transaction['invoiceId'];
                final status = transaction['status'];
                final total = transaction['total'];
                final items = transaction['items'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Invoice ID: $invoiceId'),
                    subtitle: Text('Status: $status'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total: Rp $total'),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to transaction detail page
                          },
                          child: Text("Detail Transaksi"),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the transaction detail page
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
