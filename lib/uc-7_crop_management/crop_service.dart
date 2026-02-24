import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_model.dart';

class CropService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ================================
  /// جلب مزروعات المستخدم
  /// ================================
  Stream<List<CropModel>> getUserCrops(String uid) {
    return _db
        .collection('user_crops')
        .doc(uid)
        .collection('crops')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CropModel.fromFirestore(doc))
          .toList();
    });
  }

  /// ================================
  /// اقتراح حالة الحصاد
  /// ================================
  String getHarvestSuggestion(CropModel crop) {
    final int daysLeft =
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