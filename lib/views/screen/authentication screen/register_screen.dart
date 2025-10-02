import 'package:firebase_connection/controllers/auth_controller.dart';
import 'package:firebase_connection/views/screen/authentication%20screen/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  // bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late String name;
  late String email;
  late String password;

  registerUser() async {
    setState(() {
      _isLoading = true;
    });
    BuildContext localContext = context;
    String res = await _authController.registerNewUser(email, name, password);
    if (res == 'success') {
      Navigator.push(
        localContext,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
      );
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(content: Text('Your Account has been Successfully Created.')),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey, // ✅ Wrap with Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Register Your Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "To Explore Flutter with Firebase",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 20),

                // Logo
                Center(
                  child: Image.asset(
                    "assets/images/logo.png", // replace with your logo
                    height: 120,
                  ),
                ),

                const SizedBox(height: 30),

                // Email
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your Email tanga';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.blue,
                    ),
                    hintText: "Enter your email",
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Full Name
                TextFormField(
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your FULL NAME';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.blue,
                    ),
                    hintText: "Enter your full name",
                    labelText: "Name",
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your Password';
                    } else {
                      return null;
                    }
                  },
                  obscureText: _obscurePassword, // use state
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.blue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword; // toggle
                        });
                      },
                    ),
                    // suffixIcon: const Icon(Icons.visibility, color: Colors.grey),
                    hintText: "Enter your password",
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                    : InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            // print(email);
                            // print(name);
                            // print(password);
                            // _authController.registerNewUser(email, name, password);
                            registerUser();
                          } else {
                            print('failed');
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 56, 147, 221),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // go back to login
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
