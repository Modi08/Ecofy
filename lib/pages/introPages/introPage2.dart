import 'package:flutter/material.dart';

// ignore: must_be_immutable
class IntroPage2 extends StatefulWidget {
  double width;
  double height;
  IntroPage2({super.key, required this.width, required this.height});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[200],
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(widget.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/intropage2.png',
                height: widget.height * 0.35,
              ),
              SizedBox(height: widget.height * 0.05),
              const Text(
                'Climb the Leaderboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: widget.height * 0.02),
              const Text(
                'The more photos you upload, the higher you go on the leaderboard. Compete with friends and see who can be the most eco-friendly!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}