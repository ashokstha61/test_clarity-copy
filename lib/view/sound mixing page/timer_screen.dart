import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'timer_test.dart';

class TimerScreen extends StatelessWidget {
  final int soundCount;

  const TimerScreen({
    super.key,
    required this.soundCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeHelper.timerscreenBackgrundColor(context),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.music_note,
              size: 20.sp,
              color: ThemeHelper.textColorTimer(context),
            ),
            Positioned(
              right: 0, 
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2.sp),

                child: Text(
                  "$soundCount", 
                  style: TextStyle(
                    color: ThemeHelper.textColorTimer(context),
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          'Timer',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: ThemeHelper.textColorTimer(context),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, size: 20.sp),
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
        ],
      ),
      backgroundColor: ThemeHelper.timerscreenBackgrundColor(context),
      body: Container(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.sp),
                child: Text(
                  'Choose your timer duration',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'montserrat',
                    color: ThemeHelper.textColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              ...[5, 10, 15, 30, 60, 120, 240, 480].map((minutes) {
                return Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity(vertical: -4),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      title: Text(
                        (minutes ~/ 60 > 0)
                            ? '${minutes ~/ 60} Hour${minutes ~/ 60 > 1 ? 's' : ''}'
                            : '$minutes Minutes',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: ThemeHelper.textColorTimer(context),
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                       
                        minutes * 60;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CircularTimerScreen(
                              duration: minutes * 60,
                              soundCount: soundCount,
                            ),
                          ),
                        ); 
                      },
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                    ), 
                  ],
                );
              }),
              if ([5, 10, 15, 30, 60, 120, 240, 480].isNotEmpty)
                SizedBox(height: 16.h), 
            ],
          ),
        ),
      ),
    );
  }
}
