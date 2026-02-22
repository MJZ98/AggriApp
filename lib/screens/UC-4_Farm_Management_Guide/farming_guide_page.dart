import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FarmingGuidePage extends StatefulWidget {
  const FarmingGuidePage({super.key});

  @override
  State<FarmingGuidePage> createState() => _FarmingGuidePageState();
}

class _FarmingGuidePageState extends State<FarmingGuidePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {"title": "Agriculture History", "icon": CupertinoIcons.time, "route": "/history"},
    {"title": "Crops", "icon": CupertinoIcons.leaf_arrow_circlepath, "route": "/crops"},
    {"title": "Water Resources", "icon": CupertinoIcons.drop_fill, "route": "/water"},
    {"title": "Farm Management", "icon": CupertinoIcons.briefcase_fill, "route": "/management"},
    {"title": "FAQ", "icon": CupertinoIcons.question_circle_fill, "route": "/faq"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter categories based on search query
    final filteredCategories = _categories.where((cat) {
      return cat['title'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Farming Guide"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.house_fill),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: "Search topics...",
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 10),

          // Filtered category list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: filteredCategories.map((cat) {
                return _buildCategoryCard(
                  context,
                  title: cat['title'],
                  icon: cat['icon'],
                  route: cat['route'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context,
      {required String title, required IconData icon, required String route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: CupertinoColors.systemGreen, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        trailing: const Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 20),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
