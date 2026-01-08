import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/shared/utils/app_strings.dart';

class SearchUserHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onClearPressed;

  const SearchUserHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.blueGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppStyles.paddingSmall),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppStyles.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.newMessage,
                    style: AppStyles.headerWhiteSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppStyles.paddingSmall, 0,
                  AppStyles.paddingSmall, AppStyles.paddingSmall),
              child: Container(
                decoration: AppStyles.searchBoxDecorationWhite,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchUserHint,
                    hintStyle: TextStyle(color: AppStyles.grey500),
                    prefixIcon: Icon(Icons.search, color: AppStyles.grey600),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppStyles.grey600),
                            onPressed: onClearPressed,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
