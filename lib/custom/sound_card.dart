import 'package:flutter/material.dart';

class SoundCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  const SoundCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      elevation: 1,
      child: Container(
        height: 60, 
        width: 70, 
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30, 
              height: 30,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 4), 
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

