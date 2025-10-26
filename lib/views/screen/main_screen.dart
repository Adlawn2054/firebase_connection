import 'package:flutter/material.dart';

import 'package:firebase_connection/views/screen/nav_folders/home_screen.dart';
import 'package:firebase_connection/views/screen/nav_folders/song_screen.dart';
import 'package:firebase_connection/views/screen/nav_folders/favorite_screen.dart';
import 'package:firebase_connection/firebase_code/firestore.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  final FirestoreService _fs = FirestoreService();

  // Example song list
  List<String> songs = [
    'Song One',
    'Song Two',
    'Song Three',
    'Song Four',
    'Song Five',
  ];
  // Favorite songs
  List<String> favoriteSongs = [];

  void deleteSong(String song) {
    setState(() {
      songs.remove(song);
      favoriteSongs.remove(song);
    });
  }

  void toggleFavorite(String song) {
    setState(() {
      if (favoriteSongs.contains(song)) {
        favoriteSongs.remove(song);
      } else {
        favoriteSongs.add(song);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      final List<Widget> _pages = [
      HomeScreen(),
      // SongScreen is now self-contained and reads from Firestore directly.
      SongScreen(),
      FavoriteScreen(favoriteSongs: favoriteSongs),
      Center(child: Text("User Page")),
    ];
    return Scaffold(
      body: _pages[_pageIndex],
      floatingActionButton: _pageIndex == 1
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final controller = TextEditingController();
                final title = await showDialog<String?>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add song'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Song title'),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
                    ],
                  ),
                );

                if (title != null && title.isNotEmpty) {
                  try {
                    await _fs.addSong(title);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song added')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add failed: $e')));
                  }
                }
              },
            )
          : null,
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
