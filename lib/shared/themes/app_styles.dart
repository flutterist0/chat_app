import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/shared/utils/app_strings.dart';

class AppStyles {
  // Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDarkBlue = Color(0xFF1D4ED8);
  static const Color gradientStart = Color(0xFF3B82F6);
  static const Color gradientEnd = Color(0xFF9333EA);
  
  static const Color white = Colors.white;
  static const Color red = Colors.red;
  static const Color green = Colors.green;
  
  static Color get grey900 => Colors.grey[900]!;
  static Color get grey700 => Colors.grey[700]!;
  static Color get grey600 => Colors.grey[600]!;
  static Color get grey500 => Colors.grey[500]!;
  static Color get grey400 => Colors.grey[400]!;
  static Color get grey300 => Colors.grey[300]!;
  static Color get grey200 => Colors.grey[200]!;
  static Color get grey100 => Colors.grey[100]!;
  static Color get white70 => Colors.white70;
  static Color get white30 => Colors.white.withOpacity(0.3);
  static Color get white54 => Colors.white54;
  static Color get white60 => Colors.white60;
  static Color get black54 => Colors.black54;
  static Color get black87 => Colors.black87;
  static Color get lightBlueAccent => Colors.lightBlueAccent;
  static Color get black05 => Colors.black.withOpacity(0.05);
  static Color get black10 => Colors.black.withOpacity(0.1);
  static Color get white20 => Colors.white.withOpacity(0.2);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
  );

  static const Gradient blueGradient = LinearGradient(
    colors: [primaryBlue, primaryDarkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // TextStyles
  static TextStyle get headerLarge => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: grey900,
  );
  
  static TextStyle get headerWhite => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static TextStyle get headerWhiteSmall => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static TextStyle get chatName => TextStyle(
    color: white,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get chatHeaderName => TextStyle(
    color: white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get chatStatus => TextStyle(
    color: white70,
    fontSize: 12.sp,
  );

  static TextStyle get emptyText => TextStyle(color: Colors.grey);
  
  static TextStyle get replyName => TextStyle(
    fontWeight: FontWeight.bold,
    color: primaryBlue,
  );

  static TextStyle get replyContent => TextStyle(
    color: black54,
  );

  static TextStyle get subHeader => TextStyle(
    fontSize: 16.sp,
    color: grey600,
  );
  
  static TextStyle get buttonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: white,
  );

  static TextStyle get linkText => TextStyle(
    color: primaryBlue,
    fontWeight: FontWeight.w600,
    fontSize: 14.sp, 
  );

  static TextStyle get bodyText => TextStyle(
    color: grey600,
    fontSize: 14.sp,
  );
  
  static TextStyle get inputHint => TextStyle(
    color: white70,
  );

  static TextStyle get inputTextWhite => TextStyle(
    color: white,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  static InputDecoration searchInputDecoration = InputDecoration(
    hintText: AppStrings.searchHint,
    hintStyle: TextStyle(color: white70),
    prefixIcon: Icon(Icons.search, color: white70),
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 20.w,
      vertical: 15.h,
    ),
  );

  // Button Style
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: white,
    padding: EdgeInsets.symmetric(vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    elevation: 0,
  );

  // Container Decorations
  static BoxDecoration get circleGradientDecoration => BoxDecoration(
    gradient: primaryGradient,
    shape: BoxShape.circle,
  );
  
  static BoxDecoration get searchBoxDecoration => BoxDecoration(
    color: white20,
    borderRadius: BorderRadius.circular(25.r),
  );

  static BoxDecoration get searchBoxDecorationWhite => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(25.r),
  );

  static BoxDecoration get chatHeaderProfileDecoration => BoxDecoration(
    color: white30,
    shape: BoxShape.circle,
  );

  static BoxDecoration get inputContainerDecoration => BoxDecoration(
    color: grey100,
    borderRadius: BorderRadius.circular(25.r),
  );

  static BoxDecoration get sendButtonDecoration => BoxDecoration(
    color: primaryBlue,
    shape: BoxShape.circle,
  );

  static BoxDecoration get replyPanelDecoration => BoxDecoration(
    color: grey200,
  );
  
  static BoxDecoration get chatInputAreaDecoration => BoxDecoration(
    color: white,
    border: Border(top: BorderSide(color: grey300)),
  );

  static BoxDecoration get onlineIndicatorDecoration => BoxDecoration(
    color: green,
    shape: BoxShape.circle,
    border: Border.all(color: white, width: 2.w),
  );

  static BoxDecoration get unreadCountDecoration => BoxDecoration(
    color: primaryBlue,
    shape: BoxShape.circle,
  );

  static BoxDecoration get messageButtonDecoration => BoxDecoration(
    color: primaryBlue.withOpacity(0.1),
    shape: BoxShape.circle,
  );

  static Decoration messageBubbleDecoration({required bool isSentByMe}) {
    return BoxDecoration(
      color: isSentByMe ? primaryBlue : white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
        bottomLeft: isSentByMe ? Radius.circular(16.r) : Radius.circular(0),
        bottomRight: isSentByMe ? Radius.circular(0) : Radius.circular(16.r),
      ),
      boxShadow: [
        BoxShadow(
          color: black05,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Decoration replyMessageDecoration({required bool isSentByMe}) {
    return BoxDecoration(
      color: black10,
      borderRadius: BorderRadius.circular(8.r),
      border: Border(
        left: BorderSide(
          color: isSentByMe ? white : primaryBlue,
          width: 4.w,
        ),
      ),
    );
  }

  static double get paddingDefault => 24.w;
  static double get paddingSmall => 16.w;
}
