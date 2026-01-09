import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/message.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/shared/utils/app_strings.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(Message)? onSwipe;
  final Function(Message)? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onSwipe,
    this.onLongPress,

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
        padding: const EdgeInsets.only(left: 20),
        color: Colors.transparent,
        child: Icon(Icons.reply, color: AppStyles.grey600, size: 30),
      ),
      child: GestureDetector(
        onLongPress: (){
          if (onLongPress != null) {
            onLongPress!(message);
          }
        },
          child: Align(
            alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(isImage ? 4 : 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: AppStyles.messageBubbleDecoration(context, isSentByMe: message.isSentByMe),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isReply)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: AppStyles.replyMessageDecoration(isSentByMe: message.isSentByMe),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replySender ?? AppStrings.user,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: message.isSentByMe ? AppStyles.white70 : AppStyles.primaryBlue,
                              fontSize: 12.sp,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getPreviewText(message.replyText!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: message.isSentByMe ? AppStyles.white60 : AppStyles.black54,
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
                              return Icon(Icons.broken_image, color: AppStyles.white);
                            },
                          ),
                        ),
                      )
                          : Text(
                        message.text,
                        style: TextStyle(
                          color: message.isSentByMe 
                              ? AppStyles.white 
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppStyles.black87),
                          fontSize: 16.sp,
                        ),
                      ),
                      const SizedBox(height: 4),
        

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.time,
                          style: TextStyle(
                            color: message.isSentByMe ? AppStyles.white70 : AppStyles.grey500,
                            fontSize: 10.sp,
                          ),
                        ),
                        if (message.isSentByMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all, 
                            size: 16.sp,
                            color: message.isRead
                                ? AppStyles.lightBlueAccent 
                                : AppStyles.white54,
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPreviewText(String text) {
    if (text.length > 50 && !text.contains(' ')) {
      return AppStrings.photo;
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
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}