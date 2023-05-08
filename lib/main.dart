import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(const PhotosApp());
}

class PhotosApp extends StatelessWidget {
  const PhotosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo recommendations app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
