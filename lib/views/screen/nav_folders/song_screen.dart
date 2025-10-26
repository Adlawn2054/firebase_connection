import 'package:flutter/material.dart';
import '../../../firebase_code/firestore.dart';

/// A live-updating screen that reads songs from Firestore and
/// allows toggling favorites and deleting songs.
class SongScreen extends StatefulWidget {
  const SongScreen({Key? key}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final FirestoreService _service = FirestoreService();

  Future<void> _onDelete(String title) async {
    try {
      await _service.deleteSongByTitle(title);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _onToggleFavorite(String title) async {
    try {
      await _service.toggleFavoriteByTitle(title);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Music'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs', icon: Icon(Icons.music_note)),
              Tab(text: 'Users', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Songs tab (existing)
            StreamBuilder<List<Song>>(
              stream: _service.songsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final songs = snapshot.data ?? <Song>[];

                if (songs.isEmpty) {
                  return const Center(child: Text('No songs yet'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isFavorite = song.isFavorite;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.music_note, color: Colors.blue),
                        title: Text(song.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _onToggleFavorite(song.title),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _onDelete(song.title),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Users tab
            StreamBuilder<List<Singer>>(
              stream: _service.singersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? <Singer>[];

                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }                                                                                                             

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        // show avatar or initial
                        leading: user.photoUrl.isNotEmpty
                            ? CircleAvatar(backgroundImage: NetworkImage(user.photoUrl))
                            : CircleAvatar(child: Text(user.displayName.isNotEmpty ? user.displayName[0] : '?')),
                        // display only the name
                        title: Text(user.displayName.isNotEmpty ? user.displayName : '(no name)'),
                        // edit and delete buttons
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () async {
                                final controller = TextEditingController(text: user.displayName);
                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Edit name'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(labelText: 'Name'),
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                                    ],
                                  ),
                                );

                                if (newName != null && newName.isNotEmpty && newName != user.displayName) {
                                  try {
                                    await _service.updateSingerName(user.id, newName);
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete user'),
                                    content: const Text('Are you sure you want to delete this user? This cannot be undone.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _service.deleteSingerById(user.id);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
