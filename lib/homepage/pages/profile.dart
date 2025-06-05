
import 'package:campusapp/loginpage/loginpage.dart';
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
  bool isLoading = true;

  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController rollController;
  late TextEditingController departmentController;
  late TextEditingController campusController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(user?.uid).get();
      final data = doc.data();

      nameController = TextEditingController(text: data?['name'] ?? '');
      emailController = TextEditingController(text: data?['email'] ?? '');
      phoneController = TextEditingController(text: data?['phone'] ?? '');
      rollController = TextEditingController(text: data?['roll'] ?? '');
      departmentController = TextEditingController(text: data?['department'] ?? '');
      campusController = TextEditingController(text: data?['campus'] ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  Future<void> saveProfile() async {
    try {
      await _firestore.collection('users').doc(user?.uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'roll': rollController.text.trim(),
        'department': departmentController.text.trim(),
        'campus': campusController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
    setState(() => isEditing = false);
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Widget buildField(String label, TextEditingController controller, IconData icon, {bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: editable && isEditing,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: isEditing ? saveProfile : toggleEdit,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue.shade200,
                child: Text(
                  nameController.text.isNotEmpty
                      ? nameController.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildField('Email', emailController, Icons.email, editable: false),
            buildField('Name', nameController, Icons.person),
            buildField('Phone', phoneController, Icons.phone),
            buildField('Roll No', rollController, Icons.badge),
            buildField('Department', departmentController, Icons.school),
            buildField('Campus', campusController, Icons.location_city),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
