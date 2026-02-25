class SleepRecord {
  final int? id;
  final int babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? quality;
  final String? note;

  SleepRecord({
    this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    this.quality,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality,
      'note': note,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'],
      babyId: map['babyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      quality: map['quality'],
      note: map['note'],
    );
  }

  SleepRecord copyWith({
    int? id,
    int? babyId,
    DateTime? startTime,
    DateTime? endTime,
    String? quality,
    String? note,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      note: note ?? this.note,
    );
  }
}
