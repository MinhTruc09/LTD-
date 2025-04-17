import 'package:flutter/material.dart';
import 'package:movieom_app/views/favorite_screen.dart';
import 'package:movieom_app/views/home_screen.dart';
import 'package:movieom_app/views/profile_screen.dart';
import 'package:movieom_app/views/search_screen.dart';
import 'package:movieom_app/widgets/docking_bar.dart';

class MainScreenPicker extends StatefulWidget {
  const MainScreenPicker({super.key});

  @override
  State<MainScreenPicker> createState() => _MainScreenPickerState();
}

class _MainScreenPickerState extends State<MainScreenPicker> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Trang chu
    SearchScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: DockingBar(
          activeIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          }),
    );
  }
}
