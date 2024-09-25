import '../../pages/record/ambient_recorder.dart';
import '../../utils/utils.dart';
import 'package:flutter/material.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AmbientRecorder(
          onStop: (String path) async {
            Utils.printMessage('path = $path');
          },
        ));
  }
}
