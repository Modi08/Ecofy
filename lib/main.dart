import 'package:ecofy/services/general/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:ecofy/pages/welcome_screen.dart'; // Replace your_app_name with the actual app name
import 'pages/signup_screen.dart'; // Import SignUpScreen
import 'pages/login_screen.dart'; // Import LoginScreen

void main() async {
  runApp(const Ecofy());
}

class Ecofy extends StatefulWidget {
  const Ecofy({super.key});

  @override
  State<Ecofy> createState() => _EcofyState();
}

class _EcofyState extends State<Ecofy> {
  final DatabaseService database = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      title: 'Ecofy',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(width: width, height: height),
        '/signup': (context) =>
            SignUpScreen(database: database, width: width, height: height),
        '/login': (context) =>
            LoginScreen(database: database, width: width, height: height),
      },
    );
  }
}
