class VaccineRecord {
  final int? id;
  final int babyId;
  final String vaccineId;
  final String name;
  final String scheduledTime;
  bool completed;
  DateTime? completedDate;

  VaccineRecord({
    this.id,
    required this.babyId,
    required this.vaccineId,
    required this.name,
    required this.scheduledTime,
    this.completed = false,
    this.completedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'vaccineId': vaccineId,
      'name': name,
      'scheduledTime': scheduledTime,
      'completed': completed ? 1 : 0,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory VaccineRecord.fromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'],
      babyId: map['babyId'],
      vaccineId: map['vaccineId'],
      name: map['name'],
      scheduledTime: map['scheduledTime'],
      completed: map['completed'] == 1,
      completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate']) : null,
    );
  }

  VaccineRecord copyWith({
    int? id,
    int? babyId,
    String? vaccineId,
    String? name,
    String? scheduledTime,
    bool? completed,
    DateTime? completedDate,
  }) {
    return VaccineRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      vaccineId: vaccineId ?? this.vaccineId,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completed: completed ?? this.completed,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}
