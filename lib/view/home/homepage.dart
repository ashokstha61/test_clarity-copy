import 'package:Sleephoria/model/model.dart';
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
  Homepage({super.key,this.initialTap = 0, this.favMessage, this.favBool,});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  List<NewSoundModel> soundData = [];

  late final List<Widget> _screens =  [
     SoundPage(),
    FavoritesPage(
      title: widget.favMessage ?? '',
      triggerRefresh: widget.favBool ?? false,
    ),
    const ProfilePage(),
  ];

  final List<String> _titles = const ['Sounds', 'Favorites', 'Settings'];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTap;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


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
