

import 'package:campusapp/homepage/pages/add_item.dart';
import 'package:campusapp/homepage/pages/ai_chatbot.dart';
import 'package:campusapp/homepage/pages/event_main.dart';
import 'package:campusapp/homepage/pages/feedback.dart';
import 'package:campusapp/homepage/pages/lost_found.dart';
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
                         elevation: 1,
                       centerTitle: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
              "Campus",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 25
              ),
            ),
            SizedBox(width: 5),
            Text(
              "App",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontSize: 25),
            ),
                      ],
                    ),
                      
                       
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'No Username'),
              accountEmail: Text(user?.email ?? 'No Email'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ); 
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? 'Student'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildTile(
                    context,
                    icon: Icons.class_,
                    label: 'Classes',
                    onTap: () {
                      // Navigate to classes screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.event,
                    label: 'Events',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  EventListPage(),
                        ),
                      );
                     
                      // Navigate to events screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.feedback,
                    label: 'Feedback',
                    onTap: () {
                       Navigator.push(
                            context,
                         MaterialPageRoute(
                            builder: (context) => FeedbackPage(),
                          ),
                      );
                      // Navigate to events screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.map,
                    label: 'Campus Map',
                    onTap: () {
                       Navigator.push(
                            context,
                         MaterialPageRoute(
                            builder: (context) => GoogleMapSearchPage(
                              // Replace with actual dark mode state
                              ),
                          ),
                      );
                      // Navigate to notifications screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.smart_toy_outlined,
                    label: 'AI Chatbot',
                    onTap: () {
                       Navigator.push(
                         context,
                          MaterialPageRoute(builder: (_) => const  ChatBotPage()),
                       );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.foundation,
                    label: 'Lost & Found',
                    onTap: () {
                       Navigator.push(
                         context,
                          MaterialPageRoute(builder: (_) => AllItemsPage()),
                       );
                      // Navigate to notifications screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.bus_alert,
                    label: 'Transport Scheduler',
                    onTap: () {
                      Navigator.push(
                         context,
                          MaterialPageRoute(builder: (_) => ScheduleTabs()),
                       );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.build_circle,
                    label: ' Maintenance Tracker',
                    onTap: () {
                      // Navigate to notifications screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ); // Navigate to profile screen
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                     Navigator.push(
                            context,
                         MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              // Replace with actual dark mode state
                              ),
                          ),
                      );

                      // Navigate to settings screen
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child:Center(
                child: Text(
                  '© 2025 Campus App',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
