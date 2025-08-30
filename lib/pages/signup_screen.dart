import 'dart:convert';
import 'package:ecofy/pages/introduction_screen.dart';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ecofy/components/button.dart';
import 'package:ecofy/services/general/snackbar.dart';
import 'package:ecofy/pages/login_screen.dart';
import 'package:ecofy/services/general/colors.dart';

class SignUpScreen extends StatefulWidget {
  final DatabaseService database;
  final double height;
  final double width;

  const SignUpScreen({
    super.key,
    required this.database,
    required this.height,
    required this.width,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  final confirmPwdController = TextEditingController();
  final usernameController = TextEditingController();
  late String? apiUrl;

  @override
  void dispose() {
    emailController.dispose();
    pwdController.dispose();
    confirmPwdController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void signUp() async {
    await dotenv.load();
    apiUrl = dotenv.env["httpURL"];

    if (pwdController.text != confirmPwdController.text) {
      if (mounted) {
        showSnackbar(context, "Passwords don't match", true);
      }
      return;
    }

    final requestBody = {
      "email": emailController.text,
      "pwd": pwdController.text,
      "username": usernameController.text,
    };

    try {
      var response = await http.post(
        Uri.parse("$apiUrl/recyclingSignUp"),
        body: jsonEncode(requestBody),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (mounted) {
        final responseData = jsonDecode(response.body);
        showSnackbar(
          context,
          responseData['msg'],
          response.statusCode == 400,
        );

        if (response.statusCode == 200) {
          widget.database.replace(responseData["user"]).then((data) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroductionScreen(
                    database: widget.database,
                    userId: responseData["user"]["userId"],
                    width: widget.width,
                    height: widget.height,
                  ),
                ));
          });
        }
      }
    } catch (error) {
      if (mounted) {
        print("Signup error: $error");
        showSnackbar(context, "An error occurred. Please try again.", true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: appBarColor,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: widget.height * 0.05),
                  Icon(
                    Icons.recycling_sharp,
                    size: widget.height * 0.15,
                    color: Colors.green,
                  ),
                  SizedBox(height: widget.height * 0.03),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildTextField(
                    controller: usernameController,
                    hintText: "Username",
                    icon: Icons.person,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildTextField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildTextField(
                    controller: pwdController,
                    hintText: "Password",
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildTextField(
                    controller: confirmPwdController,
                    hintText: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  SizedBox(height: widget.height * 0.03),
                  CButton(
                    onTap: signUp,
                    text: "Sign Up",
                  ),
                  SizedBox(height: widget.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                database: widget.database,
                                height: widget.height,
                                width: widget.width,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          " Sign in",
                          style: TextStyle(
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
