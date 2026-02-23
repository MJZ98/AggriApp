import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'crop_service.dart';
import 'crop_printer.dart';
import 'crop_model.dart';

class CropManagementPage extends StatelessWidget {
  final CropService service = CropService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Management'),
      ),
      body: StreamBuilder<List<CropModel>>(
        stream: service.getUserCrops(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('No Data'));
          }

          final crops = snapshot.data!;
          if (crops.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final suggestion = service.getHarvestSuggestion(crop);

              return Card(
                margin: EdgeInsets.all(12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop.name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Planting: ${crop.plantingDate}'),
                      Text('Harvest: ${crop.harvestDate}'),
                      SizedBox(height: 8),
                      Text('Suggestion: $suggestion'),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.print),
                          label: Text('Print'),
                          onPressed: () async {
                            try {
                              await CropPrinter.printCrop(crop);
                            } catch (_) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Error'),
                                  content:
                                  Text('No printer connected'),
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
}