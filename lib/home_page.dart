import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../uc-14_request_support/request_support.dart';
import '../uc-15_feedback_and_review/feed_back.dart';
import '../uc-2_sign_in/sign_in_screen.dart';
import '../uc-2_sign_in/otp_screen.dart'; // تم إضافة الاستدعاء للـ OTP

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة مساعدة للتأكد من دخول المستخدم عبر OTP
  void navigateAfterOtp() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OtpScreen()),
          (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    // هنا يمكنك استدعاء navigateAfterOtp() إذا تريد أن يظهر OTP فور فتح الهوم بيج بعد تسجيل الدخول
    // مثلاً عند تحقق تسجيل الدخول
    // navigateAfterOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agriculture Guide App"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'support') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestSupportPage(),
                  ),
                );
              } else if (value == 'feedback') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackPage(),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                      (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'support',
                child: ListTile(
                  leading: Icon(Icons.support_agent),
                  title: Text('Support'),
                ),
              ),
              PopupMenuItem(
                value: 'feedback',
                child: ListTile(
                  leading: Icon(Icons.feedback),
                  title: Text('Feedback'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search Farming Guide...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // Farming Guide Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildHomeIcon(
              icon: CupertinoIcons.book_fill,
              label: "Farming Guide",
              onTap: () => Navigator.pushNamed(context, '/guide'),
            ),
          ),

          const SizedBox(height: 10),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _MenuButton(
                  icon: Icons.support_agent,
                  label: "Request Support",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestSupportPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.thumbs_up_down,
                  label: "Give Feedback",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Firestore Search Results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farming guide')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No data found"),
                  );
                }

                if (_searchQuery.isEmpty) {
                  return const Center(
                    child: Text(
                      "Start typing to search in Farming Guide",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final results =
                snapshot.data!.docs.where((doc) {
                  final title =
                  doc['title'].toString().toLowerCase();
                  final content =
                  doc['content'].toString().toLowerCase();

                  return title.contains(_searchQuery) ||
                      content.contains(_searchQuery);
                }).toList();

                if (results.isEmpty) {
                  return const Center(
                    child: Text("No results found"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final doc = results[index];

                    return Card(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(doc['title']),
                        subtitle: Text(
                          doc['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                        ),
                        onTap: () {
                          if (doc['route'] != null &&
                              doc['route']
                                  .toString()
                                  .isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              doc['route'],
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding:
          const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}