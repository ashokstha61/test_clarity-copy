import 'package:flutter/material.dart';

class NonEditableTextField extends StatelessWidget {
  final String hintText;
  final String? value;
  final VoidCallback onTap;

  const NonEditableTextField({
    Key? key,
    required this.hintText,
    required this.onTap,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.black,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          controller: TextEditingController(text: value,),
          readOnly: true,
        ),
      ),
    );
  }
}
