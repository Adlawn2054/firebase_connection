import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_connection/controllers/auth_controller.dart';
import 'package:firebase_connection/views/screen/nav_folders/add_user_screen.dart';
import 'package:firebase_connection/views/screen/nav_folders/edit_user_screen.dart';
import 'package:flutter/material.dart';

class UserAccountScreent extends StatefulWidget {
  const UserAccountScreent({super.key});

  @override
  State<UserAccountScreent> createState() => _UserAccountScreentState();
}

class _UserAccountScreentState extends State<UserAccountScreent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> users, String query) {
    if (query.isEmpty) {
      return users;
    }

    final lowerQuery = query.toLowerCase();
    return users.where((userDoc) {
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get name
      final displayName = (userData['displayName'] ?? userData['name'] ?? '').toString().toLowerCase();
      final email = (userData['email'] ?? '').toString().toLowerCase();
      final city = (userData['city'] ?? '').toString().toLowerCase();
      final pincode = (userData['pinCode'] ?? userData['pincode'] ?? '').toString().toLowerCase();
      final purok = (userData['purok'] ?? '').toString().toLowerCase();
      
      // If email is empty, try to extract from email pattern
      String emailPrefix = '';
      if (email.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == userDoc.id) {
          emailPrefix = (currentUser.email ?? '').toLowerCase();
        }
      } else {
        emailPrefix = email;
      }
      
      // Extract name from email if needed
      String nameFromEmail = '';
      if (emailPrefix.contains('@')) {
        nameFromEmail = emailPrefix.split('@')[0];
      }
      
      return displayName.contains(lowerQuery) ||
          emailPrefix.contains(lowerQuery) ||
          nameFromEmail.contains(lowerQuery) ||
          city.contains(lowerQuery) ||
          pincode.contains(lowerQuery) ||
          purok.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Search users...',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('singers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final allUsers = snapshot.data!.docs;
            final filteredUsers = _filterUsers(allUsers, _searchQuery);

            if (filteredUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No users found matching "$_searchQuery"',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: const Text('Clear Search'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final userDoc = filteredUsers[index];
                final userData = userDoc.data() as Map<String, dynamic>;
                final uid = userDoc.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildUserCard(context, uid, userData),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, String uid, Map<String, dynamic> userData) {
    // Get email from Firestore if stored, otherwise try to get from Auth
    String email = userData['email']?.toString() ?? '';
    
    // If email not in Firestore, try to get it from Firebase Auth (for current user)
    if (email.isEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        email = currentUser.email ?? '';
      }
    }
    
    if (email.isEmpty) {
      email = 'No email';
    }
    
    // Extract name: first try Firestore, then extract from email
    String displayName;
    if (userData['displayName'] != null && userData['displayName'].toString().isNotEmpty) {
      displayName = userData['displayName'].toString();
    } else if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
      displayName = userData['name'].toString();
    } else if (email != 'No email' && email.contains('@')) {
      // Extract username from email (part before @)
      displayName = email.split('@')[0];
    } else {
      displayName = 'No Name';
    }
    
    final city = userData['city']?.toString() ?? '';
    final pincode = userData['pinCode']?.toString() ?? userData['pincode']?.toString() ?? '';
    final purok = userData['purok']?.toString() ?? '';
    
    // Format location (e.g., "Tago, Rosario" or just city if available)
    String location = city.isNotEmpty ? city : 'No location';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Avatar
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle: User Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Email
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Location
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (purok.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Purok: $purok',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  
                  // Pincode
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        const TextSpan(text: 'Pincode: '),
                        TextSpan(
                          text: pincode.isNotEmpty ? pincode : 'N/A',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Right: Action Icons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Icon
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(
                          uid: uid,
                          data: userData,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                // Delete Icon
                IconButton(
                  onPressed: () => _showDeleteConfirmDialog(context, uid),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String uid) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser != null && currentUser.uid == uid;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentUser ? 'Delete Account' : 'Delete User'),
        content: Text(
          isCurrentUser 
            ? 'Are you sure you want to delete your account? This action cannot be undone.'
            : 'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = AuthController();
              try {
                // Delete from Firestore
                await authController.deleteSinger(uid);
                
                // If deleting current user, also delete from Firebase Auth and sign out
                if (isCurrentUser) {
                  await FirebaseAuth.instance.currentUser?.delete();
                  await FirebaseAuth.instance.signOut();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User deleted successfully')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}