import 'package:Sleephoria/view/home/homepage.dart';
import 'package:Sleephoria/view/register/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sleephoria/view/globals/globals.dart' as globals;
import 'sign_in_view.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlert("Invalid Input", "Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = result.user;
      final userID = user?.uid;
      if (userID == null) throw Exception("User ID is null");

      // 🔹 Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        // ✅ Check if account is disabled
        final isDisabled = data?['isDisabled'] == true;
        if (isDisabled) {
          // Sign out immediately
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;
          _showAlert(
            "Account Disabled",
            "Your account has been disabled. Please contact support.",
          );
          return;
        }
      }

      if (!mounted) return;

      showToast(
        "Login Successful",
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.center,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black54,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,

          fontFamily: 'montserrat',
        ),
        borderRadius: BorderRadius.circular(0), 
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), 
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context); 
      globals.isUserLoggedIn = true;
      if (globals.isUserLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>  Homepage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (_) {
      _showAlert("Login Failed", "Email or Password is incorrect.");
    } catch (e) {
      _showAlert("Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAlert(String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(61, 67, 89, 1.000),
      body: Stack(
        children: [
          SignInView(
            emailController: _emailController,
            passwordController: _passwordController,
            isPasswordVisible: _isPasswordVisible,
            onTogglePassword: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            onLogin: _handleLogin,
            onRegister: _goToRegister,
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
