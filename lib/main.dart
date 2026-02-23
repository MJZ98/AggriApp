import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import pages
import 'home_page.dart';
import 'welcome_page.dart';
import 'uc-1_sign_up/sign_up.dart';
import 'uc-2_sign_in/sign_in_screen.dart';
import 'uc-2_sign_in/otp_screen.dart';
import 'uc-4_farm_management_guide/farming_guide_page.dart';
import 'uc-4_farm_management_guide/category_content_pages.dart';
import 'uc-7_crop_management/crop_management_page.dart';

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
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/otp': (context) => const OtpScreen(), // OTP screen
        '/': (context) => const HomePage(),
        '/guide': (context) => const FarmingGuidePage(),
        '/history': (context) => const HistoryPage(),
        '/crops': (context) => const CropsPage(),
        '/water': (context) => const WaterResourcesPage(),
        '/management': (context) => const ManagementPage(),
        '/faq': (context) => const FAQPage(),
        '/crop-management': (context) => CropManagementPage(), //crop management page
      },
    );
  }
}