import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple Song model mapping a Firestore document to a Dart object.
class Song {
	final String id;
	final String title;
	final bool isFavorite;
	final String? artist;

	Song({required this.id, required this.title, required this.isFavorite, this.artist});

	factory Song.fromDoc(DocumentSnapshot doc) {
		final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
		final title = (data['title'] ?? '') as String;
		
		// Parse artist from title if it contains "by"
		String? artistName;
		if (title.toLowerCase().contains(' by ')) {
			final parts = title.split(' by ');
			if (parts.length >= 2) {
				artistName = parts.sublist(1).join(' by ').trim();
			}
		} else if (data['artist'] != null) {
			artistName = data['artist']?.toString();
		}
		
		return Song(
			id: doc.id,
			title: title,
			isFavorite: (data['isFavorite'] ?? false) as bool,
			artist: artistName,
		);
	}

	// Get clean title without artist
	String get cleanTitle {
		if (title.toLowerCase().contains(' by ')) {
			return title.split(' by ')[0].trim();
		}
		return title;
	}

	Map<String, dynamic> toJson() => {
				'title': title,
				'isFavorite': isFavorite,
				if (artist != null) 'artist': artist,
			};
}

/// Firestore service for 'songs' collection.
///
/// Conventions used by this service:
/// - Collection: `songs`
/// - Document fields: `title` (String), `isFavorite` (bool)
/// If your DB uses different field names, update them here.
class FirestoreService {
	final FirebaseFirestore _db;

	FirestoreService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

	/// Stream of all songs as `Song` objects.
	Stream<List<Song>> songsStream() {
		return _db.collection('songs').snapshots().map((snap) =>
				snap.docs.map((doc) => Song.fromDoc(doc)).toList(growable: false));
	}

	/// Stream of titles (List<String>) – convenient for the current `SongScreen` widget.
	Stream<List<String>> songTitlesStream() =>
			songsStream().map((list) => list.map((s) => s.title).toList(growable: false));

	/// Stream of favorite song titles.
	Stream<List<String>> favoriteSongTitlesStream() {
		return _db
				.collection('songs')
				.where('isFavorite', isEqualTo: true)
				.snapshots()
				.map((snap) => snap.docs.map((d) => (d.data()['title'] ?? '') as String).toList(growable: false));
	}

	/// Stream of favorite songs as `Song` objects.
	Stream<List<Song>> favoriteSongsStream() {
		return _db
				.collection('songs')
				.where('isFavorite', isEqualTo: true)
				.snapshots()
				.map((snap) => snap.docs.map((doc) => Song.fromDoc(doc)).toList(growable: false));
	}

	/// Add a new song. If you want to use the title as document id, change this to `.doc(title).set(...)`.
	Future<void> addSong(String title) async {
		await _db.collection('songs').add({'title': title, 'isFavorite': false});
	}

	/// Delete song(s) with the given title.
	///
	/// Note: this finds documents where `title` equals the provided string and deletes them.
	Future<void> deleteSongByTitle(String title) async {
		final query = await _db.collection('songs').where('title', isEqualTo: title).get();
		for (final doc in query.docs) {
			await doc.reference.delete();
		}
	}

	/// Toggle the `isFavorite` field for song(s) matching the title.
	Future<void> toggleFavoriteByTitle(String title) async {
		final query = await _db.collection('songs').where('title', isEqualTo: title).get();
		for (final doc in query.docs) {
			final data = doc.data();
			final current = (data['isFavorite'] ?? false) as bool;
			await doc.reference.update({'isFavorite': !current});
		}
	}

	/// Delete song by document ID.
	Future<void> deleteSongById(String id) async {
		await _db.collection('songs').doc(id).delete();
	}

	/// Toggle the `isFavorite` field for a song by document ID.
	Future<void> toggleFavoriteById(String id) async {
		final doc = await _db.collection('songs').doc(id).get();
		if (doc.exists) {
			final data = doc.data()!;
			final current = (data['isFavorite'] ?? false) as bool;
			await doc.reference.update({'isFavorite': !current});
		}
	}

	/// Optional helper: get a one-time list of song titles (non-stream).
	Future<List<String>> getSongTitlesOnce() async {
		final snap = await _db.collection('songs').get();
		return snap.docs.map((d) => (d.data()['title'] ?? '') as String).toList(growable: false);
	}



		/// Stream of singers (users) from the `singers` collection.
		Stream<List<Singer>> singersStream() {
					return _db.collection('singers').snapshots().map((snap) =>
							snap.docs.map((doc) => Singer.fromDoc(doc)).toList(growable: false));
		}

		/// Delete singer by document id (uid).
		Future<void> deleteSingerById(String uid) async {
					await _db.collection('singers').doc(uid).delete();
		}

			/// Update a singer's display name. Also write to legacy 'name' field
			/// for backward compatibility with older documents/code paths.
			Future<void> updateSingerName(String uid, String newName) async {
				await _db.collection('singers').doc(uid).update({'displayName': newName, 'name': newName});
			}
}
	/// Simple model for a user (singer) document. This maps both old and new
	/// field names ('name' or 'displayName', 'profileImage' or 'photoUrl').
	class Singer {
		final String id;
		final String displayName;
		final String photoUrl;
		final String city;

		Singer({required this.id, required this.displayName, required this.photoUrl, required this.city});

		factory Singer.fromDoc(DocumentSnapshot doc) {
			final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
			final displayName = (data['displayName'] ?? data['name'] ?? '') as String;
			final photoUrl = (data['photoUrl'] ?? data['profileImage'] ?? '') as String;
			final city = (data['city'] ?? '') as String;
			return Singer(id: doc.id, displayName: displayName, photoUrl: photoUrl, city: city);
		}
	}