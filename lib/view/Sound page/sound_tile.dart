import 'package:Sleephoria/model/model.dart';
import 'package:Sleephoria/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoundTile extends StatelessWidget {
  final NewSoundModel sound;
  final VoidCallback onTap;
  final bool isTrail;

  const SoundTile({
    super.key,
    required this.sound,
    required this.onTap,
    this.isTrail = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool locked =
        !isTrail && sound.isLocked;

    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
            onTap: locked ? null : onTap, 
            leading: SizedBox(
              width: 53.w,
              height: 53.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    width: 2,
                    color: const Color.fromRGBO(176, 176, 224, 1),
                  ),
                  color: sound.isSelected
                      ? const Color.fromRGBO(176, 176, 224, 1)
                      : null,
                ),
                child: Center(
                  child: sound.icon.isNotEmpty
                      ? Image.asset(
                          'assets/images/${sound.icon.endsWith('.png') ? sound.icon : '${sound.icon}.png'}',
                          height: 23.sp,
                          width: 23.sp,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              'Failed to load asset for ${sound.title}: ${sound.icon}',
                            );
                            return const Icon(Icons.music_note);
                          },
                        )
                      : const Icon(Icons.music_note),
                ),
              ),
            ),
            title: Text(
              sound.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: ThemeHelper.soundTitle(context),
              ),
            ),
            trailing: locked
                ? Icon(
                    Icons.lock,
                    color: ThemeHelper.iconColor(context),
                    size: 24,
                  )
                : sound.isSelected
                ? Icon(
                    Icons.check,
                    color: ThemeHelper.iconColor(context),
                    size: 24,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
