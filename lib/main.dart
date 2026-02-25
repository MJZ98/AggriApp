import 'package:agricultural_guide_app/AI/ai_crop_doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';

// --- جميع الاستيرادات (لم يتم حذف شيء) ---
import 'home_page.dart'; // تم الإبقاء عليه لضمان عدم كسر المسارات إذا كان مستخدماً في مكان آخر
import 'welcome_page.dart';
import 'uc-1_sign_up/sign_up.dart';
import 'uc-2_sign_in/sign_in_screen.dart';
import 'uc-2_sign_in/otp_screen.dart';
import 'uc-6_weather_statusforecast/weather_screen.dart';
import 'uc-4_farm_management_guide/farming_guide.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // دمج الـ EasyLocalization مع الـ App
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
          iconTheme: IconThemeData(color: CupertinoColors.systemGreen),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
          ),
        ),
        dividerColor: Colors.transparent,
      ),
      // البداية من صفحة الـ Welcome كما في كودك الأخير
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/otp': (context) => const OtpScreen(),
        '/': (context) => const HomePage(), // الهوم المدمجة بالأسفل
        '/': (context) => const HomePage(),
        '/UC-4_Farm_Management_Guide/farming_guide.dart': (context) => const FarmingGuidePage(),
        '/AI/ai_crop_doctor': (context) => const AIChatPage(),
        '/crop_management': (context) => const HistoryPage(),
        '/Community_forum': (context) => const CropsPage(),
        '/request_support': (context) => const WaterResourcesPage(),
        '/settings': (context) => const ManagementPage(),
        '/admin_control': (context) => const FAQPage(),
        '/user_profile': (context) => const FAQPage(),
        '/weather_status': (context) => const FAQPage(),
        '/guide': (context) => const FarmingGuidePage(),
        '/ai_chat': (context) => const AIChatPage(),
        '/crop-management': (context) => const CropManagementPage(),
        '/request_support': (context) => const RequestSupportPage(),
        '/feedback': (context) => const FeedbackPage(),
        // المسارات المتبقية من كود الزميل
        '/ai_chat': (context) => const AIChatPage(),
        '/history': (context) => const HistoryPage(),
        '/crops': (context) => const CropsPage(),
        '/water': (context) => const WaterResourcesPage(),
        '/management': (context) => const ManagementPage(),
        '/faq': (context) => const FAQPage(),

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
  // TODO: Fetch this from Firebase Auth later
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
    Navigator.pop(context); // Close drawer
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
              icon: const Icon(CupertinoIcons.person_crop_circle, color: CupertinoColors.systemBlue, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // --- The Right-Side Menu (EndDrawer) ---
      endDrawer: Drawer(
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
                      backgroundColor: CupertinoColors.systemBlue,
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
                  ],
                ),
              ),
              const Divider(height: 1, color: CupertinoColors.systemGrey5),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: ListTile(
                  leading: const Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.systemRed),
                  title: Text("sign_out".tr(), style: const TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600, fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // --- Main Body Layout ---
      body: SafeArea(
        child: Column(
          children: [
            // 1. Weather Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildWeatherCard(),
            ),

            // 2. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: "Search Farming Guide...",
                padding: const EdgeInsets.all(12),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),

            // 3. Dynamic Content Area (Grid OR Search Results)
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultGrid() // Show Grid if not searching
                  : _buildSearchResults(), // Show Firebase results if searching
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // Default Grid View (Shows when search is empty)
  Widget _buildDefaultGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildHomeCard(title: "Farming Guide".tr(), icon: CupertinoIcons.book_fill, color: CupertinoColors.systemGreen, onTap: () => Navigator.pushNamed(context, '/UC-4_Farm_Management_Guide/farming_guide.dart')),
        _buildHomeCard(title: "AI Crop Doctor".tr(), icon: CupertinoIcons.sparkles, color: CupertinoColors.systemIndigo, onTap: () => Navigator.pushNamed(context, '/AI/ai_crop_doctor')),
        _buildHomeCard(title: "Crop Management".tr(), icon: CupertinoIcons.chart_bar_square_fill, color: CupertinoColors.systemOrange, onTap: () => Navigator.pushNamed(context, '/management')),
        _buildHomeCard(title: "Community Forum".tr(), icon: CupertinoIcons.person_3_fill, color: CupertinoColors.systemTeal, onTap: () => _showComingSoon(context)),
        _buildHomeCard(title: "Request Support".tr(), icon: CupertinoIcons.question_circle_fill, color: CupertinoColors.systemRed, onTap: () => _showComingSoon(context)),
        _buildHomeCard(title: "Settings".tr(), icon: CupertinoIcons.settings, color: CupertinoColors.systemGrey, onTap: () => _showComingSoon(context)),
        if (isAdmin)
          _buildHomeCard(title: "Admin Control".tr(), icon: CupertinoIcons.lock_shield_fill, color: CupertinoColors.black, onTap: () => _showComingSoon(context)),
      ],
    );
  }

  // Firebase Search Results (Shows when typing)
  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('farming guide').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No database connection or data found."));
        }

        final results = snapshot.data!.docs.where((doc) {
          // Add basic error handling in case fields are missing in Firestore
          final data = doc.data() as Map<String, dynamic>;
          final title = data.containsKey('title') ? data['title'].toString().toLowerCase() : '';
          final content = data.containsKey('content') ? data['content'].toString().toLowerCase() : '';
          return title.contains(_searchQuery) || content.contains(_searchQuery);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              "No results found for '$_searchQuery'",
              style: const TextStyle(color: CupertinoColors.systemGrey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                title: Text(data['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  data['content'] ?? 'No Content',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey3),
                onTap: () {
                  if (data.containsKey('route') && data['route'].toString().isNotEmpty) {
                    Navigator.pushNamed(context, data['route']);
                  }
                },
              ),
            );
          },
        );
        '/weather': (context) => const WeatherScreen(),
      },
    );
  }

  // --- HELPER COMPONENTS ---

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

// --- دمج صفحة الهوم (HomePage) في المين مباشرة ---
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
                    _buildDrawerItem(icon: CupertinoIcons.person_fill, title: "user_profile".tr(), onTap: () => _showComingSoon(context)),
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

  // --- دوال بناء الواجهة المدمجة ---

  Widget _buildWeatherBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.3), blurRadius: 15)],
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
          Text("Mjeed", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  void _showComingSoon(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Coming Soon"),
        actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(context))],
      ),
    );
  }
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
  }}