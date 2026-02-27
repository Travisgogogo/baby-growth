class FeedRecord {
  final int? id;
  final int babyId;
  final DateTime time;
  final String type; // breast, formula, solid
  final double? amount; // ml or grams
  final int? duration; // minutes for breastfeeding
  final String? note;

  FeedRecord({
    this.id,
    required this.babyId,
    required this.time,
    required this.type,
    this.amount,
    this.duration,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'time': time.toIso8601String(),
      'type': type,
      'amount': amount,
      'duration': duration,
      'note': note,
    };
  }

  factory FeedRecord.fromMap(Map<String, dynamic> map) {
    return FeedRecord(
      id: map['id'],
      babyId: map['babyId'],
      time: DateTime.parse(map['time']),
      type: map['type'],
      amount: map['amount'],
      duration: map['duration'],
      note: map['note'],
    );
  }

  String get typeDisplay {
    switch (type) {
      case 'breast':
      case '母乳':
        return '母乳';
      case 'formula':
      case '奶粉':
        return '配方奶';
      case 'solid':
      case '辅食':
        return '辅食';
      default:
        return type; // 直接返回原始值，而不是"其他"
    }
  }

  String get amountDisplay {
    if (amount == null) return '';
    if (type == 'solid') return '${amount!.toInt()}g';
    return '${amount!.toInt()}ml';
  }

  FeedRecord copyWith({
    int? id,
    int? babyId,
    DateTime? time,
    String? type,
    double? amount,
    int? duration,
    String? note,
  }) {
    return FeedRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      time: time ?? this.time,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      duration: duration ?? this.duration,
      note: note ?? this.note,
    );
  }
}