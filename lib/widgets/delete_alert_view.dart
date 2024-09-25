import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loader.dart';

class DeleteAlertWidget extends StatelessWidget {

  final String name;
  const DeleteAlertWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24.0),
        Text(
          'Delete ${widgetFactory}',
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Are you sure you want to delete ?',
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            const SizedBox(
              width: 30,
            ),
            TextButton(
              onPressed: () {

              },
              child: const Text('Yes'),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        // if (_showLoader)
          const Column(
            children: [
              Loader(),
              SizedBox(height: 6.0),
              Text("Deleting, Please wait..."),
              SizedBox(height: 24.0),
            ],
          ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
