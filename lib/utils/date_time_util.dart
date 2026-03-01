import 'package:intl/intl.dart';

/// 日期时间格式化工具类
class DateTimeUtil {
  static final DateFormat _dateFormat = DateFormat('yyyy年MM月dd日');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy年MM月dd日 HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _shortDateFormat = DateFormat('MM月dd日');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");

  /// 格式化为日期字符串：2024年01月15日
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 格式化为日期时间字符串：2024年01月15日 14:30
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// 格式化为时间字符串：14:30
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// 格式化为短日期字符串：01月15日
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// 格式化为 ISO 8601 字符串
  static String formatISO(DateTime dateTime) {
    return _isoFormat.format(dateTime);
  }

  /// 格式化为自定义格式
  static String format(DateTime dateTime, String pattern) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化为相对时间（如：3天前）
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}年前';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化为持续时间（如：2小时30分钟）
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}小时${minutes}分钟';
      }
      return '${hours}小时';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// 格式化为月龄显示
  static String formatAgeInMonths(int ageInMonths) {
    if (ageInMonths < 12) {
      return '$ageInMonths个月';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (months == 0) {
      return '$years岁';
    }
    return '$years岁$months个月';
  }
}
