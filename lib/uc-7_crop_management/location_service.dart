// location_service.dart
import 'package:geolocator/geolocator.dart';

/// ===============================
/// Service to get current device location
/// ===============================
class LocationService {
  /// This function returns the current location of the device
  /// as a [Position] object from Geolocator.
  /// It handles:
  ///   - Checking if location services are enabled
  ///   - Requesting permissions if not granted
  ///   - Throwing exceptions if permission denied
  static Future<Position> getCurrentLocation() async {
    // 1️⃣ التأكد أن خدمة الموقع مفعلة على الجهاز
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled on this device.');
    }

    // 2️⃣ التحقق من صلاحيات الوصول للموقع
    LocationPermission permission = await Geolocator.checkPermission();

    // لو الصلاحية مرفوضة، نطلب من المستخدم السماح
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied. Please allow access.',
        );
      }
    }

    // لو تم رفض الصلاحية بشكل دائم
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable it from settings.',
      );
    }

    // 3️⃣ الحصول على الموقع الحالي بدقة عالية
    // هذا الموقع يمكن استخدامه مباشرة لتحديد المزرعة أو عرض المستخدم على الخريطة
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ===============================
  /// Optional helper to get LatLng as tuple
  /// ===============================
  static Future<Map<String, double>> getLatLng() async {
    final position = await getCurrentLocation();
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}