import 'dart:async';
import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sleephoria/view/home/homepage.dart';
import 'package:Sleephoria/view/login/login_screen.dart';
import 'package:Sleephoria/view/splash_screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDuration = 3; 

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? onboardingSeen = prefs.getBool('onboardingSeen');
    final bool isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;

    await Future.delayed(Duration(seconds: splashDuration));

    if (!mounted) return;

    if (isUserLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Homepage()),
      );
    } else if (onboardingSeen == null || onboardingSeen == false) {
      await prefs.setBool('onboardingSeen', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(
        context,
      ), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/lottie/sleep.json",
              height: 200.h,
              width: 200.h,
              fit: BoxFit.contain,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'S L E E P H O R I A',
              style: TextStyle(
                color: ThemeHelper.textColor(context),
                fontSize: 24.sp,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
