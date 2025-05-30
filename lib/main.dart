import 'package:campusapp/loginpage/landingpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LandingPage()
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(), // Home Page
         // Another page for navigation
      },
    );
  }
}

  // This widget is the root of your application.
 
