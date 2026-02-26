import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  Timer? _debounce;
  final bool isAdmin = true;

  // Static application content for global search
  final List<Map<String, String>> _appFeatures = [
    {'title': 'Farming Guide', 'route': '/guide', 'type': 'Feature'},
    {'title': 'AI Crop Doctor', 'route': '/ai_chat', 'type': 'Feature'},
    {'title': 'Crop Management', 'route': '/crop-management', 'type': 'Feature'},
    {'title': 'Weather Status', 'route': '/weather', 'type': 'Feature'},
    {'title': 'Request Support', 'route': '/request_support', 'type': 'Feature'},
    {'title': 'Give Feedback', 'route': '/feedback', 'type': 'Feature'},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  void _toggleLanguage() {
    if (context.locale.languageCode == 'en') {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AgriGuide".tr()),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(CupertinoIcons.person_crop_circle, color: CupertinoColors.systemGreen, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildEndDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildWeatherCard(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  placeholder: "Search App & Guides...".tr(),
                  padding: const EdgeInsets.all(12),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    _buildDefaultGrid(),
                    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 16,
                        right: 16,
                        bottom: 0,
                        child: _buildSearchDropdownOverlay(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSearchDropdownOverlay() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('farming guide').snapshots(),
          builder: (context, snapshot) {
            final localResults = _appFeatures.where((feature) {
              return feature['title']!.toLowerCase().contains(_searchQuery);
            }).toList();

            List<Map<String, dynamic>> firebaseResults = [];
            if (snapshot.hasData && snapshot.data != null) {
              firebaseResults = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).where((data) {
                final title = data.containsKey('title') ? data['title'].toString().toLowerCase() : '';
                final content = data.containsKey('content') ? data['content'].toString().toLowerCase() : '';
                return title.contains(_searchQuery) || content.contains(_searchQuery);
              }).toList();
            }

            final totalResultsCount = localResults.length + firebaseResults.length;

            if (totalResultsCount == 0 && snapshot.connectionState == ConnectionState.active) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.search, size: 40, color: CupertinoColors.systemGrey3),
                      const SizedBox(height: 12),
                      Text(
                        "No results found for '$_searchQuery'",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: totalResultsCount,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                if (index < localResults.length) {
                  final item = localResults[index];
                  return ListTile(
                    leading: const Icon(CupertinoIcons.square_grid_2x2, color: CupertinoColors.systemGreen),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(item['type']!, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: CupertinoColors.systemGrey3),
                    onTap: () {
                      _searchFocusNode.unfocus();
                      Navigator.pushNamed(context, item['route']!);
                    },
                  );
                } else {
                  final item = firebaseResults[index - localResults.length];
                  return ListTile(
                    leading: const Icon(CupertinoIcons.book_fill, color: CupertinoColors.systemBlue),
                    title: Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      item['content'] ?? 'Guide Article',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: CupertinoColors.systemGrey3),
                    onTap: () {
                      _searchFocusNode.unfocus();
                      if (item.containsKey('route') && item['route'].toString().isNotEmpty) {
                        Navigator.pushNamed(context, item['route']);
                      }
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: CupertinoColors.systemGreen,
                    child: Text("M", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mjeed", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showComingSoon(context),
                          child: const Text("Edit Profile", style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: CupertinoColors.systemGrey5),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(icon: CupertinoIcons.person_fill, title: "user_profile".tr(), onTap: () => _showComingSoon(context)),
                  _buildDrawerItem(icon: CupertinoIcons.globe, title: "app_language".tr(), onTap: _toggleLanguage),
                  _buildDrawerItem(icon: CupertinoIcons.lock_shield_fill, title: "security_privacy".tr(), onTap: () => _showComingSoon(context)),
                  _buildDrawerItem(icon: Icons.support_agent, title: "Request Support".tr(), onTap: () => Navigator.pushNamed(context, '/request_support')),
                  _buildDrawerItem(icon: Icons.feedback, title: "Give Feedback".tr(), onTap: () => Navigator.pushNamed(context, '/feedback')),
                ],
              ),
            ),
            const Divider(height: 1, color: CupertinoColors.systemGrey5),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              child: ListTile(
                leading: const Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.systemRed),
                title: Text("sign_out".tr(), style: const TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600, fontSize: 16)),
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildHomeCard(title: "Farming Guide".tr(), icon: CupertinoIcons.book_fill, color: CupertinoColors.systemGreen, onTap: () => Navigator.pushNamed(context, '/guide')),
        _buildHomeCard(title: "AI Crop Doctor".tr(), icon: CupertinoIcons.sparkles, color: CupertinoColors.systemIndigo, onTap: () => Navigator.pushNamed(context, '/ai_chat')),
        _buildHomeCard(title: "Crop Management".tr(), icon: Icons.eco, color: CupertinoColors.systemOrange, onTap: () => Navigator.pushNamed(context, '/crop-management')),
        _buildHomeCard(title: "Community Forum".tr(), icon: CupertinoIcons.person_3_fill, color: CupertinoColors.systemTeal, onTap: () => _showComingSoon(context)),
        _buildHomeCard(title: "Request Support".tr(), icon: CupertinoIcons.question_circle_fill, color: CupertinoColors.systemRed, onTap: () => Navigator.pushNamed(context, '/request_support')),
        if (isAdmin)
          _buildHomeCard(title: "Admin Control".tr(), icon: CupertinoIcons.lock_shield_fill, color: CupertinoColors.black, onTap: () => _showComingSoon(context)),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("city".tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("weather_desc".tr(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              const Text("32°C", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(CupertinoIcons.sun_max_fill, color: Colors.yellow.shade300, size: 60),
        ],
      ),
    );
  }

  Widget _buildHomeCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Coming Soon"),
        content: const Text("This feature will be available in the next update."),
        actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(context))],
      ),
    );
  }
}