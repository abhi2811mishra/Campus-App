import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center ,
          children: [
            Text(
              "LNMIIT",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                shadows:  [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 6.0,
            color: Colors.grey,
          ),
        ],
              ),
            ),
            SizedBox(width: 10), // Space between LNMIIT and NewsApp
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Campus",
                  style: TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            SizedBox(width: 5), // Space between Campus and App
            Text(
              "App",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0.0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Center content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center text horizontally
          children: [
            Material(
              elevation: 3.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/image.png",

                  height:
                      MediaQuery.of(context).size.height /
                      1.8, // Reduced for better spacing
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: "Welcome to "),
                  TextSpan(text: "Campus", style: TextStyle(color: Colors.green)),
                  TextSpan(text: "App", style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Bringing Campus to Your Fingertips.",
              textAlign: TextAlign.center, // Centers the text
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Loginpage()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: Text(
          "Login Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
