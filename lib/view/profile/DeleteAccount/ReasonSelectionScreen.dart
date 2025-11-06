import 'package:flutter/material.dart';

class ReasonSelectionScreen extends StatelessWidget {
  const ReasonSelectionScreen({Key? key}) : super(key: key);

  final List<String> reasons = const [
    "Privacy concerns.",
    "Change in Personal Preferences.",
    "Too time consuming.",
    "Bugs or issues.",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Reason")),
      body: ListView.separated(
        itemCount: reasons.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(reasons[index]),
            onTap: () => Navigator.pop(context, reasons[index]),
          );
        },
      ),
    );
  }
}
