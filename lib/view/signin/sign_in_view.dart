import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInView extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isPasswordVisible;
  final VoidCallback onTogglePassword;

  const SignInView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onRegister,
    required this.isPasswordVisible,
    required this.onTogglePassword,
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: ThemeHelper.iconColorRemix(context),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: ThemeHelper.backgroundColor(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: ThemeHelper.loginAndRegisterTitleColor(context),
              ),
            ),

            _buildTextField(
              widget.emailController,
              "Email",
              isDarkMode,
              keyboardType: TextInputType.emailAddress,
            ),

            _buildTextField(
              widget.passwordController,
              "Password",
              isDarkMode,
              obscureText: !widget.isPasswordVisible,
              isPasswordField: true,
              isPasswordVisible: widget.isPasswordVisible,
              onTogglePassword: widget.onTogglePassword,
            ),

            customButton(
              onPressed: widget.onLogin,
              title: "Login",
              backgroundColor: Colors.green,
            ),
            SizedBox(height: 12.h),

            Center(
              child: TextButton(
                onPressed: widget.onRegister,
                style: TextButton.styleFrom(
                  overlayColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
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
      inputFormatters: inputFormatters,
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
          fontWeight: FontWeight.bold,
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

Widget customButton({
  required VoidCallback onPressed,
  required String title,
  Color backgroundColor = Colors.green,
  double height = 50,
  double borderRadius = 8,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: SizedBox(
      width: double.infinity,
      height: height.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
}
