import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            decoration: BoxDecoration(
              color: message.isSentByMe ? Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: message.isSentByMe ? Radius.circular(4.r) : Radius.circular(20.r),
                bottomLeft: message.isSentByMe ? Radius.circular(20.r) : Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5.r,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isSentByMe ? Colors.white : Colors.grey[900],
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.isSentByMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}