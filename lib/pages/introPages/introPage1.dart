import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  final double width;
  final double height;
  const IntroPage1({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[200],
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/intropage1.png',
                height: height * 0.35,
              ),
              SizedBox(height: height * 0.05),
              Text(
                'Upload and Track',
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Simply snap a photo of your recyclable items and upload it to the app. We'll help you track your recycling progress and impact.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.04,
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
