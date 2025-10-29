import 'dart:ui' as ui;
import 'package:Sleephoria/view/globals/globals.dart';
import 'package:Sleephoria/model/model.dart';
import 'package:Sleephoria/theme.dart';
import 'package:Sleephoria/view/Sound%20page/sound.dart';
import 'package:Sleephoria/view/favourite/favouratemanager.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../home/homepage.dart';
import 'global_timer.dart';
import '../Sound page/AudioManager.dart';
import 'slider.dart';
import 'timer_screen.dart';
import 'timer_test.dart';

class RelaxationMixPage extends StatefulWidget {
  final List<NewSoundModel> sounds;
  final Function(List<NewSoundModel>) onSoundsChanged;
  const RelaxationMixPage({
    super.key,
    required this.sounds,
    required this.onSoundsChanged,
  });

  @override
  State<RelaxationMixPage> createState() => _RelaxationMixPageState();
}

class _RelaxationMixPageState extends State<RelaxationMixPage> {
  List<NewSoundModel> _selectedSounds = [];
  List<NewSoundModel> _recommendedSounds = [];
  final AudioManager _audioManager = AudioManager();
  final bool _isLoadingRecommendedSounds = false;
  bool showLoading = false;
  ui.Image? thumbImg;

  List<NewSoundModel> _buildUpdatedSounds() {
    debugPrint("update in progress");

    return widget.sounds.map((s) {
      final selectedSound = _selectedSounds.firstWhere(
        (selected) => selected.title == s.title,
        orElse: () => s.copyWith(isSelected: false),
      );

      final isSelected = _selectedSounds.any(
        (selected) => selected.title == s.title,
      );

      return s.copyWith(isSelected: isSelected, volume: selectedSound.volume);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedSounds = widget.sounds
        .where((s) => s.isSelected)
        .map(
          (s) => s.copyWith(
            volume: _audioManager.getSavedVolume(
              s.title,
              defaultValue: s.volume.toDouble(),
            ),
          ),
        )
        .toList();
    _recommendedSounds = widget.sounds.where((s) => !s.isSelected).toList();

    CustomImageThumbShape.loadImage('assets/images/thumb.png').then((img) {
      setState(() {
        thumbImg = img;
      });
    });
  }

  Future<void> _saveMix() async {
    // 1. Validate selected sounds
    if (_selectedSounds.isEmpty) {
      _showErrorSnackBar('Please select at least one sound to save.');
      return;
    }

    // 2. Ask for mix name
    String? mixName = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'Name Your Mix',
                style: TextStyle(
                  fontSize: 20,
                  color: ThemeHelper.textColor(context),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a name for your sound mix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.textColor(context),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'My Sleep Mix',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: ThemeHelper.textFieldFillColor(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    if (mixName == null || mixName.isEmpty) {
      return;
    }

    // 3. Collect selected sound filepaths
    final selectedSoundskoTitle = _selectedSounds
        .map(
          (s) => {
            'title': s.title,
            'volume': _audioManager.getSavedVolume(s.title),
          },
        )
        .toList();

    FavoriteManager.instance.addFavorite(mixName, selectedSoundskoTitle);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Sound saved",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: ThemeHelper.textColor(context),
          ),
        ),
        content: Text(
          "Your customized mix has been saved to your favorites.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ThemeHelper.textColor(context),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => Homepage(
                    initialTap: 1,
                    
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSoundToMix(NewSoundModel sound) async {
    if (_selectedSounds.any((s) => s.title == sound.title)) {
      _showErrorSnackBar('Sound already selected');
      return;
    }

    if (!isTrial && _selectedSounds.isNotEmpty) {
      for (final selectedSound in List.from(_selectedSounds)) {
        await _removeSoundFromMixInternal(selectedSound);
      }
    }

    final normalizedSound = sound.copyWith(
      volume: sound.volume > 0 ? sound.volume : 0.8,
      isSelected: true,
    );

    setState(() {
      _recommendedSounds.removeWhere((s) => s.title == normalizedSound.title);
      _selectedSounds.add(normalizedSound);
    });

    if (_selectedSounds.isNotEmpty) {
      setState(() {
        _audioManager.isPlayingNotifier.value = true;
      });
    }

    final allSounds = _buildUpdatedSounds();

    await _audioManager.playSoundNew(sound.filepath, allSounds);
    await _audioManager.playSound(sound.filepath);

    await _audioManager.adjustVolumes(_selectedSounds);
    _audioManager.saveVolume(
      normalizedSound.title,
      normalizedSound.volume.toDouble(),
    );

    widget.onSoundsChanged(_buildUpdatedSounds());
  }

  Future<void> _removeSoundFromMixInternal(NewSoundModel sound) async {
    try {
      setState(() {
        sound.isSelected = false;

        _selectedSounds.removeWhere((s) {
          if (s.title == sound.title) {
            s.isSelected = false;
            return true;
          }
          return false;
        });

        final originalIndex = widget.sounds.indexWhere(
          (s) => s.title == sound.title,
        );

        if (originalIndex != -1) {
          final insertIndex = _recommendedSounds.indexWhere(
            (s) => widget.sounds.indexOf(s) > originalIndex,
          );

          final resetSound = sound.copyWith(isSelected: false, volume: 1.0);

          if (insertIndex == -1) {
            _recommendedSounds.add(resetSound);
          } else {
            _recommendedSounds.insert(originalIndex, resetSound);
          }
        }
      });

      if (_selectedSounds.isEmpty) {
        setState(() {
          _audioManager.isPlayingNotifier.value = false;
        });
      }

      _audioManager.pauseSound(sound.filepath);
      _audioManager.clearSound(sound.filepath);
      _audioManager.saveVolume(sound.filepath, 1.0);

      widget.onSoundsChanged(_buildUpdatedSounds());

      favIsTapped = true;
    } catch (e) {
      _showErrorSnackBar('Failed to remove sound: $e');
    }
  }

  Future<void> _updateSoundVolume(int index, double volume) async {
    if (index >= _selectedSounds.length) return;

    setState(() {
      _selectedSounds = List.from(_selectedSounds);
      _selectedSounds[index] = _selectedSounds[index].copyWith(volume: volume);
    });
    _audioManager.saveVolume(_selectedSounds[index].title, volume);

    await _audioManager.adjustVolumes(_selectedSounds);
    widget.onSoundsChanged(_buildUpdatedSounds());
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 60,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: ThemeHelper.textTitle(context),
            size: 35,
          ),
          onPressed: () {
            final updated = _buildUpdatedSounds();
            Navigator.pop(context, updated);
          },
        ),
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(
                'Your Relaxation Mix',
                style: TextStyle(
                  color: ThemeHelper.textTitle(context),
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Sounds',
                    style: TextStyle(
                      fontSize: 20,
                      color: ThemeHelper.textTitle(context),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: _isLoadingRecommendedSounds
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommendedSounds.length,
                            itemBuilder: (context, index) {
                              final sound = _recommendedSounds[index];
                              return _buildRecommendedSoundButton(
                                sound,
                                isTrial: isTrial,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Selected Sounds',
                    style: TextStyle(
                      fontSize: 20,
                      color: ThemeHelper.textTitle(context),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedSounds.isEmpty
                        ? const Center(
                            child: Text(
                              'No sounds selected\nTap on recommended sounds to add them',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _selectedSounds.length,
                            itemBuilder: (context, index) {
                              final sound = _selectedSounds[index];
                              return _buildSelectedSoundItem(sound, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 150,
            padding: EdgeInsets.all(16.0.sp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(200, 200, 251, 1),
                  Color.fromRGBO(45, 45, 105, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              color: const Color.fromARGB(194, 194, 244, 244),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 1).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlButton(
                  imagePath: "assets/images/timer_button.png",
                  label: 'Timer',
                  onPressed: () {
                    if (globalTimer.isRunning && globalTimer.remaining > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CircularTimerScreen(
                            duration: globalTimer.remaining > 0
                                ? globalTimer.remaining
                                : (globalTimer.duration ?? 0),
                            soundCount: _selectedSounds.length,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TimerScreen(soundCount: _selectedSounds.length),
                        ),
                      );
                    }
                  },
                  leading: 32.w,
                ),
                _buildPlaybackControls(),
                _buildControlButton(
                  imagePath: "assets/images/saveMix.png",
                  label: 'Save Mix',
                  onPressed: _saveMix,
                  leading: 25.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
    required double leading,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 110.h,
            width: 110.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 5,
                  spreadRadius: -20,
                  offset: Offset(-6.2, -5.7),
                ),
              ],
            ),
            child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
          ),
        ),

        Positioned(
          top: 90,
          left: leading,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _audioManager.isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return Column(
          children: [
            SizedBox(height: 25.h),
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Image.asset(
                _selectedSounds.isEmpty
                    ? "assets/images/pause.png"
                    : isPlaying
                    ? "assets/images/pause.png"
                    : "assets/images/play.png",
                height: 25.sp,
                width: 25.sp,
              ),
              onPressed: _selectedSounds.isEmpty
                  ? null
                  : () async {
                      if (isPlaying) {
                        await AudioManager().pauseAllNew();
                      } else {
                        await AudioManager().playAllNew();
                      }
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedSoundButton(
    NewSoundModel sound, {
    required bool isTrial,
  }) {
    bool locked = false;

    if (!isTrial) {
      locked = sound.isLocked;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: locked ? null : () => _addSoundToMix(sound),
            child: Opacity(
              opacity: locked ? 0.4 : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color.fromARGB(255, 62, 86, 145),
                    width: 2.w,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconImage(sound.icon, 40),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        sound.title.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.textTitle(context),
                          overflow: TextOverflow.ellipsis,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSoundItem(NewSoundModel sound, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _removeSoundFromMixInternal(sound),
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Color.fromARGB(255, 51, 61, 108),
                  width: 2.w,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: _buildIconImage(sound.icon, 24)),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const CircleBorder(),
                        backgroundColor: const Color.fromRGBO(92, 67, 108, 1),
                        elevation: 2,
                        side: const BorderSide(
                          color: Color.fromRGBO(92, 67, 108, 1),
                        ),
                      ),
                      onPressed: () => _removeSoundFromMixInternal(sound),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.sp),
                  child: Text(
                    sound.title.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeHelper.textTitle(context),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: CustomImageThumbShape(
                        thumbRadius: 18.h,
                        thumbImage: thumbImg,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 0,
                      ),
                      trackHeight: 10.h,
                      activeTrackColor: Color.fromRGBO(128, 128, 178, 1),
                      inactiveTrackColor: Color.fromRGBO(113, 109, 150, 1),
                    ),
                    child: Slider(
                      value: sound.volume.toDouble(),
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        _updateSoundVolume(index, value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconImage(String iconName, double size) {
    if (iconName.isEmpty) return _buildFallbackIcon(size);

    final assetPath = _getMatchingAssetPath(iconName);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return _buildFallbackIcon(size);
  }

  String? _getMatchingAssetPath(String iconName) {
    return 'assets/images/$iconName.png';
  }

  Widget _buildFallbackIcon(double size) =>
      Icon(Icons.audiotrack, size: size * 0.7, color: Colors.white70);
}
