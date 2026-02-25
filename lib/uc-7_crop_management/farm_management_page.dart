import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'crop_model.dart';
import 'crop_service.dart';

class FarmManagementPage extends StatefulWidget {
  const FarmManagementPage({super.key});

  @override
  State<FarmManagementPage> createState() => _FarmManagementPageState();
}

class _FarmManagementPageState extends State<FarmManagementPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CropService _cropService = CropService();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Farm',
            onPressed: () => _showAddFarmDialog(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('user_farm_info').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final farmData = snapshot.data!.data() as Map<String, dynamic>?;

          if (farmData == null) {
            return Center(
              child: Text(
                'No farm found. Tap + to add your first farm.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // معلومات المزرعة
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmData['farmName'] ?? 'Unnamed Farm',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Farm Size: ${farmData['farmSize'] ?? 0} m²'),
                      Text(
                          'Active Crops: ${farmData['activeCropsCount'] ?? 0}'),
                      Text(
                          'Finished Crops: ${farmData['finishedCropsCount'] ?? 0}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showEditFarmDialog(farmData),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Farm'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _deleteFarm(),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Farm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // المحاصيل الحالية
              const Text(
                'Current Crops',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<CropModel>>(
                stream: _cropService.getUserCrops(user.uid),
                builder: (context, cropSnapshot) {
                  if (!cropSnapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final crops = cropSnapshot.data!
                      .where((c) => c.status == 'active')
                      .toList();

                  if (crops.isEmpty) {
                    return const Text('No active crops.');
                  }

                  return Column(
                    children: crops
                        .map(
                          (crop) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(crop.name),
                          subtitle: Text(
                              'Planting: ${crop.plantingDate}\nHarvest: ${crop.harvestDate}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteCrop(crop.id),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // زر إضافة محصول
              ElevatedButton.icon(
                onPressed: () => _showAddCropDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Crop'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ===============================
  /// إضافة مزرعة جديدة
  /// ===============================
  void _showAddFarmDialog() {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Farm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
            ),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: 'Farm Size (m²)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final size = int.tryParse(sizeController.text) ?? 0;
              if (name.isNotEmpty && size > 0) {
                await _db.collection('user_farm_info').doc(user.uid).set({
                  'farmName': name,
                  'farmSize': size,
                  'activeCropsCount': 0,
                  'finishedCropsCount': 0,
                  'totalCropsPlanted': 0,
                  'isFarmActive': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// تعديل بيانات المزرعة
  /// ===============================
  void _showEditFarmDialog(Map<String, dynamic> farmData) {
    final nameController = TextEditingController(text: farmData['farmName']);
    final sizeController =
    TextEditingController(text: farmData['farmSize'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Farm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
            ),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: 'Farm Size (m²)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final size = int.tryParse(sizeController.text) ?? 0;
              if (name.isNotEmpty && size > 0) {
                await _db.collection('user_farm_info').doc(user.uid).update({
                  'farmName': name,
                  'farmSize': size,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// حذف المزرعة بالكامل
  /// ===============================
  Future<void> _deleteFarm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this farm?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm ?? false) {
      await _db.collection('user_farm_info').doc(user.uid).delete();
    }
  }

  /// ===============================
  /// حذف محصول
  /// ===============================
  Future<void> _deleteCrop(String cropId) async {
    await _db
        .collection('user_crops')
        .doc(user.uid)
        .collection('crops')
        .doc(cropId)
        .delete();
  }

  /// ===============================
  /// إضافة محصول جديد
  /// ===============================
  void _showAddCropDialog() {
    final nameController = TextEditingController();
    final harvestController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Crop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Crop Name'),
            ),
            TextField(
              controller: harvestController,
              decoration:
              const InputDecoration(labelText: 'Expected Harvest Days'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final harvestDays = int.tryParse(harvestController.text) ?? 0;
              final lat = double.tryParse(latController.text) ?? 0;
              final lng = double.tryParse(lngController.text) ?? 0;

              if (name.isNotEmpty && harvestDays > 0) {
                await _db
                    .collection('user_crops')
                    .doc(user.uid)
                    .collection('crops')
                    .add({
                  'cropName': name,
                  'expectedHarvestDays': harvestDays,
                  'plantingDate': FieldValue.serverTimestamp(),
                  'locationLat': lat,
                  'locationLng': lng,
                  'status': 'active',
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}