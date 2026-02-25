class DiaperRecord {
  final int? id;
  final int babyId;
  final DateTime time;
  final String type;
  final String? condition;
  final String? note;

  DiaperRecord({
    this.id,
    required this.babyId,
    required this.time,
    required this.type,
    this.condition,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'time': time.toIso8601String(),
      'type': type,
      'condition': condition,
      'note': note,
    };
  }

  factory DiaperRecord.fromMap(Map<String, dynamic> map) {
    return DiaperRecord(
      id: map['id'],
      babyId: map['babyId'],
      time: DateTime.parse(map['time']),
      type: map['type'],
      condition: map['condition'],
      note: map['note'],
    );
  }

  DiaperRecord copyWith({
    int? id,
    int? babyId,
    DateTime? time,
    String? type,
    String? condition,
    String? note,
  }) {
    return DiaperRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      time: time ?? this.time,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      note: note ?? this.note,
    );
  }
}
