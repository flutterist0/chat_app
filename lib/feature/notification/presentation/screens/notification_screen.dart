import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/logic/bloc/notification_bloc.dart';
import 'package:test_app/feature/notification/presentation/widgets/notification_item.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/feature/chat/service/friendship_service.dart';

@RoutePage()
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.pleaseLogin)),
      );
    }

    return BlocProvider(
      create: (context) => getIt<NotificationBloc>()..add(LoadNotifications(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.notificationsTitle,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                    return IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                       _showClearAllDialog(context, userId);
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
             if (state is NotificationLoading) {
               return Center(child: CircularProgressIndicator());
             } else if (state is NotificationError) {
               return Center(child: Text("${AppLocalizations.of(context)!.error}: ${state.message}"));
             } else if (state is NotificationLoaded) {
               if (state.notifications.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.notifications_off_outlined, size: 60.sp, color: Colors.grey),
                       SizedBox(height: 16.h),
                       Text(AppLocalizations.of(context)!.noNotifications, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                     ],
                   ),
                 );
               }
               return ListView.builder(
                 itemCount: state.notifications.length,
                 itemBuilder: (context, index) {
                   final notification = state.notifications[index];
                   return NotificationItem(
                     notification: notification,
                     onTap: () {
                       context.read<NotificationBloc>().add(MarkAsRead(userId, notification.id));
                     },
                     onAccept: () async {
                        if (notification.senderId != null) {
                           await getIt<FriendshipService>().acceptFollowRequest(notification.senderId!, notification.id);
                        }
                     },
                     onReject: () async {
                        if (notification.senderId != null) {
                           await getIt<FriendshipService>().rejectFollowRequest(notification.senderId!, notification.id);
                        }
                     },
                   );
                 },
               );
             }
             return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearAll),
        content: Text(AppLocalizations.of(context)!.clearAllDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () {
               context.read<NotificationBloc>().add(ClearAllNotifications(userId));
               Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
