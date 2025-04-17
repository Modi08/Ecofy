import 'package:flutter/material.dart';

void showSnackbar(context, String msg, bool isError, [int duration = 3]) {
  SnackBar snackBar = SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.greenAccent, duration: Duration(seconds: duration),);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
