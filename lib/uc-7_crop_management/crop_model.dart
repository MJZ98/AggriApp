import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String id;
  final String name;
  final DateTime plantingDate;
  final int harvestDays;
  final double lat;
  final double lng;

  CropModel({
    required this.id,
    required this.name,
    required this.plantingDate,
    required this.harvestDays,
    required this.lat,
    required this.lng,
  });

  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropModel(
      id: doc.id,
      name: data['cropName'],
      plantingDate: (data['plantingDate'] as Timestamp).toDate(),
      harvestDays: data['expectedHarvestDays'],
      lat: data['latitude'],
      lng: data['longitude'],
    );
  }

  DateTime get harvestDate =>
      plantingDate.add(Duration(days: harvestDays));
}