import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final roll = rollController.text.trim();
    final dept = departmentController.text.trim();
    final campus = campusController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if ([name, email, phone, roll, dept, campus, password, confirmPassword].any((e) => e.isEmpty)) {
      _showError('All fields are required.');
      return;
    }
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Please log in.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
      );

      
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An unexpected error occurred during signup.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700], 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.all(10), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword && isPasswordHidden,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]), 
          filled: true,
          fillColor: Colors.white.withOpacity(0.9), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none, 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), 
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
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
          ),
        ),
        backgroundColor: Colors.blue.shade800, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Container(
        // Background Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.lightBlue.shade300,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              const SizedBox(height: 20),
              Text(
                'Join the Campus Community!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Full Name', nameController),
              _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField('Phone', phoneController, keyboardType: TextInputType.phone),
              _buildTextField('Roll No', rollController),
              _buildTextField('Department', departmentController),
              _buildTextField('Campus', campusController),
              _buildTextField('Password', passwordController, isPassword: true),
              _buildTextField('Confirm Password', confirmPasswordController, isPassword: true),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600, 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5, 
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Create Account'),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Already have an account? Log In",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8), 
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}