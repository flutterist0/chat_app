import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class ChatHeader extends StatelessWidget {
  final Chat chat;
  final VoidCallback onBackPressed;

  const ChatHeader({
    super.key,
    required this.chat,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.blueGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.sp),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed,
              ),
              Container(
                width: 40.w,
                height: 40.h,
                decoration: chat.photoUrl != null ? null : AppStyles.chatHeaderProfileDecoration,
                child: chat.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          chat.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: AppStyles.chatHeaderProfileDecoration,
                              child: Center(
                                child: Text(
                                  chat.name.isEmpty ? '?' : chat.name[0].toUpperCase(),
                                  style: AppStyles.chatName,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          chat.name.isNotEmpty
                              ? chat.name.substring(0, 1).toUpperCase()
                              : '?',
                          style: AppStyles.chatName,
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: AppStyles.chatHeaderName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      chat.isOnline ? AppLocalizations.of(context)!.online : AppLocalizations.of(context)!.offline,
                      style: AppStyles.chatStatus,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
