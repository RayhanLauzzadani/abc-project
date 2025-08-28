import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OrderStatus {
  inProgress, // Dalam Proses
  success,    // Selesai
  canceled,   // Dibatalkan
  delivered,  // Terkirim / Selesai kirim
}

class CartAndOrderListCard extends StatelessWidget {
  final String storeName;
  final String orderId;           // Firestore doc.id (untuk navigasi/query)
  final String? displayId;        // ID yang ditampilkan (mis. invoiceId)
  final String productImage;
  final int itemCount;
  final int totalPrice;
  final DateTime? orderDateTime;
  final OrderStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? statusText;
  final bool showStatusBadge;
  final String? actionTextOverride;
  final IconData? actionIconOverride;

  const CartAndOrderListCard({
    Key? key,
    required this.storeName,
    required this.orderId,
    this.displayId,                 // NEW
    required this.productImage,
    required this.itemCount,
    required this.totalPrice,
    this.orderDateTime,
    required this.status,
    this.statusText,
    this.onTap,
    this.onActionTap,
    this.showStatusBadge = true,
    this.actionTextOverride,
    this.actionIconOverride,
  }) : super(key: key);

  Widget _buildProductImage(String path) {
    final isUrl = path.startsWith('http');
    final img = isUrl
        ? Image.network(
            path,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 28, color: Colors.grey),
          )
        : Image.asset(
            path,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: img,
    );
  }

  static String _rupiah(int v) {
    // Simple thousand separator with dots
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromRight = s.length - i;
      b.write(s[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return b.toString();
  }

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
      case OrderStatus.delivered:
        statusBgColor = const Color(0xFFF1F7FF);
        statusTextColor = const Color(0xFF1976D2);
        statusBorderColor = const Color(0xFF1976D2);
        label = statusText ?? "Terkirim";
        break;
    }

    final String actionText =
        actionTextOverride ?? (status == OrderStatus.inProgress ? "Lacak Pesanan" : "Detail Pesanan");
    final IconData actionIcon = actionIconOverride ?? Icons.chevron_right_rounded;

    // Pakai displayId kalau ada (invoiceId), fallback ke orderId
    final shownId = (displayId != null && displayId!.isNotEmpty) ? displayId! : orderId;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.7),
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
                _buildProductImage(productImage),
                const SizedBox(width: 15),
                Expanded(
                  child: Stack(
                    children: [
                      // Info
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
                            "#$shownId",
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
                      // Badge
                      if (showStatusBadge)
                        Positioned(
                          right: 0,
                          top: 4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 88,
                              maxWidth: 116,
                              minHeight: 18,
                              maxHeight: 20,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 18,
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: statusBorderColor, width: 1.25),
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
            // ROW BAWAH: harga, item, aksi
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 11, right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Rp ${_rupiah(totalPrice)}",
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
                        ),
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
