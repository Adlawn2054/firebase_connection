import 'package:cloud_firestore/cloud_firestore.dart';
//Even though you don’t directly use Firestore in this file,
//it’s needed because AuthController uses Firestore when registering a user.

import 'package:flutter/material.dart';
//Core Flutter widgets (Scaffold, Text, Form, TextFormField, etc.).

import 'package:google_fonts/google_fonts.dart';
//Custom fonts (Lato, Nunito Sans, Roboto) for styling UI text.

import 'package:mike_test_app/controllers/auth_controller.dart';
//Connects the UI with your authentication logic (signup & login functions).

import 'package:mike_test_app/views/screens/authentication_screen/login_screen.dart';
//Lets you navigate to the login screen after successful registration.

//StatefulWidget → UI changes dynamically
//(e.g., show/hide password, show loading spinner or CircularProgressIndicator).
class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

//Holds the UI state, variables, and logic.
class _RegisterScreenState extends State<RegisterScreen> {
  //

  // Creates a local instance of your AuthController class.
  // Used to validate the form (email, name, password fields).
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Creates a local instance of your AuthController class.
// This is the bridge between UI and Firebase (calls registerNewUser).
  final AuthController _authController = AuthController();

// Controls the loading spinner when submitting.
  bool _isLoading = false;

// Store user input from the form fields.
// late means they’ll be initialized later via onChanged.
//must be assigned before use.
  late String email;
  late String name;
  late String password;

//Used to toggle password visibility.
  bool _isObscure = true;

//registerUser method
  registerUser() async {
    BuildContext localContext = context;

    // Sets loading state so UI shows a CircularProgressIndicator.
    setState(() {
      _isLoading = true;
    });

    // Calls AuthController.registerNewUser, passing email, name, and password.
    // This method creates the user in Firebase Auth.
    // Then stores profile data in Firestore.
    String res = await _authController.registerNewUser(email, name, password);

    //If registration was successful, Navigates to LoginScreen and Shows a SnackBar confirming success.
    if (res == 'success') {
      Future.delayed(Duration.zero, () {
        Navigator.push(localContext, MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }));

        ScaffoldMessenger.of(localContext).showSnackBar(SnackBar(
            content: Text('Your account has been successfully created.')));
      });

      //If failed, Stop loading spinner and Show error message from Firebase (via AuthController)
    } else {
      setState(() {
        _isLoading = false;
      });

      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res)));
      });
    }
  }

// UI Side
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(
        0.95,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            // Uses _formKey and TextFormField.validator to ensure input is not empty.
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register Your Account",
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: const Color(0xFF0d120E),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      fontSize: 23,
                    ),
                  ),
                  Text(
                    "To Explore Flutter with Firebase",
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: const Color(0xFF0d120E),
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Image.asset(
                    'assets/images/Illustration.png',
                    width: 100,
                    height: 100,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  //textformfield for email
                  TextFormField(
                    //Updates variables (email, name, password)
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 217, 231, 235),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'Enter your email',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Name',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  //textformfield for name
                  TextFormField(
                    onChanged: (value) {
                      name = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your full name';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 217, 231, 235),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'Enter your full name',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/user.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //textformfield for password
                  //it Uses _isObscure to toggle hide/show password.
                  TextFormField(
                    obscureText: _isObscure,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 217, 231, 235),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'Enter your password',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //Uses InkWell widget to trigger registerUser() if form is valid.
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    child: Container(
                      width: 319,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF102DE1),
                            Color(0xCC0D6EFF),
                          ],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Sign up',
                                style: GoogleFonts.getFont(
                                  'Lato',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an Account?',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginScreen();
                          }));
                        },
                        child: Text(
                          ' Sign in',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF102DE1),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} //end of _RegisterScreenState Method
