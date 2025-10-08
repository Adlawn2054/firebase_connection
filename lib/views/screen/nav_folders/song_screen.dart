import 'package:flutter/material.dart';

class SongScreen extends StatelessWidget {
  final List<String> songs;
  final List<String> favoriteSongs;
  final void Function(String) onDelete;
  final void Function(String) onToggleFavorite;

  const SongScreen({
    Key? key,
    required this.songs,
    required this.favoriteSongs,
    required this.onDelete,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final song = songs[index];
          final isFavorite = favoriteSongs.contains(song);
          return Card(
            child: ListTile(
              leading: Icon(Icons.music_note, color: Colors.blue),
              title: Text(song),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => onToggleFavorite(song),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => onDelete(song),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
