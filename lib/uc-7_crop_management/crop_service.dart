import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_model.dart';

class CropService {
  final _db = FirebaseFirestore.instance;

  Stream<List<CropModel>> getUserCrops(String userId) {
    return _db
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((e) => CropModel.fromFirestore(e)).toList());
  }

  String getHarvestSuggestion(CropModel crop) {
    final daysLeft =
        crop.harvestDate.difference(DateTime.now()).inDays;

    if (daysLeft <= 0) {
      return 'Ready to harvest now';
    } else if (daysLeft <= 7) {
      return 'Harvest approaching soon';
    } else {
      return 'Crop growing normally';
    }
  }
}