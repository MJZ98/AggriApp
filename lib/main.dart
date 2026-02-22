import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';

import 'screens/sign_in_screen.dart';
import 'screens/home_page.dart';
import 'screens/UC-1_sign_up/sign_up.dart'; // Re-added import
import 'screens/UC-4_Farm_Management_Guide/farming_guide_page.dart';
import 'screens/UC-4_Farm_Management_Guide/category_content_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AgriGuideApp());
}

class AgriGuideApp extends StatelessWidget {
  const AgriGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agricultural Guide App',
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => SignInScreen(),
        '/signup': (context) => const SignUpPage(), // Re-added route
        '/': (context) => const HomePage(),
        '/guide': (context) => const FarmingGuidePage(),
        '/history': (context) => const HistoryPage(),
        '/crops': (context) => const CropsPage(),
        '/water': (context) => const WaterResourcesPage(),
        '/management': (context) => const ManagementPage(),
        '/faq': (context) => const FAQPage(),
      },
    );
  }
}
