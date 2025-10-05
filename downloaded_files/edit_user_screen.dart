import 'package:flutter/material.dart';
import 'package:mike_test_app/controllers/auth_controller.dart';

class EditUserScreen extends StatefulWidget {
  // uid → the Firestore document ID or unique identifier for this singer.
  // data → the full map of existing values (name, email, pinCode, etc.) so you can prefill text fields.
  final String uid;
  final Map<String, dynamic> data;

  const EditUserScreen({super.key, required this.uid, required this.data});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  // You create an AuthController so you can update Firestore.
  final AuthController _authController = AuthController();

  // TextEditingController hold the current text for each input field.
  // Declared as late → means you will initialize them in initState.
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController pinCodeController;
  late TextEditingController purokController;
  late TextEditingController barangayController;
  late TextEditingController cityController;

  // Runs once when the widget is created.
  // Each controller is seeded with the corresponding value from widget.data.
  // This way, when the form appears, fields are pre-populated with the current data.
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    emailController = TextEditingController(text: widget.data['email']);
    pinCodeController = TextEditingController(text: widget.data['pinCode']);
    purokController = TextEditingController(text: widget.data['purok']);
    barangayController = TextEditingController(text: widget.data['barangay']);
    cityController = TextEditingController(text: widget.data['city']);
  }

  //UI Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Singer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: pinCodeController,
                decoration: const InputDecoration(labelText: "Pin Code")),
            TextField(
                controller: purokController,
                decoration: const InputDecoration(labelText: "Purok")),
            TextField(
                controller: barangayController,
                decoration: const InputDecoration(labelText: "Barangay")),
            TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                //widget.uid identifies which document to update.
                // The second parameter is a map of new values taken from controllers.
                await _authController.updateSinger(widget.uid, {
                  'name': nameController.text,
                  'email': emailController.text,
                  'pinCode': pinCodeController.text,
                  'purok': purokController.text,
                  'barangay': barangayController.text,
                  'city': cityController.text,
                  'profileImage': widget.data['profileImage'], // keep old image

                  'uid': widget.uid,
                });
                // After the update finishes, Navigator.pop(context)
                //closes the screen and returns to the previous one (AccountScreen).
                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
