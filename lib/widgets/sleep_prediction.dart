import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/sleep_prediction_config.dart';
import '../models/baby.dart';
import '../models/sleep_record.dart';

/// 睡眠预测工具类
class SleepPredictor {
  /// 根据月龄获取标准清醒间隔（分钟）
  static int getStandardWakeWindow(int ageInMonths) {
    return SleepPredictionConfig.getWakeWindowForAge(ageInMonths);
  }

  /// 预测下次入睡时间
  static SleepPrediction? predictNextSleep({
    required Baby baby,
    required List<SleepRecord> recentRecords,
  }) {
    if (recentRecords.isEmpty) return null;

    final now = DateTime.now();

    // recentRecords 已经按 startTime DESC 排序（数据库查询时指定）
    // 最新的记录是第一个
    final latestRecord = recentRecords.first;

    // 检查是否正在睡觉（最新的记录没有结束时间）
    if (latestRecord.endTime == null) {
      // 正在睡觉中
      final sleepDuration = now.difference(latestRecord.startTime);
      return SleepPrediction(
        status: SleepStatus.sleeping,
        message: '宝宝正在睡觉',
        nextSleepTime: null,
        minutesUntilSleepy: null,
        progress: null,
        standardWakeWindow: null,
        awakeMinutes: null,
        currentSleepDuration: sleepDuration.inMinutes,
      );
    }

    // 找到最近一次有结束时间的睡眠（按结束时间排序，找最新的）
    final completedSleeps = recentRecords
        .where((r) => r.endTime != null)
        .toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));

    if (completedSleeps.isEmpty) {
      // 没有已完成的睡眠记录
      return null;
    }

    // 获取最近一次完成的睡眠
    final lastSleep = completedSleeps.first;

    // 计算已清醒时长（从上次醒来时间到现在）
    final awakeDuration = now.difference(lastSleep.endTime!);
    final awakeMinutes = awakeDuration.inMinutes;

    // 获取标准清醒间隔
    final ageInMonths = baby.ageInMonths ?? 0;
    final standardWindow = getStandardWakeWindow(ageInMonths);

    // 根据上次睡眠时长修正
    final lastSleepDuration = lastSleep.endTime!.difference(lastSleep.startTime).inMinutes;
    int adjustedWindow = standardWindow;

    if (lastSleepDuration < SleepPredictionConfig.shortNapThreshold) {
      // 短觉，下次提前睡
      adjustedWindow = (adjustedWindow * SleepPredictionConfig.shortNapAdjustment).round();
    } else if (lastSleepDuration > SleepPredictionConfig.longNapThreshold) {
      // 长觉（超过2小时），下次可以晚一点
      adjustedWindow += SleepPredictionConfig.longNapAdjustment;
    }

    // 确保最小清醒间隔（新生儿除外）
    if (ageInMonths >= 3 && adjustedWindow < SleepPredictionConfig.minWakeWindow) {
      adjustedWindow = SleepPredictionConfig.minWakeWindow;
    }

    // 计算距离困倦还有多久
    final minutesUntilSleepy = adjustedWindow - awakeMinutes;

    if (minutesUntilSleepy <= 0) {
      return SleepPrediction(
        status: SleepStatus.overdue,
        message: awakeMinutes > adjustedWindow + SleepPredictionConfig.overdueThreshold
            ? '宝宝已经困过头了，快哄睡吧'
            : '宝宝可能已经困了',
        nextSleepTime: now,
        minutesUntilSleepy: 0,
        progress: 1.0,
        standardWakeWindow: standardWindow,
        awakeMinutes: awakeMinutes,
        lastSleepDuration: lastSleepDuration,
        adjustedWindow: adjustedWindow,
      );
    }

    // 计算进度（0-1）
    final progress = awakeMinutes / adjustedWindow;

    // 生成状态消息
    String message;
    SleepStatus status;

    if (progress < SleepPredictionConfig.awakeThreshold) {
      status = SleepStatus.awake;
      message = '宝宝精神不错';
    } else if (progress < SleepPredictionConfig.gettingSleepyThreshold) {
      status = SleepStatus.gettingSleepy;
      message = '开始有点困了';
    } else if (progress < SleepPredictionConfig.sleepySoonThreshold) {
      status = SleepStatus.sleepySoon;
      message = '很快就要困了';
    } else {
      status = SleepStatus.sleepySoon;
      message = '该准备哄睡了';
    }

    return SleepPrediction(
      status: status,
      message: message,
      nextSleepTime: now.add(Duration(minutes: minutesUntilSleepy)),
      minutesUntilSleepy: minutesUntilSleepy,
      progress: progress.clamp(0.0, 1.0),
      standardWakeWindow: standardWindow,
      awakeMinutes: awakeMinutes,
      lastSleepDuration: lastSleepDuration,
      adjustedWindow: adjustedWindow,
    );
  }
}

/// 睡眠预测结果
class SleepPrediction {
  final SleepStatus status;
  final String message;
  final DateTime? nextSleepTime;
  final int? minutesUntilSleepy;
  final double? progress;
  final int? standardWakeWindow;
  final int? awakeMinutes;
  final int? lastSleepDuration;
  final int? adjustedWindow;
  final int? currentSleepDuration;

  SleepPrediction({
    required this.status,
    required this.message,
    this.nextSleepTime,
    this.minutesUntilSleepy,
    this.progress,
    this.standardWakeWindow,
    this.awakeMinutes,
    this.lastSleepDuration,
    this.adjustedWindow,
    this.currentSleepDuration,
  });

  /// 格式化显示时间
  String get formattedTime {
    if (nextSleepTime == null) return '--:--';
    final hour = nextSleepTime!.hour.toString().padLeft(2, '0');
    final minute = nextSleepTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 格式化显示剩余时间
  String get formattedRemaining {
    if (minutesUntilSleepy == null) return '';
    if (minutesUntilSleepy! <= 0) return '现在';
    final hours = minutesUntilSleepy! ~/ 60;
    final mins = minutesUntilSleepy! % 60;
    if (hours > 0) {
      return '${hours}小时${mins}分钟';
    }
    return '${mins}分钟';
  }

  /// 格式化当前睡眠时长
  String get formattedCurrentSleep {
    if (currentSleepDuration == null) return '';
    final hours = currentSleepDuration! ~/ 60;
    final mins = currentSleepDuration! % 60;
    if (hours > 0) {
      return '${hours}小时${mins}分钟';
    }
    return '${mins}分钟';
  }
}

enum SleepStatus {
  sleeping,      // 正在睡觉
  awake,         // 清醒
  gettingSleepy, // 开始困了
  sleepySoon,    // 很快要困
  overdue,       // 已经超时
}

/// 睡眠预测卡片组件
class SleepPredictionCard extends StatelessWidget {
  final SleepPrediction? prediction;

  const SleepPredictionCard({
    super.key,
    this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    if (prediction == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _buildGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _buildShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _buildIcon(),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '睡眠预测',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prediction!.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (prediction!.status == SleepStatus.sleeping)
            _buildSleepingView()
          else
            _buildAwakeView(),
        ],
      ),
    );
  }

  Widget _buildSleepingView() {
    return Row(
      children: [
        const Icon(
          Icons.bedtime,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '宝宝正在睡觉，好好休息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              if (prediction!.currentSleepDuration != null) ...[
                const SizedBox(height: 4),
                Text(
                  '已睡 ${prediction!.formattedCurrentSleep}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAwakeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '预计入睡时间',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prediction!.formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '还有',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prediction!.formattedRemaining,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (prediction!.progress != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prediction!.progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _buildStatusText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  String _buildStatusText() {
    final awake = prediction!.awakeMinutes;
    final standard = prediction!.standardWakeWindow;
    final adjusted = prediction!.adjustedWindow;
    final lastSleep = prediction!.lastSleepDuration;

    if (awake == null || standard == null) return '';

    String text = '已清醒 ${awake} 分钟';

    if (adjusted != null && adjusted != standard) {
      text += ' / 建议 ${adjusted} 分钟';
      if (lastSleep != null) {
        if (lastSleep < 45) {
          text += '（上次短觉，提前睡）';
        } else if (lastSleep > 120) {
          text += '（上次长觉，可延后）';
        }
      }
    } else {
      text += ' / 建议 ${standard} 分钟';
    }

    return text;
  }

  LinearGradient _buildGradient() {
    switch (prediction!.status) {
      case SleepStatus.sleeping:
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        );
      case SleepStatus.awake:
        return const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        );
      case SleepStatus.gettingSleepy:
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        );
      case SleepStatus.sleepySoon:
      case SleepStatus.overdue:
        return const LinearGradient(
          colors: [Color(0xFFfa709a), Color(0xFFfee140)],
        );
    }
  }

  Color _buildShadowColor() {
    switch (prediction!.status) {
      case SleepStatus.sleeping:
        return const Color(0xFF667eea).withOpacity(0.4);
      case SleepStatus.awake:
        return const Color(0xFF11998e).withOpacity(0.4);
      case SleepStatus.gettingSleepy:
        return const Color(0xFFf093fb).withOpacity(0.4);
      case SleepStatus.sleepySoon:
      case SleepStatus.overdue:
        return const Color(0xFFfa709a).withOpacity(0.4);
    }
  }

  IconData _buildIcon() {
    switch (prediction!.status) {
      case SleepStatus.sleeping:
        return Icons.bedtime;
      case SleepStatus.awake:
        return Icons.wb_sunny;
      case SleepStatus.gettingSleepy:
        return Icons.cloud;
      case SleepStatus.sleepySoon:
      case SleepStatus.overdue:
        return Icons.bedtime;
    }
  }
}
