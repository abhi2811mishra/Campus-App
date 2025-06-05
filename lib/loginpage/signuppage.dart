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
      return _showError('All fields are required.');
    }
    if (password != confirmPassword) {
      return _showError('Passwords do not match.');
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
        const SnackBar(content: Text('Account created! Please log in.')),
      );

      Navigator.pop(context); // or push to LoginPage
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Signup failed.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword && isPasswordHidden,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility),
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField('Full Name', nameController),
            buildTextField('Email', emailController),
            buildTextField('Phone', phoneController),
            buildTextField('Roll No', rollController),
            buildTextField('Department', departmentController),
            buildTextField('Campus', campusController),
            buildTextField('Password', passwordController, isPassword: true),
            buildTextField('Confirm Password', confirmPasswordController, isPassword: true),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Create Account'),
                  ),
          ],
        ),
      ),
    );
  }
}
