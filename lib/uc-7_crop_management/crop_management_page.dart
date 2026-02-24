import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'crop_service.dart';
import 'crop_printer.dart' as printer;
import 'crop_model.dart' as model;
import 'package:intl/intl.dart';

class CropManagementPage extends StatelessWidget {
  final CropService service = CropService();

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Management'),
      ),
      body: StreamBuilder<List<model.CropModel>>(
        stream: service.getUserCrops(user.uid), // المسار مضبوط الآن
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data'));
          }

          final crops = snapshot.data!;

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final suggestion = service.getHarvestSuggestion(crop);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Planting: ${formatDate(crop.plantingDate)}'),
                          Text('Harvest: ${formatDate(crop.harvestDate)}'),
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
                          onPressed: () async {
                            try {
                              await printer.CropPrinter.printCrop(crop);
                            } catch (_) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('No printer connected'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
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
}