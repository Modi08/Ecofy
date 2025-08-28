import 'package:ecofy/pages/introPages/introPage1.dart';
import 'package:ecofy/pages/introPages/introPage2.dart';
import 'package:ecofy/pages/introPages/introPage3.dart';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:ecofy/services/general/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen extends StatefulWidget {
  final DatabaseService database;
  final String userId;
  final double width;
  final double height;
  const IntroductionScreen(
      {super.key,
      required this.database,
      required this.userId,
      required this.width,
      required this.height});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController pageController = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: pageController,
          onPageChanged: (value) => setState(() {
            onLastPage = (value == 2);
          }),
          children: [
            IntroPage1(
              width: widget.width,
              height: widget.height,
            ),
            IntroPage2(
              width: widget.width,
              height: widget.height,
            ),
            IntroPage3( width: widget.width,
              height: widget.height,),
          ],
        ),
        Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text(
                    "Skip",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  onPressed: () {
                    pageController.jumpToPage(2);
                  },
                ),
                SmoothPageIndicator(controller: pageController, count: 3),
                onLastPage
                    ? OutlinedButton(
                        child: Text("Done",
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainNavigation(
                                  database: widget.database,
                                  userId: widget.userId,
                                  width: widget.width,
                                  height: widget.height,
                                ),
                              ));
                        },
                      )
                    : OutlinedButton(
                        child: Text("Next",
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        onPressed: () {
                          pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                      ),
              ],
            ))
      ]),
    );
  }
}
