import 'package:Sleephoria/model/model.dart';
import 'package:Sleephoria/new_firebase_service.dart';
import 'package:Sleephoria/theme.dart';
import 'package:Sleephoria/view/favourite/favouratepage.dart';
import 'package:Sleephoria/view/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Sound page/sound.dart';

class Homepage extends StatefulWidget {
  final int initialTap;
  final String? favMessage;
  final bool? favBool;
  final List<NewSoundModel>? cachedSounds;
  Homepage({super.key,this.initialTap = 0, this.favMessage, this.favBool, this.cachedSounds});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  List<NewSoundModel> soundData = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final List<Widget> _screens =  [
    SoundPage(cachedSounds: widget.cachedSounds,),
    FavoritesPage(
      // currentTitle: _currentPlayingTitle,
      // onTogglePlayback: _togglePlayback,
      // onItemTap: _onFavoriteItemTap,
      title: widget.favMessage ?? '',
      triggerRefresh: widget.favBool ?? false,
    ),
    const ProfilePage(),
  ];

  final List<String> _titles = const ['Sounds', 'Favorites', 'Settings'];

  // String? _currentPlayingTitle;
  // bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTap;

    // _fetchSoundData();
  }

  // Future<void> _fetchSoundData() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });
  //
  //   try {
  //     final sounds = await DatabaseService().fetchSoundData();
  //     if (mounted) {
  //       setState(() {
  //         soundData = sounds;
  //         _screens[0] = const SoundPage();
  //         _screens[1] = FavoritesPage(
  //           // currentTitle: _currentPlayingTitle,
  //           // onTogglePlayback: _togglePlayback,
  //           // onItemTap: _onFavoriteItemTap,
  //           title: widget.favMessage ?? '',
  //           triggerRefresh: widget.favBool ?? false,
  //         );
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = 'Failed to load sounds: $e';
  //         _isLoading = false;
  //       });
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Failed to load sounds: $e')));
  //     }
  //   }
  // }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // void _togglePlayback() {
  //   setState(() {
  //     _isPlaying = !_isPlaying;
  //   });
  // }

  // void _onFavoriteItemTap(NewSoundModel sound) async {
  //   setState(() {
  //     _currentPlayingTitle = sound.title;
  //     _isPlaying = true;
  //     _screens[1] = FavoritesPage(
  //       // currentTitle: _currentPlayingTitle,
  //       // onTogglePlayback: _togglePlayback,
  //       // onItemTap: _onFavoriteItemTap,
  //       message: widget.favMessage ?? '',
  //       triggerRefresh: widget.favBool ?? false,
  //     );
  //   });
  //   await AudioManager().toggleSoundSelection(soundData, sound, false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Recoleta',
            color: ThemeHelper.textColor(context),
          ),
        ),
      ),
      body:
      // _isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : _errorMessage != null
      //     ? Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Text(
      //               _errorMessage!,
      //               style: const TextStyle(fontSize: 16),
      //               textAlign: TextAlign.center,
      //             ),
      //             const SizedBox(height: 16),
      //             ElevatedButton(
      //               onPressed: _fetchSoundData,
      //               child: const Text('Retry'),
      //             ),
      //           ],
      //         ),
      //       )
      //     :
      _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 80),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        unselectedItemColor: const Color.fromRGBO(92, 92, 153, 1.0),
        selectedItemColor: const Color.fromRGBO(190, 190, 245, 1.0),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack_outlined),
            label: 'Sound',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
