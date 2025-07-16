import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Assuming you have a LoginPage to navigate back to
// import 'package:campusapp/loginpage/loginpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final rollController = TextEditingController();
  final departmentController = TextEditingController();
  final campusController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    rollController.dispose();
    departmentController.dispose();
    campusController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    // Validate all fields using the FormKey
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final roll = rollController.text.trim();
    final dept = departmentController.text.trim();
    final campus = campusController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'roll': roll,
        'department': dept,
        'campus': campus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Account created successfully! Please log in.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600, // Success color
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate back to login page after successful signup
        Navigator.pop(context); // Assuming pop goes back to login
        // Or if LoginPage is not in stack:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An unexpected error occurred during signup.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16), // Consistent margin
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
        duration: const Duration(seconds: 4), // Longer duration for error
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Added validator parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField( // Changed to TextFormField for validation
        controller: controller,
        obscureText: isPassword && isPasswordHidden,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        validator: validator ?? (value) { // Default validator for empty fields
          if (value == null || value.isEmpty) {
            return '$label is required.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]), // Darker grey for better visibility
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95), // Slightly less transparent for better contrast
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // No border by default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // Subtle border when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Primary color border when focused
          ),
          errorBorder: OutlineInputBorder( // Error border style
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder( // Focused error border style
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade900, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          'Create Your Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Slightly larger font for app bar title
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent app bar to show gradient
        elevation: 0, // No shadow for app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      extendBodyBehindAppBar: true, // Extends body behind app bar for full gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800, // Deeper blue start
              Colors.blue.shade400, // Lighter blue end
            ],
          ),
        ),
        child: Form( // Added Form widget for validation
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24), // Adjusted top padding for app bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join the Campus Community!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30, // Larger, more impactful heading
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2), // Slightly larger shadow
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.4), // Darker shadow
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // Increased spacing
                _buildTextField('Full Name', nameController),
                _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                _buildTextField('Phone', phoneController, keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required.';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) { // Simple 10-digit phone validation
                      return 'Please enter a valid 10-digit phone number.';
                    }
                    return null;
                  },
                ),
                _buildTextField('Roll No', rollController),
                _buildTextField('Department', departmentController),
                _buildTextField('Campus', campusController),
                _buildTextField('Password', passwordController, isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required.';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                _buildTextField('Confirm Password', confirmPasswordController, isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required.';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40), // Increased spacing before button
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Container( // Wrap button in Container for gradient
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade600, Colors.green.shade400], // Green gradient for button
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Make button background transparent to show gradient
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18), // Increased padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0, // No internal elevation as Container handles shadow
                            textStyle: const TextStyle(
                              fontSize: 22, // Larger font for button text
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                const SizedBox(height: 25), // Increased spacing
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Log In",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9), // Slightly more opaque
                      fontSize: 17, // Slightly larger font
                      fontWeight: FontWeight.w500, // Added some weight
                      decoration: TextDecoration.underline, // Underline for link
                      decorationColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}