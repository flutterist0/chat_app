import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/shared/utils/app_strings.dart';

class ChatListHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final Function(String)? onSearchChanged;

  const ChatListHeader({
    super.key,
    required this.onMenuPressed,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.blueGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppStyles.paddingSmall),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.messagesTitle,
                    style: AppStyles.headerWhite,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: AppStyles.white),
                    onPressed: onMenuPressed,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: AppStyles.searchBoxDecoration,
                child: TextField(
                  style: AppStyles.inputTextWhite,
                  onChanged: onSearchChanged,
                  decoration: AppStyles.searchInputDecoration,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
