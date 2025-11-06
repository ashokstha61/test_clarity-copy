import 'package:flutter/material.dart';

class CustomButtonDel extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomButtonDel({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
