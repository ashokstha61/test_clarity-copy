import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPhoneValid = true;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(() {
      if (_phoneController.text.length > 10) {
        setState(() => _isPhoneValid = false);
      } else {
        setState(() => _isPhoneValid = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showAlert("Invalid Input", "Please enter your full name.");
      return;
    }

    if (phone.isNotEmpty && phone.length != 10) {
      _showAlert("Invalid Input", "Phone number must be exactly 10 digits.");
      return;
    }

    if (email.isEmpty) {
      _showAlert("Invalid Input", "Email is required.");
      return;
    } else if (!_isValidEmail(email)) {
      _showAlert("Error", "Please enter a valid email address.");
      return;
    }

    if (password.isEmpty) {
      _showAlert("Invalid Input", "Password is required.");
      return;
    } else if (password.length < 6) {
      _showAlert("Error", "Password must be at least 6 characters long.");
      return;
    } else if (password.contains(' ')) {
      _showAlert("Error", "Password should not contain spaces.");
      return;
    } else if (!_isValidEmail(email)) {
      _showAlert("Error", "Please enter a valid email address.");
      return;
    }

    if (confirmPassword.isEmpty) {
      _showAlert("Invalid Input", "Please confirm your password.");
      return;
    } else if (password != confirmPassword) {
      _showAlert("Error", "Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "fullName": name,
        "phone": phone,
        "email": email,
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showAlert("Success", "Registered successfully.", () {
        Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showAlert(
          "Error",
          "This email is already registered. Please use another email or login.",
        );
      } else {
        _showAlert("Error", e.message ?? "Registration failed.");
      }
    } catch (e) {
      _showAlert("Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
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
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.registerTextColor(context),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  _buildTextField(_nameController, "Full Name", isDarkMode),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    isDarkMode,
                    keyboardType: TextInputType.phone,
                    borderColor: _isPhoneValid ? null : Colors.red,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  _buildTextField(
                    _emailController,
                    "Email",
                    isDarkMode,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    _passwordController,
                    "Password",
                    isDarkMode,
                    obscureText: !_isPasswordVisible,
                    isPasswordField: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  _buildTextField(
                    _confirmPasswordController,
                    "Confirm Password",
                    isDarkMode,
                    obscureText: !_isConfirmPasswordVisible,
                    isPasswordField: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),

                  customRegistrationButton(
                    onPressed: _registerUser,
                    title: "Register",
                    backgroundColor: Colors.blueAccent,
                    height: 50.h,
                    borderRadius: 8.r,
                    fontSize: 16,
                    textColor: Colors.white,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: const Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

Widget _buildTextField(
  TextEditingController controller,
  String label,
  bool isDarkMode, {
  bool obscureText = false,
  bool isPasswordField = false,
  VoidCallback? onTogglePassword,
  bool isPasswordVisible = false,
  TextInputType? keyboardType,
  Color? borderColor,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        floatingLabelStyle: TextStyle(
          color: isDarkMode ? Colors.grey : Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color:
                borderColor ?? (isDarkMode ? Colors.white54 : Colors.black26),
          ),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    ),
  );
}

Widget customRegistrationButton({
  required VoidCallback onPressed,
  required String title,
  Color backgroundColor = Colors.blueAccent,
  double height = 50,
  double borderRadius = 8,
  double fontSize = 16,
  Color textColor = Colors.white,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: SizedBox(
      width: double.infinity,
      height: height.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize.sp, color: textColor),
        ),
      ),
    ),
  );
}
