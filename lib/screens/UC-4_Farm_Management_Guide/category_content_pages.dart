import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContentPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const ContentPageScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.house),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: body,
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentPageScaffold(
      title: "History",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Farming in the Kingdom", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
            "Agriculture in the Kingdom has transformed from traditional oasis farming to modern, high-tech agricultural enterprises.",
            style: TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class CropsPage extends StatelessWidget {
  const CropsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentPageScaffold(
      title: "Crops",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Major Crops", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
            "The Kingdom produces a variety of crops suitable for arid climates.",
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class WaterResourcesPage extends StatelessWidget {
  const WaterResourcesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentPageScaffold(
      title: "Water Resources",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Water Management", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          WaterInfoCard(title: "Groundwater", description: "Used for large-scale wheat and forage production."),
          WaterInfoCard(title: "Treated Wastewater", description: "Used for irrigation and industrial crops."),
          WaterInfoCard(title: "Desalinated Water", description: "Primarily for urban use, with some hydroponic farming."),
        ],
      ),
    );
  }
}

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentPageScaffold(
      title: "Management Tips",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Farm Operations", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(
            "Successful farming requires balancing agronomy with business management.",
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ContentPageScaffold(
      title: "FAQ",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Common Questions", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WaterInfoCard extends StatelessWidget {
  final String title;
  final String description;
  const WaterInfoCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CupertinoColors.systemBlue)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }
}
