import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer for splash duration and navigate to onboarding screen
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, 'onBoarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display your logo or splash image
            Image.asset(
              'assets/images/splashscreenlogo.png', // Your splash logo image
              width: 450,
              height: 450,
            ),
            SizedBox(height: 20),
            
          
          ],
        ),
      ),
    );
  }
}
