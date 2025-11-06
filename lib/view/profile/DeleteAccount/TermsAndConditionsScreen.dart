import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  final String termsText = """
Welcome to Bill Cha. By accessing or using this application, you agree to be bound by these Terms and Conditions...

You must be at least 18 years old or have parental consent to use this app.

We value your privacy. The app collects and stores data according to our Privacy Policy.

We may retain billing and invoice records for up to 5 years.

By deleting your account, personal access is revoked, but essential data may be retained as required by law.

All content within this app is the intellectual property of Bill Cha or its licensors.

We may suspend your account for misuse or suspicious activity.

This app is provided "as is" without warranties of any kind.

For questions, contact us at admin@meekha.co.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(termsText, style: const TextStyle(fontSize: 16, height: 1.5)),
        ),
      ),
    );
  }
}
