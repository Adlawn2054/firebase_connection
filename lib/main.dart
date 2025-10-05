import 'dart:io';

import 'package:flutter/services.dart';
import 'package:firebase_connection/views/screen/authentication%20screen/register_screen.dart';
import 'package:firebase_connection/views/screen/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_connection/views/screen/authentication%20screen/login_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAHg1INwJDWNraTT2so9xbLAr_4BY5TGo4',
        appId: '1:77632698525:android:906b9f28b768eb4b83fc74',
        messagingSenderId: '77632698525',
        projectId: 'fir-connection-495af',
        storageBucket: 'fir-connection-495af.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return MaterialApp(
      title: 'Connection To Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: RegisterScreen(),
    );
  }
}
