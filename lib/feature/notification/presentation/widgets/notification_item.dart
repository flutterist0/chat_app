import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/data/models/notification_model.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    this.onAccept,
    this.onReject,
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
                   if (notification.type == 'follow_request')
                     Padding(
                       padding: EdgeInsets.only(bottom: 8.h),
                       child: _buildRequestContent(),
                     ),
                   Text(
                     _formatTime(context, notification.timestamp),
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

  Widget _buildRequestContent() {
    if (notification.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: Size(0, 36.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Qəbul et', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                minimumSize: Size(0, 36.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Rədd et', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } else if (notification.status == 'accepted') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
            SizedBox(width: 8.w),
            Text(
              'Qəbul edildi', 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (notification.status == 'rejected') {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, size: 16.sp, color: Colors.red),
            SizedBox(width: 8.w),
            Text(
              'Rədd edildi',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }


  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.timeMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.timeHoursAgo(difference.inHours);
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}
