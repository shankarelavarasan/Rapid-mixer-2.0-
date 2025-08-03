import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../drifft file.dart';

void main() {
  runApp(const RapidMixerApp());
}

class RapidMixerApp extends StatelessWidget {
  const RapidMixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Rapid Mixer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const AudioImport(),
        );
      },
    );
  }
}