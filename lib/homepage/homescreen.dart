import 'package:campusapp/homepage/pages/add_item.dart';
import 'package:campusapp/homepage/pages/ai_chatbot.dart';
import 'package:campusapp/homepage/pages/event_main.dart';
import 'package:campusapp/homepage/pages/feedback.dart';
import 'package:campusapp/homepage/pages/map.dart';
import 'package:campusapp/homepage/pages/profile.dart';
import 'package:campusapp/homepage/pages/settings.dart';
import 'package:campusapp/homepage/pages/transport.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusapp/loginpage/loginpage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2, // Increased elevation slightly for more depth
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Campus",
              style: TextStyle(
                color: Colors.green.shade700, // Deeper green for better contrast
                fontWeight: FontWeight.bold,
                fontSize: 26, // Slightly larger title font
                letterSpacing: 0.8, // Added letter spacing for a modern look
              ),
            ),
            const SizedBox(width: 6), // Slightly increased spacing
            Text(
              "App",
              style: TextStyle(
                color: Colors.blue.shade700, // Deeper blue for better contrast
                fontWeight: FontWeight.bold,
                fontSize: 26, // Consistent font size
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'No Username',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Styled text
              ),
              accountEmail: Text(
                user?.email ?? 'No Email',
                style: TextStyle(color: Colors.white.withOpacity(0.8)), // Slightly transparent for subtle look
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: Colors.blue.shade700), // Larger icon with darker blue
              ),
              decoration: BoxDecoration(
                color: Colors.blue, // Theme color for consistency
                // Optional: You could add a gradient or image here
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue), // Icon colored
              title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)), // Bolder text
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(indent: 16, endIndent: 16), // Divider with padding
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), // Logout icon in red
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)), // Logout text in red
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? 'Student'}!',
              style: const TextStyle(
                fontSize: 28, // Larger welcome message
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Slightly darker text
              ),
            ),
            const SizedBox(height: 25), // Increased spacing
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18, // Increased spacing between tiles
                mainAxisSpacing: 18, // Increased spacing between tiles
                children: [
                  _buildTile(context, icon: Icons.class_, label: 'Classes', onTap: () {
                    // Navigate to classes screen
                  }),
                  _buildTile(context, icon: Icons.event, label: 'Events', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EventListPage()));
                  }),
                  _buildTile(context, icon: Icons.feedback, label: 'Feedback', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                  }),
                  _buildTile(context, icon: Icons.map, label: 'Campus Map', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleMapSearchPage()));
                  }),
                  _buildTile(context, icon: Icons.smart_toy_outlined, label: 'AI Chatbot', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotPage()));
                  }),
                  _buildTile(context, icon: Icons.foundation, label: 'Lost & Found', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AllItemsPage()));
                  }),
                  _buildTile(context, icon: Icons.bus_alert, label: 'Transport Scheduler', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleTabs()));
                  }),
                  _buildTile(context, icon: Icons.build_circle, label: 'Maintenance Tracker', onTap: () {
                    // Navigate to maintenance screen
                  }),
                  _buildTile(context, icon: Icons.person, label: 'Profile', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                  _buildTile(context, icon: Icons.settings, label: 'Settings', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2025 Campus App',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13), // Slightly darker grey and smaller font
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material( // Use Material for elevation and InkWell ripple effect
      color: Colors.white, // Clean white background for the tile
      borderRadius: BorderRadius.circular(18), // Slightly more rounded corners
      elevation: 6, // Increased elevation for a floating effect
      shadowColor: Colors.blue.withOpacity(0.2), // Subtle blue tint to the shadow
      child: InkWell( // Provides visual feedback on tap (ripple effect)
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Theme.of(context).primaryColor), // Larger icon, using theme primary color
              const SizedBox(height: 14), // Increased spacing
              Text(
                label,
                textAlign: TextAlign.center, // Ensures text wraps cleanly
                style: const TextStyle(
                  fontSize: 17, // Slightly larger text
                  fontWeight: FontWeight.w600, // Bolder font weight
                  color: Colors.black87, // Darker text for readability
                ),
                maxLines: 2, // Allow label to wrap to two lines
                overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
              ),
            ],
          ),
        ),
      ),
    );
  }
}