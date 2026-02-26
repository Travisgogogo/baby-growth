import 'package:flutter/material.dart';

/// 应用主题色常量
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF667eea);
  static const Color secondary = Color(0xFF764ba2);
  
  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 功能色
  static const Color success = Color(0xFF4ade80);
  static const Color warning = Color(0xFFfbbf24);
  static const Color error = Color(0xFFf87171);
  
  // 中性色
  static const Color background = Color(0xFFFDFCF8);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color divider = Color(0xFFE0E0E0);
}

/// 应用文本样式
class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

/// 应用尺寸常量
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  static const double iconSmall = 16.0;
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
