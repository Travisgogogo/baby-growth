class Reminder {
  final int? id;
  final int babyId;
  final String title;
  final String? description;
  final DateTime time;
  final bool isEnabled;
  final bool isRepeating;
  final List<int>? repeatDays; // 0=周日, 1=周一...
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.babyId,
    required this.title,
    this.description,
    required this.time,
    this.isEnabled = true,
    this.isRepeating = false,
    this.repeatDays,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'isEnabled': isEnabled ? 1 : 0,
      'isRepeating': isRepeating ? 1 : 0,
      'repeatDays': repeatDays?.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      babyId: map['babyId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      time: DateTime.parse(map['time'] as String),
      isEnabled: map['isEnabled'] == 1,
      isRepeating: map['isRepeating'] == 1,
      repeatDays: map['repeatDays'] != null
          ? (map['repeatDays'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Reminder copyWith({
    int? id,
    int? babyId,
    String? title,
    String? description,
    DateTime? time,
    bool? isEnabled,
    bool? isRepeating,
    List<int>? repeatDays,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeDisplay {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get repeatDisplay {
    if (!isRepeating || repeatDays == null || repeatDays!.isEmpty) {
      return '仅一次';
    }
    final dayNames = ['日', '一', '二', '三', '四', '五', '六'];
    if (repeatDays!.length == 7) {
      return '每天';
    }
    if (repeatDays!.length == 5 && 
        repeatDays!.contains(1) && 
        repeatDays!.contains(2) && 
        repeatDays!.contains(3) && 
        repeatDays!.contains(4) && 
        repeatDays!.contains(5)) {
      return '工作日';
    }
    final days = repeatDays!.map((d) => '周${dayNames[d]}').join('、');
    return days;
  }
}
