import 'package:flutter/material.dart';
import 'package:movieom_app/views/favorite_screen.dart';
import 'package:movieom_app/views/profile_screen.dart';
import 'package:movieom_app/views/search_screen.dart';
import 'package:movieom_app/views/movie_home_screen.dart';
import 'package:movieom_app/widgets/docking_bar.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const MovieHomeScreen(),
    SearchScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: DockingBar(
        activeIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
