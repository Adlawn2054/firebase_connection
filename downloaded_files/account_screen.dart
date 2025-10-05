import 'package:flutter/material.dart';
import 'package:mike_test_app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mike_test_app/views/screens/nav_screens/edit_user_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Singers List"),
      ),

      //listens to Firestore stream returned by getAllSingers()
      //and rebuilds whenever the collection changes (real-time updates).
      // snapshot is an AsyncSnapshot<QuerySnapshot>
      //— it contains connection state, whether data exists, and the actual documents.
      body: StreamBuilder<QuerySnapshot>(
        stream: _authController.getAllSingers(),
        builder: (context, snapshot) {
          //the initial state while the stream is being established — show spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // handle the case of no documents — show a message instead of an empty list.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No singers found"));
          }

          // snapshot.data!.docs yields a List<QueryDocumentSnapshot>.
          final singers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: singers.length,
            itemBuilder: (context, index) {
              // you cast to Map<String, dynamic> so you can access fields safely.
              var data = singers[index].data() as Map<String, dynamic>;

              // Use ?? or containsKey to avoid runtime exceptions when fields are missing
              //(this fixes the Bad state: ex. field "email" does not exist runtime error).
              var uid = data['uid'] ?? '';
              var name = data['name'] ?? 'No Name';
              var email =
                  data.containsKey('email') ? data['email'] : 'No Email';

              // ListTile displays user avatar/icon, name in the main line and email below.
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Text(email),

                // trailing widgets are two IconButtons: edit and delete.
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navigator.push opens EditUserScreen.
                        // You pass uid and the entire data map as arguments
                        //— EditUserScreen can prefill form fields with data.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditUserScreen(
                              uid: uid,
                              data: data,
                            ),
                          ),
                        );
                      },
                    ),
                    // delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        //The dialog asks user to confirm. Buttons pop the dialog and return true (Yes) or false (No).
                        // After awaiting the dialog, check confirmDelete == true — only then call _authController.deleteSinger(uid).
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text(
                                  "Are you sure you want to delete $name?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          _authController.deleteSinger(uid);
                          // ScaffoldMessenger.of(context).showSnackBar(...) shows a quick feedback message.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$name has been deleted")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
