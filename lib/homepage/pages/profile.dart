import 'package:campusapp/loginpage/loginpage.dart'; // Ensure this path is correct
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isEditing = false;
  bool isLoading = true; // State for initial data loading

  // Controllers are now initialized in fetchUserData, but declared here
  // to be accessible throughout the widget's lifecycle.
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController rollController;
  late TextEditingController departmentController;
  late TextEditingController campusController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings initially to prevent lateinit errors
    // if fetchUserData takes time or fails.
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    rollController = TextEditingController();
    departmentController = TextEditingController();
    campusController = TextEditingController();

    fetchUserData();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    rollController.dispose();
    departmentController.dispose();
    campusController.dispose();
    super.dispose();
  }

  // Helper function for consistent SnackBar messages
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> fetchUserData() async {
    if (user == null) {
      if (mounted) {
        _showSnackBar('User not logged in.', backgroundColor: Colors.orange);
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user?.uid).get();
      final data = doc.data();

      // Update controllers with fetched data
      emailController.text = data?['email'] ?? user?.email ?? ''; // Prioritize Firestore, then Firebase Auth email
      nameController.text = data?['name'] ?? '';
      phoneController.text = data?['phone'] ?? '';
      rollController.text = data?['roll'] ?? '';
      departmentController.text = data?['department'] ?? '';
      campusController.text = data?['campus'] ?? '';
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to load profile: $e", backgroundColor: Colors.red.shade700);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true); // Show loading while saving

    try {
      if (user == null) {
        _showSnackBar('User not logged in.', backgroundColor: Colors.orange);
        return;
      }
      await _firestore.collection('users').doc(user!.uid).set( // Use .set with merge: true to avoid overwriting other fields
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'roll': rollController.text.trim(),
          'department': departmentController.text.trim(),
          'campus': campusController.text.trim(),
          'email': emailController.text.trim(), // Save email too, in case it was updated (though usually static for auth)
        },
        SetOptions(merge: true), // Important: Only update specified fields, create if doc doesn't exist
      );

      if (mounted) {
        _showSnackBar("Profile updated successfully!", backgroundColor: Colors.green.shade600);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _showSnackBar("Update failed: ${e.message}", backgroundColor: Colors.red.shade700);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("An unexpected error occurred: $e", backgroundColor: Colors.red.shade700);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Hide loading
          isEditing = false; // Exit editing mode
        });
      }
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Use pushReplacement or pushAndRemoveUntil for logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // Remove all routes from stack
      );
    }
  }

  // Refactored buildField for better UI and reusability
  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, {bool editable = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: editable && isEditing, // Only editable fields can be enabled in editing mode
        readOnly: !editable || !isEditing, // Read-only if not editable or not in editing mode
        keyboardType: keyboardType,
        style: TextStyle(
          color: editable && isEditing ? Colors.blue.shade800 : Colors.grey.shade700, // Text color changes based on edit state
          fontWeight: editable && isEditing ? FontWeight.w600 : FontWeight.normal,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isEditing ? Colors.blue.shade700 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          disabledBorder: OutlineInputBorder( // Style for disabled (read-only) state
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        cursorColor: Colors.blue.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile", // More engaging title
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue.shade700, // Richer blue for AppBar
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle_outline : Icons.edit, // More appealing icons
              color: Colors.white,
              size: 28,
            ),
            tooltip: isEditing ? 'Save Profile' : 'Edit Profile',
            onPressed: isLoading ? null : (isEditing ? saveProfile : toggleEdit), // Disable if loading
          ),
          const SizedBox(width: 8), // Add some spacing
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50, // Very light blue
              Colors.blue.shade100, // Slightly darker
              Colors.blue.shade200, // Even slightly darker
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Themed indicator
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24), // Increased overall padding
                child: Column(
                  children: [
                    // Profile Avatar Section
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.shade400, width: 3), // Border for the avatar
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60, // Larger avatar
                        backgroundColor: Colors.blue.shade500, // Solid blue background
                        child: Text(
                          nameController.text.isNotEmpty
                              ? nameController.text[0].toUpperCase()
                              : (emailController.text.isNotEmpty ? emailController.text[0].toUpperCase() : '?'),
                          style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold), // Larger, bolder initial
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Profile Fields
                    _buildProfileField('Email Address', emailController, Icons.email, editable: false),
                    _buildProfileField('Full Name', nameController, Icons.person),
                    _buildProfileField('Phone Number', phoneController, Icons.phone, keyboardType: TextInputType.phone),
                    _buildProfileField('Roll Number', rollController, Icons.school), // Changed icon
                    _buildProfileField('Department', departmentController, Icons.class_), // Changed icon
                    _buildProfileField('Campus', campusController, Icons.location_on), // Changed icon

                    const SizedBox(height: 30),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, size: 28), // Larger icon
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600, // Stronger red for logout
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5, // Add shadow
                        minimumSize: const Size(double.infinity, 50), // Make button wider
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}