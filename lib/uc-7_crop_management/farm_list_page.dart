import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farm_detail_page.dart'; // استدعاء صفحة تفاصيل المزرعة

class FarmListPage extends StatefulWidget {
  const FarmListPage({super.key});

  @override
  State<FarmListPage> createState() => _FarmListPageState();
}

class _FarmListPageState extends State<FarmListPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Farm',
            onPressed: _showAddFarmDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('user_farm_info')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final farms = snapshot.data!.docs;

          if (farms.isEmpty) {
            return const Center(child: Text('No farms yet. Tap + to add one.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FarmDetailPage(
                        farmId: farm.id,
                        farmName: farm['farmName'],
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          farm['farmName'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ==== إضافة مزرعة جديدة ====
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
                await _db.collection('user_farm_info').add({
                  'userId': user.uid,
                  'farmName': name,
                  'farmSize': size,
                  'createdAt': FieldValue.serverTimestamp(),
                  'activeCropsCount': 0,
                  'finishedCropsCount': 0,
                  'totalCropsPlanted': 0,
                  'isFarmActive': true,
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