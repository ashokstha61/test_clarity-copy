import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        height: 60.h, 
        width: 70.w, 
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30.w, 
              height: 30.h,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 4.h), 
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
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

