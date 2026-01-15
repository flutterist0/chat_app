import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class UserListItem extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onAccept;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    this.onFollow,
    this.onUnfollow,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          key == null ? onTap : null, // Disable main tap if needed, or keep it
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
                  decoration: user.photoUrl != null
                      ? null
                      : AppStyles.circleGradientDecoration,
                  child: user.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    decoration:
                                        AppStyles.circleGradientDecoration,
                                    child: Center(
                                      child: Text(
                                        user.name.isEmpty
                                            ? '?'
                                            : user.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: AppStyles.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                          ),
                        )
                      : Center(
                          child: Text(
                            user.name.isEmpty
                                ? '?'
                                : user.name
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                            style: TextStyle(
                              color: AppStyles.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                if (user.isOnline)
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
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.grey900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppStyles.grey600,
                    ),
                  ),
                ],
              ),
            ),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (user.friendshipStatus) {
      case FriendshipStatus.mutual:
        return Container(
          decoration: AppStyles.messageButtonDecoration,
          child: IconButton(
            icon: Icon(
              Icons.message,
              color: AppStyles.primaryBlue,
              size: 22.sp,
            ),
            onPressed: onTap,
          ),
        );
      case FriendshipStatus.pendingSent:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Gözlədilir', // AppLocalizations.of(context)!.pending
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case FriendshipStatus.pendingReceived:
        return SizedBox(
          height: 32.h,
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            ),
            child: Text(
              'Qəbul et', // Accept
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
        );
      case FriendshipStatus.following:
        return Container(
           height: 32.h,
           child: OutlinedButton(
            onPressed: onUnfollow, // Allow unfollow
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            ),
            child: Text(
              'Takip edirsiniz', // Following
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );
      case FriendshipStatus.followedBy:
        return SizedBox(
          height: 32.h,
          child: ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            ),
            child: Text(
              'Geri takip et', // Follow Back
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
        );
      case FriendshipStatus.none:
      default:
        return SizedBox(
          height: 32.h,
          child: ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryBlue,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
              minimumSize: Size(0, 32.h),
            ),
            child: Text(
              'Takip et', // Follow
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
        );
    }
  }
}
