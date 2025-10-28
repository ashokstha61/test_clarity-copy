import 'package:Sleephoria/model/favSoundModel.dart';
import 'package:Sleephoria/model/model.dart';
import 'package:Sleephoria/view/favourite/empty_file.dart';
import 'package:Sleephoria/view/favourite/favorite_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../globals.dart';
import '../../new_firebase_service.dart';
import '../Sound page/AudioManager.dart';

class FavoritesPage extends StatefulWidget {
  final String? currentTitle;

  final VoidCallback onTogglePlayback;
  final Function(NewSoundModel) onItemTap;

  const FavoritesPage({
    super.key,
    this.currentTitle,
    required this.onTogglePlayback,
    required this.onItemTap,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static List<FavSoundModel>? _cachedFavSounds;
  List<FavSoundModel> favoriteSounds = [];
  List<NewSoundModel> Sounds = [];
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager();
  String? currentMix;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_cachedFavSounds != null) {
      favoriteSounds = _cachedFavSounds!;
    } else {
      _loadFavorites();
    }
    _loadSounds();
    setState(() {
      currentMix = _audioManager.currentMix;
    });
  }

  Future<void> _loadFavorites() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final favData = await _firebaseService.loadMixes(userId.toString());

    setState(() {
      favoriteSounds = favData;
      _cachedFavSounds = favData;
      _isLoading = false;
    });
  }

  Future<void> _loadSounds() async {
    try {
      final sounds = await _firebaseService.fetchSoundData();
      for (var sound in sounds) {
        sound.isSelected = _audioManager.selectedSoundTitles.contains(
          sound.title,
        );
      }

      setState(() {
        Sounds = sounds;
      });
    } catch (e) {
      debugPrint("Failed to load sounds: $e");
    }
  }

  void _onFavoriteTap(
    String mixName,
    List<Map<String, dynamic>> soundTitles,
  ) async {
    setState(() {
      currentMix = mixName;
      isPlayingMix = true;
      _audioManager.currentMix = mixName;
      // _audioManager.isPlaying = true;
    });

    final selectedSounds = Sounds.map((s) {
      final match = soundTitles.firstWhere(
        (map) => map['title'] == s.title,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        // Restore saved volume if available
        final savedVolume = (match['volume'] as num?)?.toDouble() ?? s.volume;
        return s.copyWith(volume: savedVolume);
      }

      return s;
    }).where((s) => soundTitles.any((map) => map['title'] == s.title)).toList();

    if (selectedSounds.isEmpty) {
      debugPrint("⚠️ No matching sounds found for $mixName");
      return;
    }

    await AudioManager().playFavSounds(Sounds, soundTitles);
    await AudioManager().playAllFav();
    if (!mounted) return;
    // setState(() {
    //   for (var s in Sounds) {
    //     s.isSelected = selectedSounds.any((sel) => sel.title == s.title);
    //   }
    // });
  }

  void _togglePlayback() async {
    if (currentMix != null) {
      if (isPlayingMix) {
        setState(() => isPlayingMix = false);
        // _audioManager.isPlaying = false;
        await AudioManager().pauseAllFav();
      } else {
        setState(() => isPlayingMix = true);
        // _audioManager.isPlaying = true;
        await AudioManager().playAllFav();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return Scaffold(body: Center(child: CircularProgressIndicator()));
    // }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5.h),

            Expanded(
              child: !_isLoading
                  ? favoriteSounds.isNotEmpty
                        ? ListView.builder(
                            itemCount: favoriteSounds.length,
                            itemBuilder: (context, index) {
                              final favSound = favoriteSounds[index];
                              final mixName = favSound.favSoundTitle;
                              final soundTitles = favSound.soundTitles;
                              return FavoriteTile(
                                title: mixName,
                                onTap: () =>
                                    _onFavoriteTap(mixName, soundTitles),
                              );
                            },
                          )
                        : EmptyFile()
                  : const Center(
                      child: CircularProgressIndicator(),
                    ), // Show loading
            ),

            // Expanded(
            //   child: FutureBuilder<List<FavSoundModel>>(
            //     future: _firebaseService.loadMixes(
            //       FirebaseAuth.instance.currentUser!.uid,
            //     ),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       }

            //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //         return const EmptyFile();
            //       }

            //       final favoriteSounds = snapshot.data!;

            //       return ListView.builder(
            //         itemCount: favoriteSounds.length,
            //         itemBuilder: (context, index) {
            //           final favSound = favoriteSounds[index];
            //           final mixName = favSound.favSoundTitle;
            //           final soundTitles = favSound.soundTitles;
            //           return FavoriteTile(
            //             title: mixName,
            //             onTap: () => _onFavoriteTap(mixName, soundTitles),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
            if (currentMix != null)
              Container(
                height: 60.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 61, 61, 147),
                      Color.fromARGB(255, 64, 64, 144),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentMix!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Image.asset(
                        isPlayingMix
                            ? "assets/images/pause.png"
                            : "assets/images/play.png",
                        width: 28.w,
                        height: 28.h,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
