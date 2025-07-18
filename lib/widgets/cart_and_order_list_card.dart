import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OrderStatus {
  inProgress, // Dalam Proses
  success,    // Selesai
  canceled,   // Dibatalkan
}

class CartAndOrderListCard extends StatelessWidget {
  final String storeName;
  final String orderId;
  final String productImage;
  final int itemCount;
  final int totalPrice;
  final DateTime? orderDateTime;
  final OrderStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? statusText;

  const CartAndOrderListCard({
    Key? key,
    required this.storeName,
    required this.orderId,
    required this.productImage,
    required this.itemCount,
    required this.totalPrice,
    this.orderDateTime,
    required this.status,
    this.statusText,
    this.onTap,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    Color statusBorderColor;
    String label;
    switch (status) {
      case OrderStatus.inProgress:
        statusBgColor = const Color(0xFFFFFBF1);
        statusTextColor = const Color(0xFFEAB600);
        statusBorderColor = const Color(0xFFEAB600);
        label = statusText ?? "Dalam Proses";
        break;
      case OrderStatus.success:
        statusBgColor = const Color(0xFFF1FFF6);
        statusTextColor = const Color(0xFF28A745);
        statusBorderColor = const Color(0xFF28A745);
        label = statusText ?? "Selesai";
        break;
      case OrderStatus.canceled:
        statusBgColor = const Color(0xFFFFF1F3);
        statusTextColor = const Color(0xFFDC3545);
        statusBorderColor = const Color(0xFFDC3545);
        label = statusText ?? "Dibatalkan";
        break;
    }

    String actionText = status == OrderStatus.inProgress ? "Lacak Pesanan" : "Detail Pesanan";
    IconData actionIcon = Icons.chevron_right_rounded;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDDDDDD),
            width: 1.7,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROW ATAS: image, info, badge mepet kanan
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gambar produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                // Kolom info + badge pakai Stack
                Expanded(
                  child: Stack(
                    children: [
                      // Info Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 1),
                          Text(
                            storeName,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "#$orderId",
                            style: GoogleFonts.dmSans(
                              fontSize: 12.2,
                              color: const Color(0xFF444444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (orderDateTime != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              "${orderDateTime!.day.toString().padLeft(2, '0')}/${orderDateTime!.month.toString().padLeft(2, '0')}/${orderDateTime!.year}, ${orderDateTime!.hour.toString().padLeft(2, '0')}:${orderDateTime!.minute.toString().padLeft(2, '0')}",
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFFB2B2B2),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Badge di kanan atas info, tapi di-TURUNKAN dikit biar pas
                      Positioned(
                        right: 0,
                        top: 4, // Naik-turun badge, ubah sesuai kebutuhan (4 = cukup ideal)
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 88, maxWidth: 116, minHeight: 18, maxHeight: 20,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          height: 18,
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: statusBorderColor,
                              width: 1.25,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 4.0,
                                height: 4.0,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: statusTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Flexible(
                                child: Center(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w600,
                                      color: statusTextColor,
                                      fontSize: 11.5,
                                      letterSpacing: 0.02,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // BOTTOM ROW: Harga, item, aksi kanan
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 11, right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.2,
                      color: const Color(0xFF444444),
                    ),
                  ),
                  Text(
                    " • $itemCount items",
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF444444),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onActionTap ?? onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionText,
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF565656),
                            fontWeight: FontWeight.w500,
                            fontSize: 13.2,
                          ),
                        ),
                        Icon(
                          actionIcon,
                          color: const Color(0xFFB2B2B2),
                          size: 19,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
