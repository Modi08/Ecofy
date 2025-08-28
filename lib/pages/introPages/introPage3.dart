import 'package:flutter/material.dart';

class IntroPage3 extends StatefulWidget {
  final double width;
  final double height;
  const IntroPage3({super.key, required this.width, required this.height});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color.fromRGBO(21, 25, 31, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You are all set!',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.height * 0.02),
            Text(
              'Start your journey with Ecofy now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: widget.width * 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}