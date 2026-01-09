import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/shared/themes/app_styles.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final double iconSize;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.iconSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: iconSize.w,
          height: iconSize.w,
          decoration: AppStyles.circleGradientDecoration,
          child: Icon(
            icon,
            size: (iconSize / 2).sp,
            color: AppStyles.white,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppStyles.headerLarge(context),
        ),
        SizedBox(height: 8.h),
        Text(
          subTitle,
          textAlign: TextAlign.center,
          style: AppStyles.subHeader(context),
        ),
      ],
    );
  }
}
