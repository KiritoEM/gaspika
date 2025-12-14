import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class SnackbarUtils {
  static void showInSnackBar(
    BuildContext context,
    String value, {
    SnackbarType type = SnackbarType.success,
  }) {
    Color getSnackbarColor() {
      switch (type) {
        case SnackbarType.success:
          return Colors.green;
        case SnackbarType.error:
          return Colors.red;
        case SnackbarType.warning:
          return Colors.orange;
        case SnackbarType.info:
          return Colors.blue;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        backgroundColor: getSnackbarColor(),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
