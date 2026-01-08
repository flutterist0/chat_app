import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/data/models/notification_model.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFEFF6FF),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
               width: 40.w,
               height: 40.w,
               decoration: BoxDecoration(
                 color: const Color(0xFFEFF6FF),
                 shape: BoxShape.circle,
               ),
               child: Icon(Icons.notifications_outlined, color: AppStyles.primaryBlue),
             ),
             SizedBox(width: 12.w),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(
                         child: Text(
                           notification.title,
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 16.sp,
                             color: Colors.black87,
                           ),
                         ),
                       ),
                       if (!notification.isRead)
                         Container(
                           width: 8.w,
                           height: 8.w,
                           decoration: BoxDecoration(
                             color: AppStyles.primaryBlue,
                             shape: BoxShape.circle,
                           ),
                         ),
                     ],
                   ),
                   SizedBox(height: 4.h),
                   Text(
                     notification.body,
                     style: TextStyle(
                       fontSize: 14.sp,
                       color: Colors.black54,
                     ),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   SizedBox(height: 8.h),
                   Text(
                     _formatTime(notification.timestamp),
                     style: TextStyle(
                       fontSize: 12.sp,
                       color: Colors.grey,
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} dəqiqə əvvəl";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} saat əvvəl";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}
