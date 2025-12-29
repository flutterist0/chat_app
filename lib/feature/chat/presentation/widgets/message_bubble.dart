import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(Message)? onSwipe;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isImage = message.text.length > 100 && !message.text.contains(' ');
    bool isReply = message.replyText != null && message.replyText!.isNotEmpty;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if (onSwipe != null) {
          onSwipe!(message);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        color: Colors.transparent,
        child: Icon(Icons.reply, color: Colors.grey[600], size: 30),
      ),
      child: Align(
        alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: EdgeInsets.all(isImage ? 4 : 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: message.isSentByMe ? Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: message.isSentByMe ? Radius.circular(16) : Radius.circular(0),
              bottomRight: message.isSentByMe ? Radius.circular(0) : Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReply)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: message.isSentByMe ? Colors.white : Color(0xFF2563EB),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.replySender ?? 'İstifadəçi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: message.isSentByMe ? Colors.white70 : Color(0xFF2563EB),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getPreviewText(message.replyText!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: message.isSentByMe ? Colors.white60 : Colors.black54,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isImage
                      ? GestureDetector(
                    onTap: () => _showFullImage(context, message.text),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(message.text),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, color: Colors.white);
                        },
                      ),
                    ),
                  )
                      : Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white : Colors.black87,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white70 : Colors.grey[500],
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPreviewText(String text) {
    if (text.length > 50 && !text.contains(' ')) {
      return "📷 Şəkil";
    }
    return text;
  }

  void _showFullImage(BuildContext context, String base64String) {
    final imageBytes = base64Decode(base64String);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}