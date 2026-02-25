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
}
