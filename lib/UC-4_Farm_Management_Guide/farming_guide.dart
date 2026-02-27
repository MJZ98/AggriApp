import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agricultural Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS System Grey 6
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: CupertinoColors.systemGreen),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
          ),
        ),
      ),
      initialRoute: '/',

    );
  }


// Farming Page Code Start here

class FarmingGuidePage extends StatelessWidget {
  const FarmingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farming Guide"),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CupertinoSearchTextField(
              placeholder: "Search topics...",
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryCard(context, title: "Agriculture History", icon: CupertinoIcons.time, route: '/history'),
                _buildCategoryCard(context, title: "Crops", icon: CupertinoIcons.leaf_arrow_circlepath, route: '/crops'),
                _buildCategoryCard(context, title: "Water Resources", icon: CupertinoIcons.drop_fill, route: '/water'),
                _buildCategoryCard(context, title: "Farm Management", icon: CupertinoIcons.briefcase_fill, route: '/management'),
                _buildCategoryCard(context, title: "FAQ", icon: CupertinoIcons.question_circle_fill, route: '/faq'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required String title, required IconData icon, required String route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
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
            color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: CupertinoColors.systemGreen, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        trailing: const Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 20),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

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
          IconButton(icon: const Icon(CupertinoIcons.house), onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false)),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: body)),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background
      appBar: AppBar(
        title: const Text("Agricultural History"),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO SECTION
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: .3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From Oases to\nSmart Farming",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Discover how Saudi Arabia transformed its desert into a food basket through determination and technology.",
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. TIMELINE SECTION
            const Text(
              "Historical Timeline",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildTimelineItem(
              year: "1940s",
              title: "Traditional Beginnings",
              desc: "Agriculture was limited to self-sufficient oases (Al-Ahsa, Qatif) and Bedouin livestock. Dates were the primary crop.",
              icon: Icons.landscape,
              color: Colors.brown,
            ),
            _buildTimelineItem(
              year: "1980s",
              title: "The Wheat Boom",
              desc: "The government introduced massive subsidies. Pivot irrigation turned the desert green. By 1984, Saudi Arabia became self-sufficient in wheat.",
              icon: Icons.grass, // Closest to wheat
              color: Colors.amber,
            ),
            _buildTimelineItem(
              year: "2008",
              title: "The Water Shift",
              desc: "To protect non-renewable groundwater, a decision was made to phase out water-intensive wheat production.",
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            _buildTimelineItem(
              year: "2016",
              title: "Vision 2030 Launch",
              desc: "A new era focusing on sustainable greenhouses, drip irrigation, and high-value crops (fruits, poultry, aquaculture).",
              icon: Icons.rocket_launch,
              color: Colors.green,
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 30),

            // 3. WHEAT PRODUCTION CHART
            const Text(
              "The Wheat Story (in Tons)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Notice the rapid rise in the 90s and the strategic drop to save water.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(height: 20, label: "1970"),
                  _buildBar(height: 180, label: "1990", isPeak: true),
                  _buildBar(height: 120, label: "2000"),
                  _buildBar(height: 40, label: "2015"),
                  _buildBar(height: 60, label: "2024"),
                ],
              ),
            ),
            // Trigger illustrative image search
            const SizedBox(height: 30),

            // 4. VISION 2030 TABLE
            const Text(
              "Vision 2030 Goals",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildTableHeader(),
                _buildTableRow("Water Source", "Deep Groundwater", "Treated Water & Drip"),
                _buildTableRow("Key Crops", "Wheat & Alfalfa", "Dates, Fish, Greenhouse Veg"),
                _buildTableRow("Focus", "Food Security at all costs", "Sustainability & Efficiency"),
                _buildTableRow("Technology", "Basic Machinery", "Drones, AI & Hydroponics"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  year,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double height, required String label, bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: isPeak ? Colors.amber : Colors.green.shade300,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE8F5E9)),
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text("Old Era", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text("Vision 2030", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String feature, String oldVal, String newVal) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feature, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(oldVal, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feature, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(newVal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class CropsPage extends StatelessWidget {
  const CropsPage({super.key});

  final List<Map<String, String>> crops = const [
    {
      "name": "Date Palm (Nakhil)",
      "season": "Year-round",
      "planting": "February - May",
      "harvest": "August - October",
      "icon": "🌴",
      "desc": "The cornerstone of Saudi agriculture. Requires deep watering and regular cleaning."
    },
    {
      "name": "Wheat (Qamh)",
      "season": "Winter",
      "planting": "November - December",
      "harvest": "April - May",
      "icon": "🌾",
      "desc": "Strategic crop. Best grown in pivot irrigation systems in Qassim and Hail."
    },
    {
      "name": "Greenhouse Tomatoes",
      "season": "Controlled Environment",
      "planting": "September - November",
      "harvest": "December - May",
      "icon": "🍅",
      "desc": "High yield in cooled greenhouses. Watch for Tuta Absoluta pest."
    },
    {
      "name": "Alfalfa (Barseem)",
      "season": "Perennial",
      "planting": "October - November",
      "harvest": "Every 30-40 days",
      "icon": "🌿",
      "desc": "Primary fodder crop. Requires significant water; use efficient sprinklers."
    },
    {
      "name": "Citrus (Lemon/Orange)",
      "season": "Winter/Spring",
      "planting": "February - March",
      "harvest": "December - February",
      "icon": "🍋",
      "desc": "Thrives in Najran and Tabuk. Needs protection from frost."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Calendar")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final crop = crops[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(crop['icon']!, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text("Planting: ${crop['planting']}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text("Harvest: ${crop['harvest']}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WaterResourcesPage extends StatelessWidget {
  const WaterResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water Management")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: "Drip Irrigation",
            icon: CupertinoIcons.drop_fill,
            color: Colors.blue,
            content: "The most efficient method for Saudi climate. Delivers water directly to roots, reducing evaporation by up to 60%. Essential for date palms and vegetables.",
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: "Smart Salinity Control",
            icon: CupertinoIcons.lab_flask_solid,
            color: Colors.orange,
            content: "High salinity is a major issue in our soil. Use leaching techniques (flushing soil with fresh water) and plant salt-tolerant crops like Barley or Spinach in affected areas.",
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: "Treated Wastewater (TSE)",
            icon: CupertinoIcons.arrow_2_circlepath,
            color: Colors.green,
            content: "Safe for irrigation of fodder crops and landscape trees. A sustainable alternative to depleting groundwater reserves.",
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Color color, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }
}

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm Management")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Critical Alerts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Red Palm Weevil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text("Inspect palms monthly. Look for oozing brown liquid or chewed fibers.", style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Best Practices", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTip("Soil Preparation", "Always plow deep (30cm) and add organic compost 2 months before planting to improve water retention."),
          _buildTip("Windbreaks", "Plant Tamarix or Conocarpus trees around your farm perimeter to protect crops from sandstorms."),
          _buildTip("Fertilization", "Use NPK 20-20-20 during the growth stage, and switch to high Potassium during fruiting."),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(desc),
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "q": "How often should I water my date palms?",
      "a": "In summer, daily watering is required (100L per tree). In winter, reduce to twice a week."
    },
    {
      "q": "What is the best time to plant vegetables?",
      "a": "For open fields, plant in late September or October to avoid extreme summer heat."
    },
    {
      "q": "How do I fix salty soil?",
      "a": "You must leach the soil by flooding it with fresh water to push salts below the root zone. Adding gypsum also helps."
    },
    {
      "q": "Are there government subsidies for equipment?",
      "a": "Yes, the Agricultural Development Fund (ADF) offers loans for modern irrigation systems and greenhouses."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expert FAQ")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
            ),
            child: ExpansionTile(
              title: Text(
                faqs[index]['q']!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faqs[index]['a']!,
                    style: TextStyle(color: Colors.grey[800], height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}