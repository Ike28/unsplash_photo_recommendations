import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'models/picture.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Picture> _photos = <Picture>[];

  @override
  void initState() {
    super.initState();
    _getImages();
  }

  Future<void> _getImages() async {
    final Client client = Client();
    final String accessKey = dotenv.env['UNSPLASH_API_KEY']!;
    const String query = 'audi';
    final Random rng = Random();
    const String count = '16';
    final String page = rng.nextInt(50).toString();

    final Response response = await client.get(Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query&client_id=$accessKey&per_page=$count&page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;

      setState(() {
        _photos.addAll(results.cast<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> json) => Picture.fromJson(json)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo recommendations'),
      ),
      body: _photos.isNotEmpty
          ? GridView.builder(
              itemCount: _photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (BuildContext context, int index) {
                final Picture picture = _photos[index];
                return GridTile(
                        child: Image.network(
                          picture.urls.regular,
                          fit: BoxFit.cover));
              })
          : const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading photos...'),
            ),
    );
  }
}
