import 'package:campusapp/loginpage/loginpage.dart'; // <-- Make sure this is your login screen import
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  bool isEditing = false;

  TextEditingController nameController = TextEditingController(text: 'John Doe');
  TextEditingController phoneController = TextEditingController(text: '9876543210');
  TextEditingController rollController = TextEditingController(text: 'CAMP12345');
  TextEditingController departmentController = TextEditingController(text: 'Computer Science');
  TextEditingController campusController = TextEditingController(text: 'Main Campus');

  void toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  void saveProfile() {
    // Save logic (e.g., Firestore update) goes here
    setState(() => isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
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
    final TextEditingController emailController =
        TextEditingController(text: user?.email ?? 'Not available');

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



