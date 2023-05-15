import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'homepage.dart';

void main() async {
  await dotenv.load();
  runApp(const PhotosApp());
}

class PhotosApp extends StatelessWidget {
  const PhotosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo recommendations app',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
