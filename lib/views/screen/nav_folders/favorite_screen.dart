import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  final List<String> favoriteSongs;

  const FavoriteScreen({Key? key, required this.favoriteSongs})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Songs')),
      body: favoriteSongs.isEmpty
          ? const Center(child: Text('No favorite songs yet.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.purple.shade50,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.purple),
                          const SizedBox(width: 10),
                          Text(
                            'Favorite Songs: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            favoriteSongs.length.toString(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteSongs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final song = favoriteSongs[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text(song),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
