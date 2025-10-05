//NOTES:
/*
final: This declares a variable that will be assigned only once and cannot be reassigned. 
In this case, _firestore and _auth will be set to a reference to the FirebaseAuth and Firestore instance.

FirebaseFirestore _firestore: This declares _firestore as a variable of type FirebaseFirestore. 
This is the class that represents Firestore and provides methods to interact with your Firestore database 
(e.g., querying, adding, updating, deleting documents).

FirebaseFirestore.instance: This is a singleton instance of the FirebaseFirestore class. 
By accessing FirebaseFirestore.instance, you're retrieving the single, 
shared instance of Firestore for your app, which allows you to perform operations on the database.

_auth: This is a reference to Firebase's authentication system, used for things like signing in and registering users.

_firestore: This is a reference to Firestore, Firebase's cloud database, used to store and retrieve data.


*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Create a function with "Future" behavior
  Future<String> registerNewUser(
      String email, String name, String password) async {
    String result = 'something went wrong';
    try {
      //we want to create the user first in the authentication tab and then in the cloud firestore
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('singers').doc(userCredential.user!.uid).set({
        'name': name,
        'profileImage': "",
        'email': email,
        'uid': userCredential.user!.uid,
        'pinCode': "",
        'purok': '',
        'barangay': '',
        'city': '',
      });

      result = "success";
    } catch (e) {
      result = e.toString();
    }

    return result;
  }

  Future<String> loginUser(String email, String password) async {
    String result = 'something went wrong';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      result = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        result = 'Wrong password provided for that user.';
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  //GET ALL registered singers
  Stream<QuerySnapshot> getAllSingers() {
    return _firestore.collection('singers').snapshots();
  }

  //update singer
  Future<void> updateSinger(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('singers').doc(uid).update(data);
  }

  //delete singer
  Future<void> deleteSinger(String uid) async {
    await _firestore.collection('singers').doc(uid).delete();
  }
}
