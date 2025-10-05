import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mike_test_app/views/screens/authentication_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  /// Checks both connectivity (wifi/mobile) AND actual internet
  Future<bool> _hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false; // not even connected to wifi/mobile
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // actual internet access
      }
    } on SocketException catch (_) {
      return false; //  no internet
    }

    return false;
  }

  Future<void> _checkInternet() async {
    await Future.delayed(const Duration(seconds: 2)); // show splash

    bool hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      setState(() {
        _errorMessage = "No internet connection.\nPlease check your network.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: _errorMessage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  FlutterLogo(size: 100),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Checking internet...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _checkInternet();
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
      ),
    );
  }
}
