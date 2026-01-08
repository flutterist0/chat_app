import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/logic/bloc/notification_bloc.dart';
import 'package:test_app/feature/notification/presentation/widgets/notification_item.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("Zəhmət olmasa daxil olun")),
      );
    }

    return BlocProvider(
      create: (context) => getIt<NotificationBloc>()..add(LoadNotifications(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Bildirişlər",
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
               return Center(child: Text("Xəta: ${state.message}"));
             } else if (state is NotificationLoaded) {
               if (state.notifications.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.notifications_off_outlined, size: 60.sp, color: Colors.grey),
                       SizedBox(height: 16.h),
                       Text("Bildiriş yoxdur", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
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
        title: Text("Təmizlə"),
        content: Text("Bütün bildirişləri silmək istədiyinizə əminsiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Xeyr"),
          ),
          TextButton(
            onPressed: () {
               context.read<NotificationBloc>().add(ClearAllNotifications(userId));
               Navigator.pop(ctx);
            },
            child: Text("Bəli", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
