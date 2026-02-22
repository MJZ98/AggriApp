import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment if using Firestore
import 'request_support.dart';
import 'feed_back.dart';
import 'sign_in_screen.dart';

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
                  MaterialPageRoute(builder: (context) => const RequestSupportPage()),
                );
              } else if (value == 'feedback') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'support',
                  child: ListTile(
                    leading: Icon(Icons.support_agent),
                    title: Text('Support'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'feedback',
                  child: ListTile(
                    leading: Icon(Icons.feedback),
                    title: Text('Feedback'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar (TOP)
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

            const SizedBox(height: 20),

            // Navigation Buttons (Merged from HomeScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuButton(
                    icon: Icons.support_agent,
                    label: "Request Support",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RequestSupportPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    icon: Icons.thumbs_up_down,
                    label: "Give Feedback",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackPage()),
                    ),
                  ),
                ],
              ),
            ),

            // Placeholder for Search Results / Content
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Search results for: '$_searchQuery'"),
              ),
            
            /* 
            // Original Firestore search logic - uncomment if Firebase is configured
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('farming guide')
                    .snapshots(),
                builder: (context, snapshot) { ... }
              ),
            ),
            */
          ],
        ),
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
              Icon(icon, size: 50, color: CupertinoColors.systemGreen),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
