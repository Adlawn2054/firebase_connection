import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> registerNewUser(
    String email,
    String name,
    String password,
  ) async {
    String result = 'something went Wrong';
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('singers').doc(userCredential.user!.uid).set({
        'name': name,
        'profileImage': "",
        'uid': userCredential.user!.uid,
        'pinCode': "",
        'purok': '',
        'city': '',
      });

      result = 'success';
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
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }
  
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

