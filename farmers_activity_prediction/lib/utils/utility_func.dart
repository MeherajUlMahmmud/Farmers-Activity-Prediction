import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UtilityFunction {
  static showAlertDialog(
      BuildContext context, String title, String message, bool success) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (success) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      },
    );
  }

  static showSnackbar(BuildContext context, String message, bool success) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  static String stringToDateTime(String date) {
    var dateTime = DateTime.parse(date);
    var formatter = new DateFormat('MMM. dd, yyyy, hh:mm a');
    return formatter.format(dateTime);
  }
}
