import 'dart:convert';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ecofy/components/button.dart';
import 'package:ecofy/services/general/colors.dart';
import 'package:ecofy/services/general/snackBar.dart';
import 'package:ecofy/pages/signup_screen.dart';
import 'package:ecofy/services/general/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  final DatabaseService database;
  final double width;
  final double height;
  const LoginScreen({
    super.key,
    required this.database,
    required this.height,
    required this.width,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  late String? apiUrl;

  Future<void> login() async {
    await dotenv.load();

    apiUrl = dotenv.env["httpURL"];

    var paramsApiUrl =
        "$apiUrl/recyclingLoginApp?email=${emailController.text}&pwd=${pwdController.text}";

    try {
      var response = await http.put(Uri.parse(paramsApiUrl));

      if (mounted) {
        var responseData = jsonDecode(response.body);

        showSnackbar(context, responseData['msg'], response.statusCode == 400);

        if (response.statusCode == 200) {
          widget.database.replace(responseData["user"]).then((data) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainNavigation(
                  database: widget.database,
                  userId: responseData["user"]["userId"],
                  width: widget.width,
                  height: widget.height,
                ),
              ),
            );
          });
        }
      }
    } catch (error) {
      if (mounted) {
        print("Error occurred during login: $error");
        showSnackbar(context, "An error occurred. Please try again.", true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: appBarColor,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: widget.height * 0.05),
                  // Enlarge the recycling image
                  Icon(
                    Icons.recycling_sharp,
                    size: widget.height * 0.15, // Increased size
                    color: Colors.green,
                  ),
                  SizedBox(
                      height: widget.height * 0.05), // Move text further down
                  const Text(
                    "Welcome back. You've been missed!",
                    style: TextStyle(
                      fontSize: 20, // Slightly larger text
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: widget.height * 0.04),
                  _buildTextField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                  ),
                  SizedBox(height: widget.height * 0.03),
                  _buildTextField(
                    controller: pwdController,
                    hintText: "Password",
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: widget.height * 0.04),
                  CButton(onTap: login, text: "Login"),
                  SizedBox(height: widget.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 15, // Increase the font size
                          fontWeight: FontWeight
                              .normal, // Keep normal weight for clarity
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(
                                database: widget.database,
                                height: widget.height,
                                width: widget.width,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          " Register now",
                          style: TextStyle(
                            fontSize:
                                15, // Match the size with the "Don't have an account?"
                            color: Colors.green,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
