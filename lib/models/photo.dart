class Photo {
  final int? id;
  final int babyId;
  final String path;
  final DateTime takenAt;
  final String? description;

  Photo({
    this.id,
    required this.babyId,
    required this.path,
    required this.takenAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'path': path,
      'takenAt': takenAt.toIso8601String(),
      'description': description,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      babyId: map['babyId'],
      path: map['path'],
      takenAt: DateTime.parse(map['takenAt']),
      description: map['description'],
    );
  }

  Photo copyWith({
    int? id,
    int? babyId,
    String? path,
    DateTime? takenAt,
    String? description,
  }) {
    return Photo(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      path: path ?? this.path,
      takenAt: takenAt ?? this.takenAt,
      description: description ?? this.description,
    );
  }
}
