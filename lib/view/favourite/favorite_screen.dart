// import 'package:clarity/view/Sound%20page/AudioManager.dart';
// import 'package:clarity/view/favourite/favorite_view.dart';
// import 'package:flutter/material.dart';
//
// class FavoriteScreen extends StatefulWidget {
//   const FavoriteScreen({super.key});
//
//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }
//
// class _FavoriteScreenState extends State<FavoriteScreen> {
//   List<String> favorites = ["Mix Audio 1", "Mix Audio 2"];
//   String? currentMix;
//   bool isPlayingSound = false;
//
//   void togglePlayback() {
//     print("1 : $isSoundPlaying");
//     setState(() {
//       isPlayingSound = !isPlayingSound;
//     });
//     print("2 : $isSoundPlaying");
//   }
//
//   void handleItemTap(String mix) {
//     setState(() {
//       print('Current mix1: $currentMix');
//       if (currentMix == mix) {
//         // toggle play/pause
//         isPlayingSound = !isPlayingSound;
//         print('Current mix2: $currentMix');
//       } else {
//         currentMix = mix;
//         isPlayingSound = true;
//         print('Current mix3: $currentMix');
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FavoriteView(
//       favorites: favorites,
//       currentTitle: currentMix,
//       isPlayingSound: isPlayingSound,
//       onTogglePlayback: togglePlayback,
//       onItemTap: handleItemTap,
//     );
//   }
// }

import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> favorites = ["Mix Audio 1", "Mix Audio 2"];
  String? currentMix;
  bool isPlayingSound = false;

  void togglePlayback() {
    debugPrint("🎧 Before toggle: $isPlayingSound");
    setState(() {
      isPlayingSound = !isPlayingSound;
    });
    debugPrint("🎧 After toggle: $isPlayingSound");
  }

  void handleItemTap(String mix) {
    setState(() {
      debugPrint('📝 Tapped on: $mix | Current: $currentMix');
      if (currentMix == mix) {
        // toggle play/pause
        isPlayingSound = !isPlayingSound;
        debugPrint('⏯ Toggled playback for the same mix');
      } else {
        currentMix = mix;
        isPlayingSound = true;
        debugPrint('▶️ Started playback for: $currentMix');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12162A),
      body: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Favorites",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List or Empty State
          Expanded(
            child: favorites.isEmpty
                ? const Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final title = favorites[index];
                return ListTile(
                  onTap: () => handleItemTap(title),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(
                    currentMix == title && isPlayingSound
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),

          // Player View (Bottom Bar)
          if (currentMix != null)
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1E2C), Color(0xFF2E2E48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentMix!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      debugPrint('🔥 Button tapped ✅');
                      togglePlayback();
                    },
                    icon: Image.asset(
                      isPlayingSound
                          ? "assets/images/pause_icon.png"
                          : "assets/images/play_icon.png",
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

