import 'package:flutter/material.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Static song data matching the image
  final List<Map<String, String>> _songs = const [
    {'title': 'Ikot Ikot lang', 'artist': 'Sarah Geronimo'},
    {'title': 'Lord Patawad', 'artist': 'Michael Estal'},
    {'title': 'Kulang Pa Ba', 'artist': 'Regine Velasquez'},
    {'title': 'Pare', 'artist': 'Gilbert Quevedo'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filterSongs(List<Map<String, String>> songs, String query) {
    if (query.isEmpty) {
      return songs;
    }

    final lowerQuery = query.toLowerCase();
    return songs.where((song) {
      final title = song['title']!.toLowerCase();
      final artist = song['artist']!.toLowerCase();
      return title.contains(lowerQuery) || artist.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongs = _filterSongs(_songs, _searchQuery);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Search songs...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: filteredSongs.isEmpty && _searchQuery.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No songs found matching "$_searchQuery"',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(filteredSongs[index]);
              },
            ),
    );
  }

  Widget _buildSongItem(Map<String, String> song) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.music_note,
          color: Colors.blue.shade700,
          size: 24,
        ),
      ),
      title: Text(
        song['title']!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        'by ${song['artist']!}',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite Icon
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
          // Delete Icon
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}