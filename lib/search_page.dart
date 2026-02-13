import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchQuery = '';
  bool _isSpeechAvailable = false;
  late AnimationController _micAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _micAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _micAnimation.reverse();
      else if (status == AnimationStatus.dismissed) _micAnimation.forward();
    });
  }

  void _initSpeech() async {
    _isSpeechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => print('Speech Error: $error'),
    );
    setState(() {});
  }

  void _startListening() async {
    if (_isSpeechAvailable && !_isListening) {
      setState(() => _isListening = true);
      _micAnimation.forward();
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _searchQuery = result.recognizedWords.toLowerCase();
            _controller.text = _searchQuery;
          });
        },
        localeId: 'ar_SA',
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    _micAnimation.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _micAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // خلفية فاتحة ومريحة
      body: Stack(
        children: [
          // خلفية علوية خضراء منحنية
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "المساعد الزراعي الذكي",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal', // تأكد من إضافة الخط في pubspec
                  ),
                ),
                const SizedBox(height: 20),

                // شريط البحث المطور
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن آفة، محصول، أو نصيحة...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                        suffixIcon: _buildMicButton(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // منطقة النتائج
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _buildHint()
                      : _buildResultsStream(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت زر الميكروفون مع الحركة
  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: ScaleTransition(
        scale: _micAnimation,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isListening ? Colors.red.shade50 : Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  // بناء قائمة النتائج
  Widget _buildResultsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .where('keywords', arrayContains: _searchQuery)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return _buildArticleCard(doc);
          },
        );
      },
    );
  }

  // تصميم البطاقة الاحترافي
  Widget _buildArticleCard(DocumentSnapshot doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          doc['title'],
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 16),
        ),
        subtitle: Text(
          doc['content'],
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.green),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(title: doc['title'], content: doc['content']),
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/2311/2311543.png', // أيقونة بحث لطيفة
            height: 120,
            color: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          const Text(
            'أهلاً بك في الدليل الزراعي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Text(
            'يمكنك البحث كتابةً أو عبر الصوت',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text("عذراً، لم نجد نتائج تطابق بحثك", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}