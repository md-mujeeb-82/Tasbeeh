// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CustomMessageDialog extends StatelessWidget {
  final String _title;
  final String _message;

  const CustomMessageDialog(this._title, this._message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: Text(_message),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
