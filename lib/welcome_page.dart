import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // Soft subtle green at the top
              Color(0xFFFFFFFF), // Fading into white
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Floating App Icon with soft shadow
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGreen.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.leaf_arrow_circlepath,
                    size: 80,
                    color: CupertinoColors.systemGreen,
                  ),
                ),

                const SizedBox(height: 40),

                // Modern Bold Title
                const Text(
                  'AgriGuide',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Refined Subtitle
                Text(
                  'Your smart companion for modern farming, crop management, and agricultural insights.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const Spacer(),

                // Primary Button (Sign In)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(16), // Apple-style thick radius
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Secondary Button (Sign Up)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CupertinoButton(
                    color: const Color(0xFFF2F2F7), // iOS System Grey 6
                    borderRadius: BorderRadius.circular(16),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGreen,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}