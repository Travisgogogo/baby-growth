/// 睡眠预测配置常量
class SleepPredictionConfig {
  /// 标准清醒间隔配置（分钟）
  /// 格式: {最大月龄: 清醒间隔}
  static const Map<int, int> standardWakeWindows = {
    0: 45,   // 新生儿
    1: 60,   // 1个月
    3: 90,   // 3个月
    5: 120,  // 5个月
    7: 180,  // 7个月
    10: 240, // 10个月
    14: 300, // 14个月
    20: 360, // 20个月
  };

  /// 默认清醒间隔（20个月以上）
  static const int defaultWakeWindow = 360;

  /// 短觉阈值（分钟）
  static const int shortNapThreshold = 45;

  /// 长觉阈值（分钟）
  static const int longNapThreshold = 120;

  /// 短觉后清醒间隔调整比例（缩短20%）
  static const double shortNapAdjustment = 0.8;

  /// 长觉后清醒间隔调整（增加分钟数）
  static const int longNapAdjustment = 15;

  /// 最小清醒间隔（3个月以上）
  static const int minWakeWindow = 60;

  /// 状态进度阈值
  static const double awakeThreshold = 0.5;
  static const double gettingSleepyThreshold = 0.75;
  static const double sleepySoonThreshold = 0.9;

  /// 超时判断阈值（分钟）
  static const int overdueThreshold = 30;

  /// 根据月龄获取标准清醒间隔
  static int getWakeWindowForAge(int ageInMonths) {
    for (final entry in standardWakeWindows.entries) {
      if (ageInMonths < entry.key) {
        return entry.value;
      }
    }
    return defaultWakeWindow;
  }
}
