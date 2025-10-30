import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyFile extends StatelessWidget {
  const EmptyFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100.h),
        Image(image: AssetImage('assets/images/empty-min.png'), height: 200),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'You don\'t have any sounds saved. Make your own mix and save it to view here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: ThemeHelper.textSubtitle(context),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
