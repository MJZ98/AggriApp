import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for Web support
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

// IMPORTANT: Do not hardcode API keys in production.
// Consider using flutter_dotenv or Firebase Vertex AI instead.
const String _apiKey = 'AIzaSyDn-MgOzDZu0tZP4BsqM0jo5CIOaDS8sgA';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    final String userText = _controller.text.trim();
    final XFile? userImage = _selectedImage;

    setState(() {
      _messages.add({"role": "user", "text": userText, "image": userImage});
      _isLoading = true;
      _controller.clear();
      _selectedImage = null;
    });

    try {
      // 1. Properly define the System Instruction
      final systemInstruction = Content.system(
          "You are an agricultural expert. Identify plants, pests, or diseases from images if provided. Answer farming questions concisely and accurately for the Saudi Arabian region."
      );

      // 2. Initialize the model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: systemInstruction,
      );

      final List<Part> parts = [];

      // 3. Add user text if it exists
      if (userText.isNotEmpty) {
        parts.add(TextPart(userText));
      }

      // 4. Add image safely across platforms
      if (userImage != null) {
        // FIX: Use XFile's built-in readAsBytes() instead of dart:io File
        final imageBytes = await userImage.readAsBytes();

        // FIX: Use XFile's mimeType if available, fallback to guessing
        final mimeType = userImage.mimeType ??
            (userImage.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');

        parts.add(DataPart(mimeType, imageBytes));
      }

      // 5. Generate content
      final content = [Content.multi(parts)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add({
          "role": "ai",
          "text": response.text ?? "Sorry, I could not generate a response."
        });
      });

    } catch (e) {
      setState(() {
        _messages.add({
          "role": "ai",
          "text": "Connection Error: ${e.toString()}"
        });
      });
      debugPrint("AI Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    // Catch errors if the user cancels or denies permissions
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Crop Doctor")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final XFile? msgImage = msg['image']; // Extract the image securely

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser ? CupertinoColors.systemBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 4)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msgImage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // FIX: Cross-platform image rendering
                              child: kIsWeb
                                  ? Image.network(msgImage.path, height: 150, fit: BoxFit.cover)
                                  : Image.file(File(msgImage.path), height: 150, fit: BoxFit.cover),
                            ),
                          ),
                        if (msg['text'].isNotEmpty)
                          Text(
                            msg['text'],
                            style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CupertinoActivityIndicator()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  if (_selectedImage != null)
                    Row(children: [
                      const Icon(Icons.image, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Photo attached", style: TextStyle(color: Colors.green[700])),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _selectedImage = null))
                    ]),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.camera_fill, color: Colors.grey),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _controller,
                          placeholder: "Ask or upload a photo...",
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: CupertinoColors.systemBlue,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}