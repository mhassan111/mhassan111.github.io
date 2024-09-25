import 'package:flutter/cupertino.dart';
import 'package:x51/utils/text_styles.dart';

class ErrorText extends StatelessWidget {
  final String error;

  const ErrorText({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
