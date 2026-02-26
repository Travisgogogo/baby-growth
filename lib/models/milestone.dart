/// 里程碑分类枚举
enum MilestoneCategory {
  grossMotor,    // 大运动
  fineMotor,     // 精细动作
  language,      // 语言发展
  socialEmotion, // 社交情绪
}

/// 里程碑分类扩展
extension MilestoneCategoryExtension on MilestoneCategory {
  String get displayName {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return '大运动';
      case MilestoneCategory.fineMotor:
        return '精细动作';
      case MilestoneCategory.language:
        return '语言发展';
      case MilestoneCategory.socialEmotion:
        return '社交情绪';
    }
  }

  String get iconName {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return 'directions_run';
      case MilestoneCategory.fineMotor:
        return 'back_hand';
      case MilestoneCategory.language:
        return 'record_voice_over';
      case MilestoneCategory.socialEmotion:
        return 'mood';
    }
  }

  String get description {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return '翻身、坐立、爬行、行走等大肌肉群运动能力';
      case MilestoneCategory.fineMotor:
        return '抓握、捏取、涂鸦等手眼协调能力';
      case MilestoneCategory.language:
        return '咿呀学语、词汇积累、句子表达等语言能力';
      case MilestoneCategory.socialEmotion:
        return '微笑、认生、互动、情绪表达等社交能力';
    }
  }
}

/// 里程碑定义类
/// 包含里程碑的基本信息和预期达成时间范围
class Milestone {
  final String id;
  final MilestoneCategory category;
  final int minMonth;      // 最早达成月龄
  final int maxMonth;      // 最晚达成月龄
  final String title;
  final String description;
  final String trainingTip;

  const Milestone({
    required this.id,
    required this.category,
    required this.minMonth,
    required this.maxMonth,
    required this.title,
    required this.description,
    required this.trainingTip,
  });

  /// 获取月龄范围显示文本
  String get monthRange {
    if (minMonth == maxMonth) {
      return '$minMonth个月';
    } else if (maxMonth >= 36) {
      return '$minMonth个月以后';
    } else {
      return '$minMonth-$maxMonth个月';
    }
  }

  /// 判断指定月龄是否在此里程碑的时间范围内
  bool isInRange(int month) {
    return month >= minMonth && month <= maxMonth;
  }

  /// 判断指定月龄是否已达到此里程碑的最早时间
  bool isReached(int month) {
    return month >= minMonth;
  }

  /// 获取进度状态
  /// 0: 未开始, 1: 进行中, 2: 已达成
  int getProgressStatus(int currentMonth) {
    if (currentMonth < minMonth) return 0;
    if (currentMonth > maxMonth) return 2;
    return 1;
  }

  @override
  String toString() {
    return 'Milestone(id: $id, category: ${category.displayName}, title: $title, range: $monthRange)';
  }
}

/// 用户里程碑记录类
/// 记录宝宝实际达成里程碑的情况
class MilestoneRecord {
  final int? id;
  final int babyId;
  final String milestoneId;
  final DateTime completedDate;
  final String? photoPath;
  final String? note;

  MilestoneRecord({
    this.id,
    required this.babyId,
    required this.milestoneId,
    required this.completedDate,
    this.photoPath,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'milestoneId': milestoneId,
      'completedDate': completedDate.toIso8601String(),
      'photoPath': photoPath,
      'note': note,
    };
  }

  factory MilestoneRecord.fromMap(Map<String, dynamic> map) {
    return MilestoneRecord(
      id: map['id'],
      babyId: map['babyId'],
      milestoneId: map['milestoneId'],
      completedDate: DateTime.parse(map['completedDate']),
      photoPath: map['photoPath'],
      note: map['note'],
    );
  }

  MilestoneRecord copyWith({
    int? id,
    int? babyId,
    String? milestoneId,
    DateTime? completedDate,
    String? photoPath,
    String? note,
  }) {
    return MilestoneRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      milestoneId: milestoneId ?? this.milestoneId,
      completedDate: completedDate ?? this.completedDate,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'MilestoneRecord(id: $id, babyId: $babyId, milestoneId: $milestoneId, completedDate: $completedDate)';
  }
}

/// 里程碑统计信息
class MilestoneStats {
  final int totalCount;
  final int completedCount;
  final int inProgressCount;
  final int pendingCount;

  const MilestoneStats({
    required this.totalCount,
    required this.completedCount,
    required this.inProgressCount,
    required this.pendingCount,
  });

  /// 完成百分比
  double get completionRate {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  /// 完成百分比（整数）
  int get completionPercentage {
    return (completionRate * 100).round();
  }

  @override
  String toString() {
    return 'MilestoneStats(total: $totalCount, completed: $completedCount, inProgress: $inProgressCount, pending: $pendingCount)';
  }
}
