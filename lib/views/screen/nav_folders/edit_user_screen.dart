import 'package:flutter/material.dart';


class EditUserScreen extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;

  const EditUserScreen({super.key, required this.uid, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editing user: $uid'),
            const SizedBox(height: 10),
            Text('Name: ${data['name'] ?? 'No name'}'),
            Text('Email: ${data['email'] ?? 'No email'}'),
            // Add your TextFields or other editing UI here
          ],
        ),
      ),
    );
  }
}