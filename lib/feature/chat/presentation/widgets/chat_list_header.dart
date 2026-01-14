import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/themes/app_styles.dart';

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
                    AppLocalizations.of(context)!.messagesTitle,
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
                  decoration: AppStyles.searchInputDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.searchHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
