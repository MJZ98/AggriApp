import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../uc-2_sign_in/otp_screen.dart'; // ربط صفحة OTP

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String _selectedLanguage = 'English';
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey[600]) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Personal Information'),
                Row(
                  children: [
                    Expanded(child: _buildTextField('First Name', controller: _firstNameController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Last Name', controller: _lastNameController)),
                  ],
                ),
                _buildTextField('Email', icon: Icons.mail_outline, isEmail: true, controller: _emailController),
                _buildTextField('Phone Number', icon: Icons.phone, isNumeric: true, controller: _phoneController),
                _buildSectionTitle('Location'),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Country', controller: _countryController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('City', controller: _cityController)),
                  ],
                ),
                _buildTextField('Address', icon: Icons.house_outlined, controller: _addressController),
                _buildSectionTitle('Preferred Language'),
                _buildLanguageSegment(),
                _buildSectionTitle('Security'),
                _buildTextField('Password', isPassword: true, controller: _passwordController),
                _buildTextField('Confirm Password', isPassword: true, isConfirmPassword: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text('Complete Registration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {IconData? icon,
        bool isPassword = false,
        bool isNumeric = false,
        bool isEmail = false,
        TextEditingController? controller,
        bool isConfirmPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(
          hint,
          icon: icon,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon((isConfirmPassword ? _isConfirmPasswordObscured : _isPasswordObscured)
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () {
              setState(() {
                if (isConfirmPassword) {
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                } else {
                  _isPasswordObscured = !_isPasswordObscured;
                }
              });
            },
          )
              : null,
        ),
        obscureText: isPassword ? (isConfirmPassword ? _isConfirmPasswordObscured : _isPasswordObscured) : false,
        keyboardType: isNumeric
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Required';
          if (isEmail && !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)) return 'Enter a valid email';
          if (isNumeric && (!RegExp(r'^[0-9]+$').hasMatch(val) || val.length < 10)) return 'Invalid phone number';
          if (isPassword && !isConfirmPassword) {
            if (val.length < 8) return 'Password must be at least 8 characters.';
            if (!RegExp(r'[a-zA-Z]').hasMatch(val) || !RegExp(r'[0-9]').hasMatch(val)) return 'Password must include letters & numbers.';
          }
          if (isConfirmPassword && val != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget _buildLanguageSegment() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'English', label: Text('English')),
          ButtonSegment(value: 'Arabic', label: Text('Arabic')),
        ],
        selected: {_selectedLanguage},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedLanguage = newSelection.first;
          });
        },
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance.collection('user_credentials').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'country': _countryController.text.trim(),
          'city': _cityController.text.trim(),
          'address': _addressController.text.trim(),
          'language': _selectedLanguage,
        });

        if (!mounted) return;

        // الانتقال مباشرة إلى OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OtpScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.message ?? 'An unknown error occurred.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}