import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

// Import all screens
import 'firebase_options.dart';
import 'welcome_page.dart';
import 'home_page.dart'; // Ensure HomePage is in its own file
import 'AI/ai_crop_doctor.dart';
import 'uc-1_sign_up/sign_up.dart';
import 'uc-2_sign_in/sign_in_screen.dart';
import 'uc-2_sign_in/otp_screen.dart';
import 'uc-6_weather_statusforecast/weather_screen.dart';
import 'UC-4_Farm_Management_Guide/farming_guide.dart';
import 'uc-7_crop_management/crop_management_page.dart';
import 'uc-14_request_support/request_support.dart';
import 'uc-15_feedback_and_review/feed_back.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          iconTheme: IconThemeData(color: CupertinoColors.systemGreen),
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
        // Internal guide routes
        '/history': (context) => const HistoryPage(),
        '/crops': (context) => const CropsPage(),
        '/water': (context) => const WaterResourcesPage(),
        '/management': (context) => const ManagementPage(),
        '/faq': (context) => const FAQPage(),
      },
    );
  }
}