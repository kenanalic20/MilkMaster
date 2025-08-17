import 'package:flutter/material.dart';

Widget leadingIcon(dynamic icon, {double width = 25, double height = 25}) {
  if (icon is IconData) {
    return Icon(icon, color: const Color.fromRGBO(27, 27, 27, 1));
  } else if (icon is String) {
    return Image.asset(icon, width: width, height: height, fit: BoxFit.contain);
  } else {
    return const SizedBox();
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  bool showCancel = true,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: const Text("OK"),
        ),
        if (showCancel)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Cancel"),
          ),
      ],
    ),
  );
}
