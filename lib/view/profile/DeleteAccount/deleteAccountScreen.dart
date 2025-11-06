import 'package:Sleephoria/view/login/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../custom/CustomButtonDel.dart';
import '../../login/auth.dart';
import 'NonEditableTextField.dart';
import 'ReasonSelectionScreen.dart';
import 'TermsAndConditionsScreen.dart';
import 'dialog_utils.dart';


class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? selectedReason;
  bool isLoading = false;

  void _showReasonSelector() async {
    final reason = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ReasonSelectionScreen()),
    );
    if (reason != null) {
      setState(() => selectedReason = reason);
    }
  }

  void _openTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
    );
  }

  Future<void> _disableAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showAlert(context, "Error", "No user logged in.");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isDisabled': true,
        'disableReason': selectedReason
      });

      debugPrint("✅ Account disabled successfully");

      // Clear app data and logout
      // FavSoundManager.instance.clear();
      // SoundManager.instance.stopAll();

      _logout(context);

    } catch (e) {
      showAlert(context, "Error", "Failed to disable account: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    setState(() {
      AuthService().signOut();
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _confirmDeletion() {
    if (selectedReason == null || selectedReason!.isEmpty) {
      showAlert(context, "Missing Reason", "Please select a reason before continuing.");
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disableAccount();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termsText = RichText(
      text: TextSpan(
        text:
        "According to regulations, we must retain your data for 5 years. Please note that once you delete your account, you won't be able to access your data. Please review ",
        style: TextStyle(fontSize: 14.sp),
        children: [
          TextSpan(
            text: "terms and conditions",
            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 14.sp),
            recognizer: TapGestureRecognizer()..onTap = _openTerms,
          ),
          TextSpan(text: " for additional details before proceeding.",
          style: TextStyle(fontSize: 14.sp)
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Account Closure Request")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text("Before You Delete", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "We're sorry you're leaving. Share your reason for account deletion, and we might assist with common issues.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text("Reason to delete Account?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Reason*", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                NonEditableTextField(
                  hintText: "Select your reason",
                  value: selectedReason,
                  onTap: _showReasonSelector,
                ),
                const SizedBox(height: 16),
                const Text("Terms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                termsText,
                const SizedBox(height: 40),
                CustomButtonDel(title: "Continue", onPressed: _confirmDeletion),
              ],
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
