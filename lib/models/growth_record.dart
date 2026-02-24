class GrowthRecord {
   final int? id;
   final int babyId;
   final DateTime date;
   final double? weight;
   final double? height;
   final double? headCircumference;
   final String? note;

   GrowthRecord({
     this.id,
     required this.babyId,
     required this.date,
     this.weight,
     this.height,
     this.headCircumference,
     this.note,
   });

   Map<String, dynamic> toMap() {
     return {
       'id': id,
       'babyId': babyId,
       'date': date.toIso8601String(),
       'weight': weight,
       'height': height,
       'headCircumference': headCircumference,
       'note': note,
     };
   }

   factory GrowthRecord.fromMap(Map<String, dynamic> map) {
     return GrowthRecord(
       id: map['id'],
       babyId: map['babyId'],
       date: DateTime.parse(map['date']),
       weight: map['weight'],
       height: map['height'],
       headCircumference: map['headCircumference'],
       note: map['note'],
     );
   }
 }