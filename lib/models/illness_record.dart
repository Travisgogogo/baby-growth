class IllnessRecord {
  final int? id;
  final int babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final String symptom;
  final double? temperature;
  final String description;
  final String treatment;

  IllnessRecord({
    this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    required this.symptom,
    this.temperature,
    required this.description,
    required this.treatment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'symptom': symptom,
      'temperature': temperature,
      'description': description,
      'treatment': treatment,
    };
  }

  factory IllnessRecord.fromMap(Map<String, dynamic> map) {
    return IllnessRecord(
      id: map['id'],
      babyId: map['babyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      symptom: map['symptom'],
      temperature: map['temperature'],
      description: map['description'],
      treatment: map['treatment'],
    );
  }

  IllnessRecord copyWith({
    int? id,
    int? babyId,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEndTime = false,
    String? symptom,
    double? temperature,
    String? description,
    String? treatment,
  }) {
    return IllnessRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      symptom: symptom ?? this.symptom,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      treatment: treatment ?? this.treatment,
    );
  }

  String get duration {
    final end = endTime ?? DateTime.now();
    final diff = end.difference(startTime);
    if (diff.inDays > 0) return '${diff.inDays}天';
    if (diff.inHours > 0) return '${diff.inHours}小时';
    return '${diff.inMinutes}分钟';
  }

  bool get isOngoing => endTime == null;
}
