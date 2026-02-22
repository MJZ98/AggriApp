import 'package:flutter/material.dart';
import '/home_page.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;

  void _verifyOtp() {
    // Basic verification logic: checking if OTP is '1234'
    if (_otpController.text == '1234') {
      setState(() {
        _errorMessage = null;
      });
      // Navigate to HomePage (where UC-4 is) and remove all previous screens
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = "Invalid OTP. Use 1234 to test.";
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the code sent to your email",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "0000",
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
