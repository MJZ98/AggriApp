import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';
import 'welcome_page.dart';
import 'AI/ai_crop_doctor.dart';
import 'uc-1_sign_up/sign_up.dart';
import 'uc-2_sign_in/sign_in_screen.dart';
import 'uc-2_sign_in/otp_screen.dart';
import 'uc-6_weather_statusforecast/weather_screen.dart';
import 'UC-4_Farm_Management_Guide/farming_guide.dart';
import 'uc-7_crop_management/crop_management_page.dart';
import 'uc-14_request_support/request_support.dart';
import 'uc-15_feedback_and_review/feed_back.dart';
import 'uc-16_community_forum/community_forum.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AgriGuideApp(),
    ),
  );
}

class AgriGuideApp extends StatelessWidget {
  const AgriGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agricultural Guide App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/otp': (context) => const OtpScreen(),
        '/home': (context) => const HomePage(),
        '/guide': (context) => const FarmingGuidePage(),
        '/ai_chat': (context) => const AIChatPage(),
        '/crop-management': (context) => const CropManagementPage(),
        '/request_support': (context) => const RequestSupportPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/weather': (context) => const WeatherScreen(),
        // Internal guide sub-routes
        '/history': (context) => const HistoryPage(),
        '/crops': (context) => const CropsPage(),
        '/water': (context) => const WaterResourcesPage(),
        '/management': (context) => const ManagementPage(),
        '/faq': (context) => const FAQPage(),
        '/forum': (context) => const CommunityForumPage(),
      },
    );
  }
}

// --- HOME PAGE IMPLEMENTATION ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool isAdmin = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(icon: CupertinoIcons.person_fill, title: "user_profile".tr(), onTap: () => _showComingSoon()),
                    _buildDrawerItem(icon: Icons.support_agent, title: "Request Support".tr(), onTap: () => Navigator.pushNamed(context, '/request_support')),
                    _buildDrawerItem(icon: Icons.feedback, title: "Give Feedback".tr(), onTap: () => Navigator.pushNamed(context, '/feedback')),
                    _buildDrawerItem(icon: CupertinoIcons.globe, title: "app_language".tr(), onTap: _toggleLanguage),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWeatherBanner(),
            _buildSearchBar(),
            Expanded(
              child: _searchQuery.isEmpty ? _buildMainGrid() : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("city".tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("32°C", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(CupertinoIcons.sun_max_fill, color: Colors.yellow, size: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: "Search Farming Guide...".tr(),
        onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildMainGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildHomeCard("Farming Guide".tr(), CupertinoIcons.book_fill, Colors.green, () => Navigator.pushNamed(context, '/guide')),
        _buildHomeCard("AI Crop Doctor".tr(), CupertinoIcons.sparkles, Colors.indigo, () => Navigator.pushNamed(context, '/ai_chat')),
        _buildHomeCard("Crop Management".tr(), Icons.eco, Colors.orange, () => Navigator.pushNamed(context, '/crop-management')),
        _buildHomeCard("Request Support".tr(), Icons.support_agent, Colors.red, () => Navigator.pushNamed(context, '/request_support')),
      ],
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('farming guide').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) {
          final title = doc['title'].toString().toLowerCase();
          return title.contains(_searchQuery);
        }).toList();
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(docs[index]['title']),
            onTap: () => Navigator.pushNamed(context, docs[index]['route']),
          ),
        );
      },
    );
  }

  Widget _buildHomeCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.green, child: Text("M", style: TextStyle(color: Colors.white, fontSize: 24))),
          const SizedBox(width: 16),
          const Text("Mjeed", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text("sign_out".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right, size: 16), onTap: onTap);
  }

  void _showComingSoon() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Coming Soon"),
        actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(context))],
      ),
    );
  }
}