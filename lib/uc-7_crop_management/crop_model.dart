import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String id;
  final String cropMasterId;       // رابط crops_master
  final String cropCategoryId;     // رابط crops_category
  final String name;               // اسم المحصول
  final DateTime plantingDate;     // تاريخ الزراعة
  final int expectedHarvestDays;   // مدة الحصاد
  final double locationLat;        // خط العرض
  final double locationLng;        // خط الطول
  final String? iconUrl;

  CropModel({
    required this.id,
    required this.cropMasterId,
    required this.cropCategoryId,
    required this.name,
    required this.plantingDate,
    required this.expectedHarvestDays,
    required this.locationLat,
    required this.locationLng,
    this.iconUrl,
  });

  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CropModel(
      id: doc.id,
      cropMasterId: data['cropMasterId'] ?? '',
      cropCategoryId: data['cropCategoryId'] ?? '',
      name: data['cropName'] ?? 'Unnamed Crop',
      plantingDate: data['plantingDate'] is Timestamp
          ? (data['plantingDate'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(data['plantingDate']),
      expectedHarvestDays: data['expectedHarvestDays'] ?? 0,
      locationLat: (data['locationLat'] ?? 0).toDouble(),
      locationLng: (data['locationLng'] ?? 0).toDouble(),
      iconUrl: data['iconUrl'],

    );
  }

  DateTime get harvestDate =>
      plantingDate.add(Duration(days: expectedHarvestDays));

  double get lat => locationLat;
  double get lng => locationLng;
}