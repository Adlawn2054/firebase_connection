import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // const MainScreen({super.key});
  int _pageIndex = 0;
  final List<Widget> _pages = [
    Center(child: Text("Home Page")),
    Center(child: Text("Music Page")),
    Center(child: Text("Favorite Page")),
    Center(child: Text("User Page")),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/home.png", width: 25),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/music.png", width: 25),
            label: "Music",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/heart.png", width: 25),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/user.png", width: 25),
            label: "User",
          ),
        ],
      ),
    );
  }
}
