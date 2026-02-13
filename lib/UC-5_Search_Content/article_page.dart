import 'package:flutter/material.dart';

class ArticlePage extends StatelessWidget {
  final String title;
  final String content; // must match what we send from SearchPage

  const ArticlePage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
