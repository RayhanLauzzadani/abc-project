// lib/buyer/data/dummy_data.dart

final List<Map<String, dynamic>> dummyStores = [
  {
    'id': 'store1',
    'name': 'Nippon Mart',
    'image': 'assets/images/nihonmart.png',
    'distance': '4 km',
    'duration': '15 mins',
    'rating': 4.8,
  },
  {
    'id': 'store2',
    'name': 'Fresh Mart',
    'image': 'assets/images/nihonmart.png',
    'distance': '8 km',
    'duration': '30 mins',
    'rating': 4.7,
  },
  {
    'id': 'store3',
    'name': 'Jaya Mart',
    'image': 'assets/images/nihonmart.png',
    'distance': '12 km',
    'duration': '36 mins',
    'rating': 4.3,
  },
  {
    'id': 'store4',
    'name': 'Nihonggo Mart',
    'image': 'assets/images/nihonmart.png',
    'distance': '16 km',
    'duration': '15 mins',
    'rating': 3.9,
  },
];

final List<Map<String, dynamic>> dummyProducts = [
  // Produk Nippon Mart
  {
    'id': 'prod1',
    'storeId': 'store1',
    'image': 'assets/images/geprek.png',
    'name': 'Ayam Geprek',
    'price': 15000,
    'rating': 4.8,
    'category': 'Makanan',
    'description': 'Ayam geprek gurih pedas khas Nippon Mart.',
  },
  {
    'id': 'prod2',
    'storeId': 'store1',
    'image': 'assets/images/geprek.png',
    'name': 'Es Teh Uwueenak',
    'price': 7500,
    'rating': 3.9,
    'category': 'Minuman',
    'description': 'Es teh segar khas Nippon Mart.',
  },
  {
    'id': 'prod3',
    'storeId': 'store1',
    'image': 'assets/images/geprek.png',
    'name': 'Oreo Mini',
    'price': 2000,
    'rating': 4.6,
    'category': 'Snacks',
    'description': 'Oreo Mini enak dan crunchy.',
  },
  // Produk Fresh Mart
  {
    'id': 'prod4',
    'storeId': 'store2',
    'image': 'assets/images/geprek.png',
    'name': 'Keripik Kentang',
    'price': 12000,
    'rating': 4.7,
    'category': 'Snacks',
    'description': 'Keripik kentang renyah favorit anak muda!',
  },
  {
    'id': 'prod5',
    'storeId': 'store2',
    'image': 'assets/images/geprek.png',
    'name': 'Es Jeruk Segar',
    'price': 10000,
    'rating': 4.5,
    'category': 'Minuman',
    'description': 'Es jeruk segar menyegarkan hari Anda.',
  },
  // Produk Jaya Mart
  {
    'id': 'prod6',
    'storeId': 'store3',
    'image': 'assets/images/geprek.png',
    'name': 'Beng-Beng',
    'price': 7000,
    'rating': 4.3,
    'category': 'Snacks',
    'description': 'Coklat wafer legendaris.',
  },
  // Produk Nihonggo Mart
  {
    'id': 'prod7',
    'storeId': 'store4',
    'image': 'assets/images/geprek.png',
    'name': 'Roti Aoka',
    'price': 4500,
    'rating': 4.0,
    'category': 'Makanan',
    'description': 'Roti lembut isi coklat keju.',
  },
];
