class Baby {
   final int? id;
   final String name;
   final DateTime birthDate;
   final String gender;
   final double? birthWeight;
   final double? birthHeight;
   final double? birthHeadCircumference;
   final String? avatarPath; // 宝宝头像路径

   Baby({
     this.id,
     required this.name,
     required this.birthDate,
     required this.gender,
     this.birthWeight,
     this.birthHeight,
     this.birthHeadCircumference,
     this.avatarPath,
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
     );
   }
 }
