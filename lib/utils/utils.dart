import 'package:flutter/material.dart';

class utils {
  customSnackbar(BuildContext context, String message) {
    var snackBar = SnackBar(content: Text('$message'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
