import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'crop_service.dart';
import 'crop_model.dart';
import 'crop_printer.dart' as printer;
import 'map_picker_page.dart';

class FarmDetailPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const FarmDetailPage({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<FarmDetailPage> createState() => _FarmDetailPageState();
}

class _FarmDetailPageState extends State<FarmDetailPage> {
  final _db = FirebaseFirestore.instance;
  final _cropService = CropService();
  final user = FirebaseAuth.instance.currentUser!;

  String _format(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // ===== ألوان الحالة =====
  Color _statusColor(String status) {
    if (status == 'Ready') return Colors.green.shade300;
    if (status == 'Approaching') return Colors.orange.shade300;
    return Colors.blue.shade200;
  }

  IconData _statusIcon(String status) {
    if (status == 'Ready') return Icons.check_circle;
    if (status == 'Approaching') return Icons.timelapse;
    return Icons.spa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.farmName)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: _showAddCropDialog,
      ),
      body: StreamBuilder<List<CropModel>>(
        stream: _cropService.getUserCrops(
          user.uid,
          farmId: widget.farmId,
          onlyActive: true,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final crops = snapshot.data!;
          if (crops.isEmpty) {
            return const Center(child: Text('No active crops'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final status = _cropService.calculateStatus(crop);

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_statusIcon(status),
                              color: _statusColor(status)),
                          const SizedBox(width: 8),
                          Text(
                            crop.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            backgroundColor: _statusColor(status),
                            label: Text(status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Planting Date: ${_format(crop.plantingDate)}'),
                      Text('Harvest Date: ${_format(crop.harvestDate)}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print),
                            onPressed: () async {
                              try {
                                await printer.CropPrinter.printCrop(crop);
                              } catch (_) {
                                _showError('No printer connected');
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditCropDialog(crop),
                          ),
                          IconButton(
                            icon: const Icon(Icons.flag, color: Colors.green),
                            tooltip: 'Mark as Finished',
                            onPressed: () => _finishCrop(crop.id),
                          ),
                          IconButton(
                            icon:
                            const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCrop(crop.id),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===== إنهاء محصول =====
  Future<void> _finishCrop(String id) async {
    await _db
        .collection('user_crops')
        .doc(user.uid)
        .collection('crops')
        .doc(id)
        .update({'status': 'finished'});
  }

  // ===== حذف =====
  Future<void> _deleteCrop(String id) async {
    await _db
        .collection('user_crops')
        .doc(user.uid)
        .collection('crops')
        .doc(id)
        .delete();
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // ===== إضافة =====
  Future<void> _showAddCropDialog() async {
    _showCropDialog();
  }

  // ===== تعديل =====
  Future<void> _showEditCropDialog(CropModel crop) async {
    _showCropDialog(editCrop: crop);
  }

  // ===== Dialog موحد =====
  Future<void> _showCropDialog({CropModel? editCrop}) async {
    String? cropId = editCrop?.cropMasterId;
    DateTime plantingDate = editCrop?.plantingDate ?? DateTime.now();
    LatLng location = LatLng(
      editCrop?.locationLat ?? 24.7136,
      editCrop?.locationLng ?? 46.6753,
    );

    final cropsMaster =
    await _db.collection('crops_master').get();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          int harvestDays = 0;

          if (cropId != null) {
            final c = cropsMaster.docs
                .firstWhere((e) => e['cropId'] == cropId);
            harvestDays = c['defaultHarvestDays'];
          }

          final harvestDate =
          plantingDate.add(Duration(days: harvestDays));

          return AlertDialog(
            title: Text(editCrop == null ? 'Add Crop' : 'Edit Crop'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: cropId,
                    hint: const Text('Select Crop'),
                    items: cropsMaster.docs
                        .map(
                          (e) => DropdownMenuItem<String>(
                        value: e['cropId'] as String,
                        child: Text(e['name'] as String),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() => cropId = v),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Planting: ${_format(plantingDate)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: plantingDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setState(() => plantingDate = d);
                          }
                        },
                      ),
                    ],
                  ),
                  Text('Harvest: ${_format(harvestDate)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Location: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: () async {
                          final r = await Navigator.push<LatLng>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapPickerPage(
                                  initialLocation: location),
                            ),
                          );
                          if (r != null) setState(() => location = r);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: cropId == null
                    ? null
                    : () async {
                  final selected = cropsMaster.docs
                      .firstWhere(
                          (e) => e['cropId'] == cropId);

                  final data = {
                    'farmId': widget.farmId,
                    'cropName': selected['name'],
                    'cropMasterId': cropId,
                    'plantingDate':
                    Timestamp.fromDate(plantingDate),
                    'harvestDate':
                    Timestamp.fromDate(harvestDate),
                    'locationLat': location.latitude,
                    'locationLng': location.longitude,
                    'status': 'active',
                  };

                  final ref = _db
                      .collection('user_crops')
                      .doc(user.uid)
                      .collection('crops');

                  if (editCrop == null) {
                    await ref.add(data);
                  } else {
                    await ref
                        .doc(editCrop.id)
                        .update(data);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}