class Baby {
  final int? id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final double? birthWeight;
  final double? birthHeight;
  final double? birthHeadCircumference;
  final String? avatarPath;
  
  // 新增字段
  final DateTime? birthTime; // 出生时间
  final String? birthPlace; // 出生地点/医院
  final String? gestationalAge; // 胎龄，如 "39周2天"
  final String? deliveryMode; // 分娩方式：顺产/剖腹产/产钳等
  final String? bloodType; // 血型
  final String? birthPhotoPath; // 出生照片
  final String? handprintPath; // 手印照片
  final String? footprintPath; // 脚印照片

  Baby({
    this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.birthWeight,
    this.birthHeight,
    this.birthHeadCircumference,
    this.avatarPath,
    this.birthTime,
    this.birthPlace,
    this.gestationalAge,
    this.deliveryMode,
    this.bloodType,
    this.birthPhotoPath,
    this.handprintPath,
    this.footprintPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'birthHeadCircumference': birthHeadCircumference,
      'avatarPath': avatarPath,
      'birthTime': birthTime?.toIso8601String(),
      'birthPlace': birthPlace,
      'gestationalAge': gestationalAge,
      'deliveryMode': deliveryMode,
      'bloodType': bloodType,
      'birthPhotoPath': birthPhotoPath,
      'handprintPath': handprintPath,
      'footprintPath': footprintPath,
    };
  }

  factory Baby.fromMap(Map<String, dynamic> map) {
    return Baby(
      id: map['id'],
      name: map['name'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
      birthWeight: map['birthWeight'],
      birthHeight: map['birthHeight'],
      birthHeadCircumference: map['birthHeadCircumference'],
      avatarPath: map['avatarPath'],
      birthTime: map['birthTime'] != null ? DateTime.parse(map['birthTime']) : null,
      birthPlace: map['birthPlace'],
      gestationalAge: map['gestationalAge'],
      deliveryMode: map['deliveryMode'],
      bloodType: map['bloodType'],
      birthPhotoPath: map['birthPhotoPath'],
      handprintPath: map['handprintPath'],
      footprintPath: map['footprintPath'],
    );
  }

  int get ageInDays {
    return DateTime.now().difference(birthDate).inDays;
  }

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  String get ageDisplay {
    final days = ageInDays;
    if (days < 30) return '$days天';
    final months = days ~/ 30;
    if (months < 12) return '$months个月${days % 30}天';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    return '$years岁$remainingMonths个月';
  }

  Baby copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? avatarPath,
    DateTime? birthTime,
    bool clearBirthTime = false,
    String? birthPlace,
    bool clearBirthPlace = false,
    String? gestationalAge,
    bool clearGestationalAge = false,
    String? deliveryMode,
    bool clearDeliveryMode = false,
    String? bloodType,
    bool clearBloodType = false,
    String? birthPhotoPath,
    bool clearBirthPhotoPath = false,
    String? handprintPath,
    bool clearHandprintPath = false,
    String? footprintPath,
    bool clearFootprintPath = false,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      birthHeadCircumference: birthHeadCircumference ?? this.birthHeadCircumference,
      avatarPath: avatarPath ?? this.avatarPath,
      birthTime: clearBirthTime ? null : (birthTime ?? this.birthTime),
      birthPlace: clearBirthPlace ? null : (birthPlace ?? this.birthPlace),
      gestationalAge: clearGestationalAge ? null : (gestationalAge ?? this.gestationalAge),
      deliveryMode: clearDeliveryMode ? null : (deliveryMode ?? this.deliveryMode),
      bloodType: clearBloodType ? null : (bloodType ?? this.bloodType),
      birthPhotoPath: clearBirthPhotoPath ? null : (birthPhotoPath ?? this.birthPhotoPath),
      handprintPath: clearHandprintPath ? null : (handprintPath ?? this.handprintPath),
      footprintPath: clearFootprintPath ? null : (footprintPath ?? this.footprintPath),
    );
  }
}
