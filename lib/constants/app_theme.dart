import 'package:flutter/material.dart';

/// 应用主题色常量 - 温馨母婴配色
class AppColors {
  // 主色：温暖的珊瑚粉
  static const Color primary = Color(0xFFFF8A80);
  static const Color primaryLight = Color(0xFFFFBDB8);
  static const Color primaryDark = Color(0xFFE57373);
  
  // 辅助色
  static const Color secondary = Color(0xFF81D4FA);  // 天蓝
  static const Color accent = Color(0xFFFFF59D);     // 暖黄
  static const Color mint = Color(0xFF80CBC4);       // 薄荷绿
  
  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFCCBC), Color(0xFFFFAB91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 功能色
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
  
  // 中性色 - 暖色调
  static const Color background = Color(0xFFFDF8F5);  // 暖白背景
  static const Color surface = Colors.white;
  static const Color cardBackground = Color(0xFFFFF8F0); // 卡片暖背景
  static const Color textPrimary = Color(0xFF3E2723);   // 深棕色文字
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color textTertiary = Color(0xFF8D6E63);
  static const Color divider = Color(0xFFEFEBE9);
  
  // 喂养类型颜色
  static const Color breastMilk = Color(0xFFFFCCBC);
  static const Color formula = Color(0xFFBBDEFB);
  static const Color solidFood = Color(0xFFC8E6C9);
  
  // 睡眠颜色
  static const Color sleepGood = Color(0xFFA5D6A7);
  static const Color sleepNormal = Color(0xFFFFF59D);
  static const Color sleepPoor = Color(0xFFFFAB91);
}

/// 应用文本样式
class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textTertiary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// 应用尺寸常量
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXl = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusXl = 28.0;
  
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}

/// 应用业务常量
class AppConstants {
  // 日期选择器最早年份
  static const int minBirthYear = 2000;
  
  // 数据库查询默认限制
  static const int defaultQueryLimit = 10;
  static const int maxQueryLimit = 1000;
  
  // 备份版本
  static const String backupVersion = '1.0';
}

/// 动画时长常量
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}