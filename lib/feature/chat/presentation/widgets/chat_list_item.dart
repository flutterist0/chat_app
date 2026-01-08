import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppStyles.grey200)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: AppStyles.circleGradientDecoration,
                  child: Center(
                    child: Text(
                      chat.name.split(' ').map((e) => e[0]).take(2).join(),
                      style: TextStyle(
                        color: AppStyles.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0.sp,
                    right: 0.sp,
                    child: Container(
                      width: 16.w,
                      height: 16.h,
                      decoration: AppStyles.onlineIndicatorDecoration,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.grey900,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppStyles.grey600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppStyles.grey600,
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(6),
                decoration: AppStyles.unreadCountDecoration,
                child: Text(
                  '${chat.unreadCount}',
                  style: TextStyle(
                    color: AppStyles.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}