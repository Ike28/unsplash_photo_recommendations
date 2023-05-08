import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _photos = <String>[];

  @override
  void initState() {
    super.initState();
    _getImages();
  }

  Future<void> _getImages() async {
    const String accessKey = 'zK9UCH1xkpTIJkZZIyax9kUJlEzJRNovydBMR_ToFTY';
    const String query = 'audi';
    final Random rng = Random();
    const String count = '16';
    final String page = rng.nextInt(50).toString();

    final Response response = await get(
      Uri.parse(
          'https://api.unsplash.com/search/photos?query=$query&client_id=$accessKey&per_page=$count&page=$page'
      )
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;
      for (final dynamic element in results) {
        final Map<String, dynamic> currentResult = element as Map<String, dynamic>;
        final Map<String, dynamic> uriResult = currentResult['urls'] as Map<String, dynamic>;
        _photos.add(uriResult['regular'] as String);
      }
      setState(() {
        // update list
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GridTile(
                        child: Image.network(_photos[index],
                        fit: BoxFit.cover
                        )
                  );
                }
            )
        : const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading photos...'
            ),
      ),
    );
  }
}
