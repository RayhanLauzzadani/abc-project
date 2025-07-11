import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/cart/cart_item.dart';

class CartBox extends StatelessWidget {
  final String title; // e.g., 'Keranjang 1'
  final String storeName;
  final bool isChecked;
  final ValueChanged<bool> onChecked;
  final List<CartItem> items;
  final void Function(int idx, int qty) onQtyChanged;

  const CartBox({
    super.key,
    required this.title,
    required this.storeName,
    required this.isChecked,
    required this.onChecked,
    required this.items,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 0), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF212121),
                  ),
                  margin: const EdgeInsets.only(right: 6),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (v) => onChecked(v ?? false),
                  activeColor: const Color(0xFF2979FF),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          // Garis patah-patah benar-benar full width (tanpa padding)
          const _DashedDivider(),
          // ISI BOX
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Toko",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  storeName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Produk yang Dipesan",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gambar produk
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(item.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        // Nama produk, harga, qty
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF212121),
                                  )),
                              if (item.variant != null && item.variant!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(item.variant!,
                                      style: const TextStyle(fontSize: 13, color: Colors.blue)),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rp ${item.price}",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF212121),
                                    ),
                                  ),
                                  const Spacer(),
                                  // TOMBOL - (SELALU AKTIF, BISA 0 UNTUK HAPUS)
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () => onQtyChanged(idx, item.quantity - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      item.quantity.toString(),
                                      style: GoogleFonts.dmSans(
                                          fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () => onQtyChanged(idx, item.quantity + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Button untuk + dan -
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22, // <-- Dikecilkan dari 28 ke 22
        height: 22,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[300] : const Color(0xFF2979FF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 13, // <-- Dikecilkan dari 17 ke 13
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1.3,
              color: const Color(0xFFE0E0E0),
              margin: const EdgeInsets.only(right: dashSpace),
            );
          }),
        );
      },
    );
  }
}
