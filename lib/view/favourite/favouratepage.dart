import 'package:Sleephoria/model/favSoundModel.dart';
import 'package:Sleephoria/model/model.dart';
import 'package:Sleephoria/view/favourite/empty_file.dart';
import 'package:Sleephoria/view/favourite/favorite_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../globals/globals.dart';
import '../../new_firebase_service.dart';
import '../Sound page/AudioManager.dart';

class FavoritesPage extends StatefulWidget {
  // final String? currentTitle;
  // final VoidCallback onTogglePlayback;
  // final Function(NewSoundModel) onItemTap;
  final String title;
  bool triggerRefresh;

  FavoritesPage({
    super.key,
    // this.currentTitle,
    // required this.onTogglePlayback,
    // required this.onItemTap,
    required this.title,
    this.triggerRefresh = false,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static List<FavSoundModel>? _cachedFavSounds;
  static List<NewSoundModel>? _cachedSounds;
  List<FavSoundModel> favoriteSounds = [];
  List<NewSoundModel> Sounds = [];
  final DatabaseService _firebaseService = DatabaseService();
  final AudioManager _audioManager = AudioManager();
  String? currentMix;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    playAftersSave();
    if (_cachedFavSounds != null && _cachedSounds != null) {
      favoriteSounds = _cachedFavSounds!;
      Sounds = _cachedSounds!;
    } else {
      _loadFavorites();
      _loadSounds();
    }

    setState(() {
      currentMix = _audioManager.currentMix;
    });
  }

  Future<void> playAftersSave() async {

    print(widget.triggerRefresh);
    if (widget.triggerRefresh){
      await _loadFavorites();
      await _loadSounds();
      for (var sound in favoriteSounds){
        if (sound.favSoundTitle == widget.title) {
          _onFavoriteTap(widget.title, sound.soundTitles);
        }
      }
      setState(() {
        widget.triggerRefresh = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final favData = await _firebaseService.loadMixes(userId.toString());

    if (isPlayingMix) {
      setState(() => isPlayingMix = false);
      await AudioManager().pauseAllFav();
    }

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
        _cachedSounds = sounds;
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
    });

    debugPrint("All sounds: ${Sounds.map((e) => e.title).toList()}");
    debugPrint("Mix soundTitles: ${soundTitles.map((e) => e['title']).toList()}");

    final selectedSounds = Sounds.where((s) {
      final match = soundTitles.firstWhere(
            (map) => map['title'] == s.title,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        s = s.copyWith(volume: (match['volume'] as num?)?.toDouble() ?? s.volume);
        return true;
      }
      return false;
    }).toList();

    if (selectedSounds.isEmpty) {
      debugPrint("⚠️ No matching sounds found for $mixName");
      return;
    }

    if (selectedSounds.isEmpty) {
      debugPrint("⚠️ No matching sounds found for $mixName");
      return;
    }

    await AudioManager().playFavSounds(Sounds, soundTitles);
    await AudioManager().playAllFav();
    // setState(() {
      favIsTapped = true;
    // });
    if (!mounted) return;
  }

  void _togglePlayback() async {
    if (currentMix != null) {
      if (isPlayingMix) {
        setState(() => isPlayingMix = false);
        await AudioManager().pauseAllFav();
      } else {
        setState(() => isPlayingMix = true);
        await AudioManager().playAllFav();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFavorites,
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
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),

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
