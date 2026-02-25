import 'package:cloud_firestore/cloud_firestore.dart';

class CropMaster {
  final String cropId;
  final String name;
  final int defaultHarvestDays;
  final String categoryId;

  CropMaster({
    required this.cropId,
    required this.name,
    required this.defaultHarvestDays,
    required this.categoryId,
  });

  factory CropMaster.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropMaster(
      cropId: data['cropId'] ?? '',
      name: data['name'] ?? 'Unnamed Crop',
      defaultHarvestDays: data['defaultHarvestDays'] ?? 0,
      categoryId: data['categoryId'] ?? '',
    );
  }
}