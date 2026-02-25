import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_model.dart';

class CropService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ================================
  /// جلب مزروعات المستخدم مع خيارات الفلترة
  /// ================================
  Stream<List<CropModel>> getUserCrops(
      String uid, {
        String? farmId,
        bool onlyActive = false,
      }) {
    Query ref = _db.collection('user_crops').doc(uid).collection('crops');

    if (farmId != null) {
      ref = ref.where('farmId', isEqualTo: farmId);
    }

    if (onlyActive) {
      ref = ref.where('status', isEqualTo: 'active');
    }

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CropModel.fromFirestore(doc)).toList();
    });
  }

  /// ================================
  /// اقتراح حالة الحصاد
  /// ================================
  String calculateStatus(CropModel crop) {
    final now = DateTime.now();
    final diff = crop.harvestDate.difference(now).inDays;

    if (diff <= 0) return 'Ready';
    if (diff <= 7) return 'Approaching';
    return 'Growing';
  }
}