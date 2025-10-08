// import 'package:clarity/model/favSoundModel.dart';
// import 'package:clarity/model/model.dart';
// import 'package:clarity/view/favourite/empty_file.dart';
// import 'package:clarity/view/favourite/favorite_tile.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../new_firebase_service.dart';
// import '../Sound page/AudioManager.dart';

// class FavoritesPage extends StatefulWidget {
//   final String? currentTitle;
//   final bool isPlaying;
//   final VoidCallback onTogglePlayback;
//   final Function(NewSoundModel) onItemTap;

//   const FavoritesPage({
//     super.key,
//     this.currentTitle,
//     this.isPlaying = false,
//     required this.onTogglePlayback,
//     required this.onItemTap,
//   });

//   @override
//   State<FavoritesPage> createState() => _FavoritesPageState();
// }

// class _FavoritesPageState extends State<FavoritesPage> {
//   List<FavSoundModel> favoriteSounds = [];
//   // ignore: non_constant_identifier_names
//   List<NewSoundModel> Sounds = [];
//   final DatabaseService _firebaseService = DatabaseService();
//   final AudioManager _favoriteAudioManager = AudioManager();
//   String? currentMix;
//   bool isPlaying = false;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//     _loadSounds();
//     // _loadData();
//     setState(() {
//       currentMix = _favoriteAudioManager.currentMix;
//       isPlaying = _favoriteAudioManager.isPlaying;
//     });
//   }

//   // Future<void> _loadData() async {
//   //   await _loadFavorites();
//   //   await _loadSounds();
//   // }

//   Future<void> _loadFavorites() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     final favData = await _firebaseService.loadMixes(userId.toString());
//     setState(() {
//       favoriteSounds = favData;
//     });
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _loadSounds() async {
//     try {
//       final sounds = await _firebaseService.fetchSoundData();
//       for (var sound in sounds) {
//         sound.isSelected = _favoriteAudioManager.selectedSoundTitles.contains(
//           sound.title,
//         );
//       }

//       setState(() {
//         Sounds = sounds;
//       });
//     } catch (e) {
//       debugPrint("Failed to load sounds: $e");
//     }
//   }

//   // void _onFavoriteTap(String mixName, List<Map<String, dynamic>> soundTitles) async {
//   //   setState(() {
//   //     currentMix = mixName;
//   //     isPlaying = true;
//   //   });

//   //   final selectedSounds = Sounds.where(
//   //     (s) => soundTitles.contains(s.title),
//   //   ).toList();

//   //   if (selectedSounds.isEmpty) {
//   //     debugPrint("⚠️ No matching sounds found for $mixName");
//   //     return;
//   //   }

//   //   await AudioManager().ensurePlayers(selectedSounds);
//   //   await AudioManager().syncPlayers(selectedSounds);
//   //   await AudioManager().playAll();
//   // }
//   void _onFavoriteTap(
//     String mixName,
//     List<Map<String, dynamic>> soundTitles,
//   ) async {
//     setState(() {
//       currentMix = mixName;
//       isPlaying = true;

//       _favoriteAudioManager.currentMix = mixName;
//       _favoriteAudioManager.isPlaying = true;
//     });

//     // Match saved favorite sounds to actual NewSoundModel instances
//     final selectedSounds = Sounds.map((s) {
//       final match = soundTitles.firstWhere(
//         (map) => map['title'] == s.title,
//         orElse: () => {},
//       );

//       if (match.isNotEmpty) {
//         // Restore saved volume if available
//         final savedVolume = (match['volume'] as num?)?.toDouble() ?? s.volume;
//         return s.copyWith(volume: savedVolume);
//       }

//       return s;
//     }).where((s) => soundTitles.any((map) => map['title'] == s.title)).toList();

//     if (selectedSounds.isEmpty) {
//       debugPrint("⚠️ No matching sounds found for $mixName");
//       return;
//     }

//     // Ensure audio players are ready
//     await AudioManager().ensurePlayers(selectedSounds);
//     await AudioManager().syncPlayers(selectedSounds);

//     // Play all selected sounds
//     await AudioManager().playAll();

//     // Update the main sounds list to reflect selection
//     if (!mounted) return;
//     setState(() {
//       for (var s in Sounds) {
//         s.isSelected = selectedSounds.any((sel) => sel.title == s.title);
//       }
//     });
//   }

//   void _togglePlayback() async {
//     if (currentMix != null) {
//       if (isPlaying) {
//         setState(() => isPlaying = false);
//         _favoriteAudioManager.isPlaying = false;
//         await AudioManager().pauseAll();
//       } else {
//         setState(() => isPlaying = true);
//         _favoriteAudioManager.isPlaying = true;
//         await AudioManager().playAll();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 5.h),
//             Expanded(
//               child: favoriteSounds.isEmpty
//                   ? const EmptyFile()
//                   : ListView.builder(
//                       itemCount: favoriteSounds.length,
//                       itemBuilder: (context, index) {
//                         final favSound = favoriteSounds[index];
//                         final mixName = favSound.favSoundTitle;
//                         final soundTitles = favSound.soundTitles;
//                         return FavoriteTile(
//                           title: mixName,
//                           onTap: () => _onFavoriteTap(mixName, soundTitles),
//                         );
//                       },
//                     ),
//             ),
//             if (currentMix != null)
//               Container(
//                 height: 60.h,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromARGB(255, 61, 61, 147),
//                       Color.fromARGB(255, 64, 64, 144),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 25.sp),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       currentMix!,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontFamily: "Montserrat",
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: _togglePlayback,
//                       icon: Image.asset(
//                         isPlaying
//                             ? "assets/images/pause.png"
//                             : "assets/images/play.png",
//                         width: 28.w,
//                         height: 28.h,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:clarity/model/favSoundModel.dart';
import 'package:clarity/model/model.dart';
import 'package:clarity/view/favourite/empty_file.dart';
import 'package:clarity/view/favourite/favorite_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../new_firebase_service.dart';
import '../Sound page/audio_manager.dart';

class FavoritesPage extends StatefulWidget {
  final String? currentTitle;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final Function(NewSoundModel) onItemTap;

  const FavoritesPage({
    super.key,
    this.currentTitle,
    this.isPlaying = false,
    required this.onTogglePlayback,
    required this.onItemTap,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavSoundModel> favoriteSounds = [];
  List<NewSoundModel> sounds = [];
  final DatabaseService _firebaseService = DatabaseService();

  // ✅ Separate AudioManager for FavoritesPage
  static final AudioManager _favoriteAudioManager = AudioManager();
  String? currentMix;

  bool isfavPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSounds();

    currentMix = _favoriteAudioManager.currentMix;
    isfavPlaying = _favoriteAudioManager.isPlaying;
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final favData = await _firebaseService.loadMixes(userId.toString());
    setState(() {
      favoriteSounds = favData;
      _isLoading = false;
    });
  }

  Future<void> _loadSounds() async {
    try {
      final fetchedSounds = await _firebaseService.fetchSoundData();
      for (var sound in fetchedSounds) {
        sound.isSelected = _favoriteAudioManager.selectedSoundTitles.contains(
          sound.title,
        );
      }
      setState(() {
        sounds = fetchedSounds;
      });
    } catch (e) {
      debugPrint("Failed to load sounds: $e");
    }
  }

  void _togglePlayback() async {
    if (currentMix != null) {
      if (isfavPlaying) {
        setState(() {
          isfavPlaying = false;
          _favoriteAudioManager.isPlaying = false;
        });
        await _favoriteAudioManager.pauseAll();
      } else {
        setState(() {
          isfavPlaying = true;
          _favoriteAudioManager.isPlaying = true;
        });
        await _favoriteAudioManager.playAll();
      }
    }
  }

  void _onFavoriteTap(
    String mixName,
    List<Map<String, dynamic>> soundTitles,
  ) async {
    setState(() {
      currentMix = mixName;
      isfavPlaying = true;
      _favoriteAudioManager.currentMix = mixName;
      _favoriteAudioManager.isPlaying = true;
    });

    // Match saved favorite sounds to actual NewSoundModel instances
    final selectedSounds = sounds
        .map((s) {
          final match = soundTitles.firstWhere(
            (map) => map['title'] == s.title,
            orElse: () => {},
          );

          if (match.isNotEmpty) {
            final savedVolume =
                (match['volume'] as num?)?.toDouble() ?? s.volume;
            return s.copyWith(volume: savedVolume);
          }

          return s;
        })
        .where((s) => soundTitles.any((map) => map['title'] == s.title))
        .toList();

    if (selectedSounds.isEmpty) {
      debugPrint("⚠️ No matching sounds found for $mixName");
      return;
    }

    // ✅ Use the separate AudioManager
    await _favoriteAudioManager.ensurePlayers(selectedSounds);
    await _favoriteAudioManager.syncPlayers(selectedSounds);
    await _favoriteAudioManager.playAll();

    // Update the main sounds list to reflect selection locally
    if (!mounted) return;
    setState(() {
      for (var s in sounds) {
        s.isSelected = selectedSounds.any((sel) => sel.title == s.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Expanded(
              child: favoriteSounds.isEmpty
                  ? const EmptyFile()
                  : ListView.builder(
                      itemCount: favoriteSounds.length,
                      itemBuilder: (context, index) {
                        final favSound = favoriteSounds[index];
                        final mixName = favSound.favSoundTitle;
                        final soundTitles = favSound.soundTitles;
                        return FavoriteTile(
                          title: mixName,
                          onTap: () => _onFavoriteTap(mixName, soundTitles),
                        );
                      },
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
                        isfavPlaying
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
