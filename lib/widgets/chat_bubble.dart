import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;
  final VoidCallback? onLongPress;
  final bool isEdited;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.time,
    required this.isMe,
    this.isRead = false,
    this.onLongPress,
    this.isEdited = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFD4E6FF) : const Color(0xFFFFF6D8);
    final radius = Radius.circular(18);

    // Maksimal lebar bubble: 75% layar
    double maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    return GestureDetector(
      onLongPress: onLongPress,
      child:Padding(
        padding: EdgeInsets.only(
          top: 6,
          bottom: 2,
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble
            Container(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? radius : Radius.circular(7),
                  topRight: isMe ? Radius.circular(7) : radius,
                  bottomLeft: radius,
                  bottomRight: radius,
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: 15.5,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            // Waktu & Read status
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isMe ? 0 : 4,
                right: isMe ? 4 : 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (isMe && isRead) ...[
                    Text(
                      "Read",
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  // Tambahkan keterangan Edit
                  if (isEdited) ...[
                    const SizedBox(width: 6),
                    Text(
                      "Edit",
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
