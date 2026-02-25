import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'crop_service.dart';
import 'crop_model.dart';
import 'crop_printer.dart' as printer;
import 'farm_management_page.dart';

class CropManagementPage extends StatefulWidget {
  const CropManagementPage({super.key});

  @override
  State<CropManagementPage> createState() => _CropManagementPageState();
}

class _CropManagementPageState extends State<CropManagementPage> {
  final CropService service = CropService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.agriculture),
            tooltip: 'Farm Management',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FarmManagementPage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: _showAddCropDialog,
      ),
      body: StreamBuilder<List<CropModel>>(
        stream: service.getUserCrops(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No crops yet\nTap + to add your first crop',
                textAlign: TextAlign.center,
              ),
            );
          }

          final crops = snapshot.data!;

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final suggestion = service.getHarvestSuggestion(crop);

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Planting: ${formatDate(crop.plantingDate)}'),
                          Text(
                              'Harvest: ${formatDate(crop.harvestDate)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: $suggestion',
                        style: TextStyle(
                          color: suggestion.contains('Ready')
                              ? Colors.green
                              : suggestion.contains('approaching')
                              ? Colors.orange
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text('Print'),
                          onPressed: () async {
                            try {
                              await printer.CropPrinter.printCrop(crop);
                            } catch (_) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'No printer connected'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
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

  /// ===============================
  /// Add Crop Dialog (كامل)
  /// ===============================
  Future<void> _showAddCropDialog() async {
    String? selectedCropId;
    DateTime plantingDate = DateTime.now();
    LatLng selectedLocation =
    const LatLng(24.7136, 46.6753);

    final cropsMasterSnap =
    await _db.collection('crops_master').get();

    final cropsMaster = cropsMasterSnap.docs;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          int harvestDays = 0;

          if (selectedCropId != null) {
            final selected = cropsMaster.firstWhere(
                    (e) => e['cropId'] == selectedCropId);
            harvestDays = selected['defaultHarvestDays'];
          }

          DateTime harvestDate =
          plantingDate.add(Duration(days: harvestDays));

          return AlertDialog(
            title: const Text('Add Crop'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    hint: const Text('Select Crop'),
                    value: selectedCropId,
                    items: cropsMaster.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['cropId'],
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCropId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Planting Date: ${formatDate(plantingDate)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: plantingDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              plantingDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Expected Harvest: ${formatDate(harvestDate)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Location: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: () async {
                          final result =
                          await Navigator.push<LatLng>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _MapPickerPage(
                                initialLocation:
                                selectedLocation,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              selectedLocation = result;
                            });
                          }
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
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: selectedCropId == null
                    ? null
                    : () async {
                  final selected =
                  cropsMaster.firstWhere(
                          (e) =>
                      e['cropId'] ==
                          selectedCropId);

                  await _db
                      .collection('user_crops')
                      .doc(user.uid)
                      .collection('crops')
                      .add({
                    'cropName': selected['name'],
                    'cropMasterId': selected['cropId'],
                    'plantingDate':
                    Timestamp.fromDate(plantingDate),
                    'harvestDate':
                    Timestamp.fromDate(harvestDate),
                    'locationLat':
                    selectedLocation.latitude,
                    'locationLng':
                    selectedLocation.longitude,
                    'status': 'active',
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ===============================
/// Map Picker Page
/// ===============================
class _MapPickerPage extends StatefulWidget {
  final LatLng initialLocation;

  const _MapPickerPage({required this.initialLocation});

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  late LatLng selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selected);
            },
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selected,
          zoom: 15,
        ),
        onTap: (latLng) {
          setState(() {
            selected = latLng;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('m1'),
            position: selected,
          )
        },
      ),
    );
  }
}